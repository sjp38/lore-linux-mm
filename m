Received: from localhost (amlaukka@localhost)
	by sirppi.helsinki.fi (8.10.1/8.10.1) with ESMTP id e7GMhS509042
	for <linux-mm@kvack.org>; Thu, 17 Aug 2000 01:43:28 +0300 (EET DST)
Date: Thu, 17 Aug 2000 01:43:26 +0300 (EET DST)
From: Aki M Laukkanen <amlaukka@cc.helsinki.fi>
Subject: 2.4.0-test7-pre4-vm2 results
Message-ID: <Pine.OSF.4.20.0008170130550.7212-200000@sirppi.helsinki.fi>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-714346355-966465806=:7212"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--0-714346355-966465806=:7212
Content-Type: TEXT/PLAIN; charset=US-ASCII

Hello,
I tested the patch with two workloads on 2x466 Celeron/128MB. Btw. I couldn't
trigger the SMP race with these tests. What kind of workload is needed?

* make -j30 bzImage

* bonnie++ -s 512
[amlaukka@stellar tmp]$ bon_csv2txt <stellar.pp.htv.fi-2.4.0-test7-pre4-vm
Version  1.00  ------Sequential Output------ --Sequential Input---Random-
               -Per Chr- --Block-- -Rewrite- -Per Chr- --Block----Seeks--
Machine        MB K/sec %CP K/sec %CP K/sec %CP K/sec %CP K/sec %CP  /sec %CP
   Unknown     512  6236 87 11975  18 4242   8  5217  66  9623  10   nan 
   -2147483648
               ------Sequential Create------ --------RandomCreate--------
               -Create-- --Read--- -Delete-- -Create-- --Read----Delete--
files:max:min /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP
Unknown 30    129  98 +++++  90  5484  99   130  98 +++++  97   642  96

For comparison:
[amlaukka@stellar tmp]$ bon_csv2txt <stellar.pp.htv.fi-2.3.99-pre6-3
Version  1.00 ------Sequential Output------ --Sequential Input---Random-
              -Per Chr- --Block-- -Rewrite- -Per Chr- --Block----Seeks--
Machine       MB K/sec %CP K/sec %CP K/sec %CP K/sec %CP K/sec %CP  /sec%CP
   Unknown    256 7484 100 24077  40  7602  15  7005  90 22186  29   nan
-2147483648
              ------Sequential Create------ --------RandomCreate--------
              -Create-- --Read--- -Delete-- -Create-- --Read----Delete--
files:max:min /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec%CP
Unknown 30    125  99 +++++  96  6043 100   127  99 +++++  99   602 90

I also logged vmstat, date and cat /proc/zoneinfo every seconds. These logs
are available at 

http://www.cs.helsinki.fi/Aki.Laukkanen/log.1.bz2 (make)
http://www.cs.helsinki.fi/Aki.Laukkanen/log.2.bz2 (bonnie++)

/proc/zoneinfo is a silly hack. Hopefully it's somewhat useful. See attached
patch. I haven't done much analyzing on these logs although there seems to
be gaps of several tens of seconds (indicating burstiness).


-- 
D.

--0-714346355-966465806=:7212
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="zoneinfo-t7-p4-vm2.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.OSF.4.20.0008170143260.7212@sirppi.helsinki.fi>
Content-Description: 
Content-Disposition: attachment; filename="zoneinfo-t7-p4-vm2.patch"

ZGlmZiAtdXJOIGxpbnV4LTIuNC4wLXQ3LXA0LXZtLmJhay9mcy9wcm9jL3By
b2NfbWlzYy5jIGxpbnV4LTIuNC4wLXQ3LXA0LXZtL2ZzL3Byb2MvcHJvY19t
aXNjLmMNCi0tLSBsaW51eC0yLjQuMC10Ny1wNC12bS5iYWsvZnMvcHJvYy9w
cm9jX21pc2MuYwlUaHUgQXVnIDE3IDAxOjI5OjM3IDIwMDANCisrKyBsaW51
eC0yLjQuMC10Ny1wNC12bS9mcy9wcm9jL3Byb2NfbWlzYy5jCVdlZCBBdWcg
MTYgMjM6NDk6MzAgMjAwMA0KQEAgLTYzLDYgKzYzLDcgQEANCiBleHRlcm4g
aW50IGdldF9pcnFfbGlzdChjaGFyICopOw0KIGV4dGVybiBpbnQgZ2V0X2Rt
YV9saXN0KGNoYXIgKik7DQogZXh0ZXJuIGludCBnZXRfbG9ja3Nfc3RhdHVz
IChjaGFyICosIGNoYXIgKiosIG9mZl90LCBpbnQpOw0KK2V4dGVybiBpbnQg
Z2V0X3pvbmVpbmZvIChjaGFyICosIGNoYXIgKiosIG9mZl90LCBpbnQpOw0K
IGV4dGVybiBpbnQgZ2V0X3N3YXBhcmVhX2luZm8gKGNoYXIgKik7DQogI2lm
ZGVmIENPTkZJR19TR0lfRFMxMjg2DQogZXh0ZXJuIGludCBnZXRfZHMxMjg2
X3N0YXR1cyhjaGFyICopOw0KQEAgLTI4OSw2ICsyOTAsMTggQEANCiB9DQog
I2VuZGlmDQogDQorc3RhdGljIGludCB6b25laW5mb19yZWFkX3Byb2MoY2hh
ciAqcGFnZSwgY2hhciAqKnN0YXJ0LCBvZmZfdCBvZmYsDQorCQkJICAgICAg
aW50IGNvdW50LCBpbnQgKmVvZiwgdm9pZCAqZGF0YSkNCit7DQorCWludCBs
ZW4gPSBnZXRfem9uZWluZm8ocGFnZSwgc3RhcnQsIG9mZiwgY291bnQpOw0K
KwlsZW4gLT0gKCpzdGFydC1wYWdlKTsNCisJaWYgKGxlbiA8PSBjb3VudCkN
CisJCSplb2YgPSAxOw0KKwlpZiAobGVuID4gY291bnQpIGxlbiA9IGNvdW50
Ow0KKwlpZiAobGVuIDwgMCkgbGVuID0gMDsNCisJcmV0dXJuIGxlbjsNCit9
DQorDQogc3RhdGljIGludCBrc3RhdF9yZWFkX3Byb2MoY2hhciAqcGFnZSwg
Y2hhciAqKnN0YXJ0LCBvZmZfdCBvZmYsDQogCQkJCSBpbnQgY291bnQsIGlu
dCAqZW9mLCB2b2lkICpkYXRhKQ0KIHsNCkBAIC02MzksNiArNjUyLDcgQEAN
CiAJCXsic3dhcHMiLAlzd2Fwc19yZWFkX3Byb2N9LA0KIAkJeyJpb21lbSIs
CW1lbW9yeV9yZWFkX3Byb2N9LA0KIAkJeyJleGVjZG9tYWlucyIsCWV4ZWNk
b21haW5zX3JlYWRfcHJvY30sDQorCQl7InpvbmVpbmZvIiwJem9uZWluZm9f
cmVhZF9wcm9jfSwNCiAJCXtOVUxMLE5VTEx9DQogCX07DQogCWZvcihwPXNp
bXBsZV9vbmVzO3AtPm5hbWU7cCsrKQ0KQEAgLTY3Niw1ICs2OTAsNSBAQA0K
IAkJCXJlcy0+cmVhZF9wcm9jID0gc2xhYmluZm9fcmVhZF9wcm9jOw0KIAkJ
CXJlcy0+d3JpdGVfcHJvYyA9IHNsYWJpbmZvX3dyaXRlX3Byb2M7DQogCQl9
DQotCX0NCisgCX0NCiB9DQpkaWZmIC11ck4gbGludXgtMi40LjAtdDctcDQt
dm0uYmFrL21tL3BhZ2VfYWxsb2MuYyBsaW51eC0yLjQuMC10Ny1wNC12bS9t
bS9wYWdlX2FsbG9jLmMNCi0tLSBsaW51eC0yLjQuMC10Ny1wNC12bS5iYWsv
bW0vcGFnZV9hbGxvYy5jCVRodSBBdWcgMTcgMDE6Mjk6MzcgMjAwMA0KKysr
IGxpbnV4LTIuNC4wLXQ3LXA0LXZtL21tL3BhZ2VfYWxsb2MuYwlUaHUgQXVn
IDE3IDAwOjE0OjMwIDIwMDANCkBAIC02NTksNiArNjU5LDcgQEANCiAJCQkJ
CXpvbmVsaXN0LT56b25lc1tqKytdID0gem9uZTsNCiAJCQkJfQ0KIAkJCWNh
c2UgWk9ORV9OT1JNQUw6DQorDQogCQkJCXpvbmUgPSBwZ2RhdC0+bm9kZV96
b25lcyArIFpPTkVfTk9STUFMOw0KIAkJCQlpZiAoem9uZS0+c2l6ZSkNCiAJ
CQkJCXpvbmVsaXN0LT56b25lc1tqKytdID0gem9uZTsNCkBAIC04MjgsNSAr
ODI5LDQwIEBADQogCXByaW50aygiXG4iKTsNCiAJcmV0dXJuIDE7DQogfQ0K
Kw0KKyNpZmRlZiBDT05GSUdfUFJPQ19GUw0KK2ludCBnZXRfem9uZWluZm8g
KGNoYXIqcGFnZSwgY2hhcioqc3RhcnQsIG9mZl90IG9mZiwgaW50IGNvdW50
KQ0KK3sNCisJcGdfZGF0YV90ICpwZ2RhdCA9IE5PREVfREFUQSgwKTsNCisJ
aW50IGksajsgdW5zaWduZWQgbG9uZyBmbGFnczsNCisJaW50IGxlbiA9IDA7
DQorDQorCWZvciAoaSA9IDA7IGkgPCBNQVhfTlJfWk9ORVM7IGkrKykgew0K
KwkJem9uZWxpc3RfdCAqem9uZWxpc3Q7DQorCQl6b25lX3QgKip6b25lOw0K
Kw0KKwkJem9uZWxpc3QgPSBwZ2RhdC0+bm9kZV96b25lbGlzdHMgKyBpOw0K
Kw0KKwkJem9uZSA9IHpvbmVsaXN0LT56b25lczsNCisJCWZvciAoaiA9IDA7
O2orKykgew0KKwkJCXpvbmVfdCAqeiA9ICooem9uZSsrKTsNCisJCQlpZiAo
IXopDQorCQkJCWJyZWFrOw0KKwkJCWlmICghei0+c2l6ZSkNCisJCQkJQlVH
KCk7DQorDQorCQkJc3Bpbl9sb2NrX2lycXNhdmUoJnotPmxvY2ssIGZsYWdz
KTsNCisJCQkNCisJCQlsZW4gKz0gc3ByaW50ZihwYWdlK2xlbiwgIiU0dSAl
NHUgJTZsdSAlNmx1ICU2bHUgJTZsdSAlNmx1ICU2bHUgJTZsdVxuIiwNCisJ
CQkJICAgICAgIGksaix6LT5vZmZzZXQsIHotPmZyZWVfcGFnZXMsIHotPmlu
YWN0aXZlX2NsZWFuX3BhZ2VzLA0KKwkJCQkgICAgICAgei0+aW5hY3RpdmVf
ZGlydHlfcGFnZXMsIHotPnBhZ2VzX21pbiwgei0+cGFnZXNfbG93LCB6LT5w
YWdlc19oaWdoKTsNCisNCisJCQlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZ6
LT5sb2NrLCBmbGFncyk7DQorCQl9DQorCX0NCisJKnN0YXJ0ID0gcGFnZStv
ZmY7DQorCXJldHVybiBsZW47DQorfQ0KKyNlbmRpZg0KIA0KIF9fc2V0dXAo
Im1lbWZyYWM9Iiwgc2V0dXBfbWVtX2ZyYWMpOw0K
--0-714346355-966465806=:7212--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
