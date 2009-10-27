Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0AE0D6B0044
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 14:02:41 -0400 (EDT)
Received: by iwn34 with SMTP id 34so313513iwn.12
        for <linux-mm@kvack.org>; Tue, 27 Oct 2009 11:02:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4AE72A0D.9070804@gmail.com>
References: <hav57c$rso$1@ger.gmane.org>
	 <20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com>
	 <hb2cfu$r08$2@ger.gmane.org>
	 <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com>
	 <4ADE3121.6090407@gmail.com>
	 <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com>
	 <4AE5CB4E.4090504@gmail.com>
	 <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
	 <4AE72A0D.9070804@gmail.com>
Date: Wed, 28 Oct 2009 03:02:39 +0900
Message-ID: <2f11576a0910271102g60dcdd1dj8f3df213bc64a51d@mail.gmail.com>
Subject: Re: Memory overcommit
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: multipart/mixed; boundary=0016e6460848e5c3860476ee7b40
Sender: owner-linux-mm@kvack.org
To: vedran.furac@gmail.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hugh.dickins@tiscali.co.uk, akpm@linux-foundation.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

--0016e6460848e5c3860476ee7b40
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

>> I attached a scirpt for checking oom_score of all exisiting process.
>> (oom_score is a value used for selecting "bad" processs.")
>> please run if you have time.
>
> 96890 =A0 21463 =A0 VirtualBox // OK
> 118615 =A011144 =A0 kded4 // WRONG
> 127455 =A011158 =A0 knotify4 // WRONG
> 132198 =A01 =A0 =A0 =A0 init // WRONG
> 133940 =A011151 =A0 ksmserver // WRONG
> 134109 =A011224 =A0 audacious2 // Audio player, maybe
> 145476 =A021503 =A0 VirtualBox // OK
> 174939 =A011322 =A0 icedove-bin // thunderbird, maybe
> 178015 =A011223 =A0 akregator // rss reader, maybe
> 201043 =A022672 =A0 krusader =A0// WRONG
> 212609 =A011187 =A0 krunner // WRONG
> 256911 =A024252 =A0 test // culprit, malloced 1GB
> 1750371 11318 =A0 run-mozilla.sh // tiny, parent of firefox threads
> 2044902 11141 =A0 kdeinit4 // tiny, parent of most KDE apps

Verdran, I made alternative improvement idea. Can you please mesure
badness score
on your system?
Maybe your culprit process take biggest badness value.

Note: this patch change time related thing. So, please drink a cup of
coffee before mesurement.
small rest time makes correct test result.

--0016e6460848e5c3860476ee7b40
Content-Type: application/octet-stream;
	name="0001-oom-oom-score-bonus-by-run_time-use-proportional-va.patch"
Content-Disposition: attachment;
	filename="0001-oom-oom-score-bonus-by-run_time-use-proportional-va.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g1ayn0fk0

RnJvbSAwNDdlNjY0N2Y1ODBhN2M5YmVkMmFjNTQ3YmM5YjE1MTU0ZDVkYTRjIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBLT1NBS0kgTW90b2hpcm8gPGtvc2FraS5tb3RvaGlyb0BqcC5m
dWppdHN1LmNvbT4KRGF0ZTogV2VkLCAyOCBPY3QgMjAwOSAwMjoyNTowMSArMDkwMApTdWJqZWN0
OiBbUEFUQ0hdIG9vbTogb29tLXNjb3JlIGJvbnVzIGJ5IHJ1bl90aW1lIHVzZSBwcm9wb3J0aW9u
YWwgdmFsdWUKCkN1cnJlbnRseSwgb29tLXNjb3JlIGJvbnVzIGJ5IHJ1bl90aW1lIHVzZSB0aGUg
Zm9tdWxhIG9mICJzcXJ0KHNxcnQocnVudGltZSAvIDEwMjQpKSkiLgpJdCBtZWFuIHByb2Nlc3Mg
Z290IDEvMyB0aW1lcyBvb20tc2NvcmUgcGVyIGRheS4gVGhpcyBmZWF0dXJlIGV4aXN0IGZvciBw
cm90ZWN0IHNldmFyYWwKaW1wb3J0YW50IHN5c3RlbSBkYWVtb24uCgpIb3dldmVyLCB0eXBpY2Fs
IGRlc2t0b3AgdXNlciByZWJvb3QgdGhlIHN5c3RlbSBldmVyeWRheS4gdGhlbiBpdHMgYm9udXMg
aXMgdG9vIHNtYWxsLgpUaGlzIGJvbnVzIG9ubHkgd29ya3Mgd2VsbCBvbiBzZXJ2ZXIgc3lzdGVt
cy4gSU9XIHR5cGljYWwgdXB0aW1lIHN0cm9uZ2x5IGRlcGVuZCBvbgp1c2UtY2FzZS4gaXQgc2hv
dWxkbid0IHVzZSBmb3Igb29tIG1vZGlmaWVyLgoKSW5zdGVhZCwgVGhpcyBwYXRjaCB1c2UgcHJv
cG9ydGlvbmFsIHJ1bl90aW1lIHZhbHVlIGFnYWluc3QgdXB0aW1lLgoKU2lnbmVkLW9mZi1ieTog
S09TQUtJIE1vdG9oaXJvIDxrb3Nha2kubW90b2hpcm9AanAuZnVqaXRzdS5jb20+Ci0tLQogZnMv
cHJvYy9iYXNlLmMgfCAgICAxICsKIG1tL29vbV9raWxsLmMgIHwgICAyNiArKysrKysrKysrKysr
KystLS0tLS0tLS0tLQogMiBmaWxlcyBjaGFuZ2VkLCAxNiBpbnNlcnRpb25zKCspLCAxMSBkZWxl
dGlvbnMoLSkKCmRpZmYgLS1naXQgYS9mcy9wcm9jL2Jhc2UuYyBiL2ZzL3Byb2MvYmFzZS5jCmlu
ZGV4IDgzNzQ2OWEuLjE3ZDZmZDQgMTAwNjQ0Ci0tLSBhL2ZzL3Byb2MvYmFzZS5jCisrKyBiL2Zz
L3Byb2MvYmFzZS5jCkBAIC00NDYsNiArNDQ2LDcgQEAgc3RhdGljIGludCBwcm9jX29vbV9zY29y
ZShzdHJ1Y3QgdGFza19zdHJ1Y3QgKnRhc2ssIGNoYXIgKmJ1ZmZlcikKIAlzdHJ1Y3QgdGltZXNw
ZWMgdXB0aW1lOwogCiAJZG9fcG9zaXhfY2xvY2tfbW9ub3RvbmljX2dldHRpbWUoJnVwdGltZSk7
CisJbW9ub3RvbmljX3RvX2Jvb3RiYXNlZCgmdXB0aW1lKTsKIAlyZWFkX2xvY2soJnRhc2tsaXN0
X2xvY2spOwogCXBvaW50cyA9IGJhZG5lc3ModGFzay0+Z3JvdXBfbGVhZGVyLCB1cHRpbWUudHZf
c2VjKTsKIAlyZWFkX3VubG9jaygmdGFza2xpc3RfbG9jayk7CmRpZmYgLS1naXQgYS9tbS9vb21f
a2lsbC5jIGIvbW0vb29tX2tpbGwuYwppbmRleCBlYTIxNDdkLi4zYzFiM2EzIDEwMDY0NAotLS0g
YS9tbS9vb21fa2lsbC5jCisrKyBiL21tL29vbV9raWxsLmMKQEAgLTY5LDEwICs2OSwxMCBAQCBz
dGF0aWMgaW50IGhhc19pbnRlcnNlY3RzX21lbXNfYWxsb3dlZChzdHJ1Y3QgdGFza19zdHJ1Y3Qg
KnRzaykKICAqICAgIGFsZ29yaXRobSBoYXMgYmVlbiBtZXRpY3Vsb3VzbHkgdHVuZWQgdG8gbWVl
dCB0aGUgcHJpbmNpcGxlCiAgKiAgICBvZiBsZWFzdCBzdXJwcmlzZSAuLi4gKGJlIGNhcmVmdWwg
d2hlbiB5b3UgY2hhbmdlIGl0KQogICovCi0KIHVuc2lnbmVkIGxvbmcgYmFkbmVzcyhzdHJ1Y3Qg
dGFza19zdHJ1Y3QgKnAsIHVuc2lnbmVkIGxvbmcgdXB0aW1lKQogewotCXVuc2lnbmVkIGxvbmcg
cG9pbnRzLCBjcHVfdGltZSwgcnVuX3RpbWU7CisJdW5zaWduZWQgbG9uZyBwb2ludHMsIGNwdV90
aW1lOworCXVuc2lnbmVkIGxvbmcgcnVuX3RpbWUgPSAwOwogCXN0cnVjdCBtbV9zdHJ1Y3QgKm1t
OwogCXN0cnVjdCB0YXNrX3N0cnVjdCAqY2hpbGQ7CiAJaW50IG9vbV9hZGogPSBwLT5zaWduYWwt
Pm9vbV9hZGo7CkBAIC0xMzAsMTcgKzEzMCwyMCBAQCB1bnNpZ25lZCBsb25nIGJhZG5lc3Moc3Ry
dWN0IHRhc2tfc3RydWN0ICpwLCB1bnNpZ25lZCBsb25nIHVwdGltZSkKIAl1dGltZSA9IGNwdXRp
bWVfdG9famlmZmllcyh0YXNrX3RpbWUudXRpbWUpOwogCXN0aW1lID0gY3B1dGltZV90b19qaWZm
aWVzKHRhc2tfdGltZS5zdGltZSk7CiAJY3B1X3RpbWUgPSAodXRpbWUgKyBzdGltZSkgPj4gKFNI
SUZUX0haICsgMyk7Ci0KLQotCWlmICh1cHRpbWUgPj0gcC0+c3RhcnRfdGltZS50dl9zZWMpCi0J
CXJ1bl90aW1lID0gKHVwdGltZSAtIHAtPnN0YXJ0X3RpbWUudHZfc2VjKSA+PiAxMDsKLQllbHNl
Ci0JCXJ1bl90aW1lID0gMDsKLQogCWlmIChjcHVfdGltZSkKIAkJcG9pbnRzIC89IGludF9zcXJ0
KGNwdV90aW1lKTsKLQlpZiAocnVuX3RpbWUpCi0JCXBvaW50cyAvPSBpbnRfc3FydChpbnRfc3Fy
dChydW5fdGltZSkpOworCisJaWYgKHVwdGltZSA8PSBwLT5yZWFsX3N0YXJ0X3RpbWUudHZfc2Vj
KSB7CisJCS8qIEJhYnkgcHJvY2VzcyBtYXkgYmUgbm90IHNvIGltcG9ydGFudC4gKi8KKwkJcG9p
bnRzICo9IDI7CisJfSBlbHNlIHsKKwkJcnVuX3RpbWUgPSAodXB0aW1lIC0gcC0+cmVhbF9zdGFy
dF90aW1lLnR2X3NlYyk7CisJCWlmICghcnVuX3RpbWUpCisJCQlydW5fdGltZSA9IDE7CisKKwkJ
cnVuX3RpbWUgPSAoKHJ1bl90aW1lICogMTAwKSAvIHVwdGltZSkgKyAxOworCQlwb2ludHMgLz0g
aW50X3NxcnQocnVuX3RpbWUpOworCX0KIAogCS8qCiAJICogTmljZWQgcHJvY2Vzc2VzIGFyZSBt
b3N0IGxpa2VseSBsZXNzIGltcG9ydGFudCwgc28gZG91YmxlCkBAIC0yMzMsNiArMjM2LDcgQEAg
c3RhdGljIHN0cnVjdCB0YXNrX3N0cnVjdCAqc2VsZWN0X2JhZF9wcm9jZXNzKHVuc2lnbmVkIGxv
bmcgKnBwb2ludHMsCiAJKnBwb2ludHMgPSAwOwogCiAJZG9fcG9zaXhfY2xvY2tfbW9ub3Rvbmlj
X2dldHRpbWUoJnVwdGltZSk7CisJbW9ub3RvbmljX3RvX2Jvb3RiYXNlZCgmdXB0aW1lKTsKIAlm
b3JfZWFjaF9wcm9jZXNzKHApIHsKIAkJdW5zaWduZWQgbG9uZyBwb2ludHM7CiAKLS0gCjEuNi4y
LjUKCg==
--0016e6460848e5c3860476ee7b40--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
