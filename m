Date: Sun, 16 Sep 2001 13:28:37 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH RFC] higher order allocs 2.4.10-pre9-recycle-R1
In-Reply-To: <200109152258.f8FMwbK05717@mailc.telia.com>
Message-ID: <Pine.LNX.4.33L.0109161327530.9536-200000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY="------------Boundary-00=_SL7Q3LNNXPI9XTFDQQRQ"
Content-ID: <Pine.LNX.4.33L.0109161327531.9536@imladris.rielhome.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: Stephan von Krawczynski <skraw@ithnet.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--------------Boundary-00=_SL7Q3LNNXPI9XTFDQQRQ
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.33L.0109161327532.9536@imladris.rielhome.conectiva>

On Sun, 16 Sep 2001, Roger Larsson wrote:

> I have made some test runs - results are close to proper 2.4.10-pre9
> actually slightly better for all but two of mine testcases.
> diff of two files bigger than RAM got half throughput, why???
> mmap002 (use all memory attempt) took more than three times as long -
> less memory to use at once, OK. And not necessarily a bad thing.

These "test runs" are completely unrelated to memory fragmentation.
I don't know what you're thinking, but you could at least test the
thing you're trying to fix ...

regards,

Rik
-- 
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--------------Boundary-00=_SL7Q3LNNXPI9XTFDQQRQ
Content-Type: TEXT/X-DIFF; CHARSET=iso-8859-1; NAME="patch-2.4.10-pre9-recycle-R1"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.33L.0109161327533.9536@imladris.rielhome.conectiva>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME="patch-2.4.10-pre9-recycle-R1"

KioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKgpQYXRjaCBwcmVwYXJl
ZCBieTogcm9nZXIubGFyc3NvbkBub3JyYW4ubmV0Ck5hbWUgb2YgZmlsZTogL2hvbWUvcm9nZXIv
cGF0Y2hlcy9wYXRjaC0yLjQuMTAtcHJlOS1yZWN5Y2xlLVIxCgotLS0gbGludXgvbW0vcGFnZV9h
bGxvYy5jLm9yaWcJU2F0IFNlcCAxNSAxNzozMDozMiAyMDAxCisrKyBsaW51eC9tbS9wYWdlX2Fs
bG9jLmMJU3VuIFNlcCAxNiAwMDowMToyNCAyMDAxCkBAIC0xMDQsNyArMTA0LDEyIEBACiAKIAlz
cGluX2xvY2tfaXJxc2F2ZSgmem9uZS0+bG9jaywgZmxhZ3MpOwogCi0Jem9uZS0+ZnJlZV9wYWdl
cyAtPSBtYXNrOworCWFyZWEtPnJlY3ljbGVkKys7CisJaWYgKGFyZWEtPnJlY3ljbGVkIDw9IDAp
CisJCWFyZWEtPnJlY3ljbGVkPTE7CisKKwlpZiAoIW9yZGVyIHx8IGFyZWEtPnJlY3ljbGVkIDwg
MCkKKwkJem9uZS0+ZnJlZV9wYWdlcyAtPSBtYXNrOwogCiAJd2hpbGUgKG1hc2sgKyAoMSA8PCAo
TUFYX09SREVSLTEpKSkgewogCQlzdHJ1Y3QgcGFnZSAqYnVkZHkxLCAqYnVkZHkyOwpAQCAtMTkz
LDkgKzE5OCwxNCBAQAogCQkJaW5kZXggPSBwYWdlIC0gem9uZS0+em9uZV9tZW1fbWFwOwogCQkJ
aWYgKGN1cnJfb3JkZXIgIT0gTUFYX09SREVSLTEpCiAJCQkJTUFSS19VU0VEKGluZGV4LCBjdXJy
X29yZGVyLCBhcmVhKTsKLQkJCXpvbmUtPmZyZWVfcGFnZXMgLT0gMSA8PCBvcmRlcjsKIAogCQkJ
cGFnZSA9IGV4cGFuZCh6b25lLCBwYWdlLCBpbmRleCwgb3JkZXIsIGN1cnJfb3JkZXIsIGFyZWEp
OworCQkJLyogdXNlIGluaXRpYWwgYXJlYSwgcmVxdWVzdGVkIG9yZGVyICovCisJCQlhcmVhPXpv
bmUtPmZyZWVfYXJlYSArIG9yZGVyOworCQkJYXJlYS0+cmVjeWNsZWQtLTsgLyogbWlnaHQgZ28g
bmVnLCBmaXhlZCBpbiBmcmVlICovCisJCQlpZiAoIW9yZGVyIHx8IGFyZWEtPnJlY3ljbGVkIDwg
MCkKKwkJCQl6b25lLT5mcmVlX3BhZ2VzIC09IDEgPDwgb3JkZXI7CisKIAkJCXNwaW5fdW5sb2Nr
X2lycXJlc3RvcmUoJnpvbmUtPmxvY2ssIGZsYWdzKTsKIAogCQkJc2V0X3BhZ2VfY291bnQocGFn
ZSwgMSk7CkBAIC02NTMsNyArNjYzLDggQEAKIAkJaWYgKHpvbmUtPnNpemUpIHsKIAkJCXNwaW5f
bG9ja19pcnFzYXZlKCZ6b25lLT5sb2NrLCBmbGFncyk7CiAJCSAJZm9yIChvcmRlciA9IDA7IG9y
ZGVyIDwgTUFYX09SREVSOyBvcmRlcisrKSB7Ci0JCQkJaGVhZCA9ICYoem9uZS0+ZnJlZV9hcmVh
ICsgb3JkZXIpLT5mcmVlX2xpc3Q7CisJCQkJZnJlZV9hcmVhX3QgKmFyZWEgPSB6b25lLT5mcmVl
X2FyZWEgKyBvcmRlcjsKKwkJCQloZWFkID0gJmFyZWEtPmZyZWVfbGlzdDsKIAkJCQljdXJyID0g
aGVhZDsKIAkJCQluciA9IDA7CiAJCQkJZm9yICg7OykgewpAQCAtNjYzLDggKzY3NCw5IEBACiAJ
CQkJCW5yKys7CiAJCQkJfQogCQkJCXRvdGFsICs9IG5yICogKDEgPDwgb3JkZXIpOwotCQkJCXBy
aW50aygiJWx1KiVsdWtCICIsIG5yLAotCQkJCQkJKFBBR0VfU0laRT4+MTApIDw8IG9yZGVyKTsK
KwkJCQlwcmludGsoIiVsdS8lbGQqJWx1a0IgIiwgbnIsCisJCQkJICAgICAgIGFyZWEtPnJlY3lj
bGVkLAorCQkJCSAgICAgICAoUEFHRV9TSVpFPj4xMCkgPDwgb3JkZXIpOwogCQkJfQogCQkJc3Bp
bl91bmxvY2tfaXJxcmVzdG9yZSgmem9uZS0+bG9jaywgZmxhZ3MpOwogCQl9CkBAIC04OTEsNiAr
OTAzLDcgQEAKIAkJCWJpdG1hcF9zaXplID0gTE9OR19BTElHTihiaXRtYXBfc2l6ZSsxKTsKIAkJ
CXpvbmUtPmZyZWVfYXJlYVtpXS5tYXAgPSAKIAkJCSAgKHVuc2lnbmVkIGxvbmcgKikgYWxsb2Nf
Ym9vdG1lbV9ub2RlKHBnZGF0LCBiaXRtYXBfc2l6ZSk7CisJCQl6b25lLT5mcmVlX2FyZWFbaV0u
cmVjeWNsZWQgPSAwOwogCQl9CiAJfQogCWJ1aWxkX3pvbmVsaXN0cyhwZ2RhdCk7Ci0tLSBsaW51
eC9pbmNsdWRlL2xpbnV4L21tem9uZS5oLm9yaWcJU2F0IFNlcCAxNSAyMTo1ODo0NyAyMDAxCisr
KyBsaW51eC9pbmNsdWRlL2xpbnV4L21tem9uZS5oCVNhdCBTZXAgMTUgMjI6MDE6MjkgMjAwMQpA
QCAtMjEsNiArMjEsNyBAQAogdHlwZWRlZiBzdHJ1Y3QgZnJlZV9hcmVhX3N0cnVjdCB7CiAJc3Ry
dWN0IGxpc3RfaGVhZAlmcmVlX2xpc3Q7CiAJdW5zaWduZWQgbG9uZwkJKm1hcDsKKwlsb25nICAg
ICAgICAgICAgICAgICAgICByZWN5Y2xlZDsKIH0gZnJlZV9hcmVhX3Q7CiAKIHN0cnVjdCBwZ2xp
c3RfZGF0YTsK

--------------Boundary-00=_SL7Q3LNNXPI9XTFDQQRQ--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
