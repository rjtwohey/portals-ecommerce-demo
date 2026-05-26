import React, { useContext, useEffect, useState } from 'react';
import {
  IonButton,
  IonButtons,
  IonContent,
  IonHeader,
  IonItem,
  IonLabel,
  IonList,
  IonListHeader,
  IonPage,
  IonTitle,
  IonToolbar,
  useIonRouter,
} from '@ionic/react';
import { registerPlugin } from '@capacitor/core';
import { DataContext } from '../../DataProvider';
import './CheckoutPage.scss';
import { Address, CreditCard } from '../../ShopAPIPlugin';
import AddressItem from '../../components/AddressItem';
import PaymentItem from '../../components/PaymentItem';
import * as Portals from '@ionic/portals';
import FadeIn from '../../components/FadeIn';

interface IonicProviderTestPlugin {
  isProviderRegistered(): Promise<{ registered: boolean }>;
  getLatestAppDirectory(options: {
    liveUpdateTarget: 'help' | 'webapp' | 'featured';
  }): Promise<{ latestAppDirectory: string | null }>;
  syncManager(options: {
    liveUpdateTarget: 'help' | 'webapp' | 'featured';
  }): Promise<{ latestAppDirectory: string | null; metadata?: Record<string, unknown> }>;
}

const IonicProviderTest = registerPlugin<IonicProviderTestPlugin>('IonicProviderTest');

const providerConfig = {
  liveUpdateTarget: 'webapp' as const,
};

const CheckoutPage: React.FC = () => {
  const { cart, user, checkout } = useContext(DataContext);
  const [selectedAddress, setSelectedAddress] = useState<Address>();
  const [selectedCreditCard, setSelectedCreditCard] = useState<CreditCard>();
  const [providerTestOutput, setProviderTestOutput] = useState<string>('Not run yet.');
  const [providerTestRunning, setProviderTestRunning] = useState<boolean>(false);
  const router = useIonRouter();

  const runProviderTest = async (action: 'isProviderRegistered' | 'getLatestAppDirectory' | 'syncManager') => {
    setProviderTestRunning(true);
    try {
      let result: unknown;
      if (action === 'isProviderRegistered') {
        result = await IonicProviderTest.isProviderRegistered();
      } else if (action === 'getLatestAppDirectory') {
        result = await IonicProviderTest.getLatestAppDirectory(providerConfig);
      } else {
        result = await IonicProviderTest.syncManager(providerConfig);
      }
      setProviderTestOutput(JSON.stringify(result, null, 2));
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      setProviderTestOutput(`Error: ${message}`);
    } finally {
      setProviderTestRunning(false);
    }
  };

  useEffect(() => {
    if (user && !selectedAddress) {
      const address = user.addresses.find((x) => x.preferred);
      if (address) {
        setSelectedAddress(address);
      }
    }
    if (user && !selectedCreditCard) {
      const creditCard = user.creditCards.find((x) => x.preferred);
      if (creditCard) {
        setSelectedCreditCard(creditCard);
      }
    }
  }, [selectedAddress, selectedCreditCard, user]);

  return (
    <IonPage id="checkout-page">
      <IonHeader>
        <IonToolbar>
          <IonButtons slot="start">
            <IonButton
              onClick={() => {
                Portals.publish({ topic: 'dismiss', data: 'cancel' });
              }}
            >
              Cancel
            </IonButton>
          </IonButtons>
          <IonTitle>Checkout</IonTitle>
        </IonToolbar>
      </IonHeader>
      <FadeIn isLoaded={user != null && cart != null}>
        <IonContent className="ion-padding">
          {cart && user && (
            <>
              <IonList lines="none">
                <IonListHeader>Delivery</IonListHeader>
                {user.addresses.map((address) => (
                  <AddressItem
                    key={address.id}
                    address={address}
                    onAddressSelected={(address) => setSelectedAddress(address)}
                    selectedId={selectedAddress?.id}
                    user={user}
                  />
                ))}
              </IonList>
              <IonButton
                expand="block"
                color="secondary"
                onClick={() => router.push('/address')}
              >
                New Address
              </IonButton>

              <IonList lines="none">
                <IonListHeader>Payment</IonListHeader>
                {user.creditCards.map((creditCard) => (
                  <PaymentItem
                    key={creditCard.id}
                    creditCard={creditCard}
                    selectedId={selectedCreditCard?.id}
                    onPaymentSelected={(creditCard) =>
                      setSelectedCreditCard(creditCard)
                    }
                    selectable={true}
                  />
                ))}
              </IonList>
              <IonButton
                expand="block"
                color="secondary"
                onClick={() => router.push('/payment')}
              >
                New Payment Method
              </IonButton>

              <IonList lines="none">
                <IonListHeader>Review total</IonListHeader>
                <IonItem>
                  <IonLabel>${cart.subTotal} + Tax</IonLabel>
                </IonItem>
              </IonList>
              <IonButton
                className="order-button"
                expand="block"
                onClick={() => {
                  const result = 'success';
                  checkout({ result });
                  Portals.publish({ topic: 'dismiss', data: result });
                }}
              >
                Place Your Order Please
              </IonButton>

              <div className="provider-test-panel">
                <IonListHeader>Live Update Provider Test</IonListHeader>
                <p className="provider-test-panel__help">
                  Uses IonicProviderTest plugin with live update target <strong>{providerConfig.liveUpdateTarget}</strong>.
                </p>
                <div className="provider-test-panel__actions">
                  <IonButton
                    size="small"
                    fill="outline"
                    disabled={providerTestRunning}
                    onClick={() => runProviderTest('isProviderRegistered')}
                  >
                    Is Provider Registered?
                  </IonButton>
                  <IonButton
                    size="small"
                    fill="outline"
                    disabled={providerTestRunning}
                    onClick={() => runProviderTest('getLatestAppDirectory')}
                  >
                    Get Latest App Directory
                  </IonButton>
                  <IonButton
                    size="small"
                    disabled={providerTestRunning}
                    onClick={() => runProviderTest('syncManager')}
                  >
                    Sync Manager
                  </IonButton>
                </div>
                <pre className="provider-test-panel__output">{providerTestOutput}</pre>
              </div>
            </>
          )}
        </IonContent>
      </FadeIn>
    </IonPage>
  );
};

export default CheckoutPage;
