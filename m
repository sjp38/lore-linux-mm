Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 992E06B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 13:37:03 -0400 (EDT)
Received: from mail-wy0-f169.google.com (mail-wy0-f169.google.com [74.125.82.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p5HHax9h011419
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 10:37:00 -0700
Received: by wyf19 with SMTP id 19so2524317wyf.14
        for <linux-mm@kvack.org>; Fri, 17 Jun 2011 10:36:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTin3onK+43LxODfbu-sdm-pFut0TKw@mail.gmail.com>
References: <1308097798.17300.142.camel@schen9-DESK> <1308101214.15392.151.camel@sli10-conroe>
 <1308138750.15315.62.camel@twins> <20110615161827.GA11769@tassilo.jf.intel.com>
 <1308156337.2171.23.camel@laptop> <1308163398.17300.147.camel@schen9-DESK>
 <1308169937.15315.88.camel@twins> <4DF91CB9.5080504@linux.intel.com>
 <1308172336.17300.177.camel@schen9-DESK> <1308173849.15315.91.camel@twins>
 <BANLkTim5TPKQ9RdLYRxy=mphOVKw5EXvTA@mail.gmail.com> <1308255972.17300.450.camel@schen9-DESK>
 <BANLkTinptaydNvK4ZvGvy0KVLnRmmza7tA@mail.gmail.com> <BANLkTi=GPtwjQ-bYDNUYCwzW5h--y86Law@mail.gmail.com>
 <BANLkTim-dBjva9w7AajqggKT3iUVYG2euQ@mail.gmail.com> <BANLkTimLV8aCZ7snXT_Do+f4vRY0EkoS4A@mail.gmail.com>
 <BANLkTinUBTYWxrF5TCuDSQuFUAyivXJXjQ@mail.gmail.com> <1308310080.2355.19.camel@twins>
 <BANLkTin3onK+43LxODfbu-sdm-pFut0TKw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 17 Jun 2011 10:28:26 -0700
Message-ID: <BANLkTik6pxMHpaMsD_LZPXfdrJgNNsuCFw@mail.gmail.com>
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
Content-Type: multipart/mixed; boundary=000e0cdfd88e931b0704a5ebba52
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

--000e0cdfd88e931b0704a5ebba52
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Jun 17, 2011 at 9:46 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Oh, and can you do this with a commit log and sign-off, and I'll put
> it in my "anon_vma-locking" branch that I have. I'm not going to
> actually merge that branch into mainline until I've seen a few more
> acks or more testing by Tim.

Attached is the tentative commit I have, which is yours but with the
tests for anon_vma being NULL removed, and a made-up commit log. It
works for me, but needs more testing and eyeballs looking at it.

Tim? This is on top of my previous patch, replacing Peter's two patches.

                                 Linus

--000e0cdfd88e931b0704a5ebba52
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gp1ewbxu0

Y29tbWl0IDMzZTRjNzVjZTZjMjNlOGE5ZmNiMzIyMTZjNGQ4NDNkNWU5YjQ5ZTIKQXV0aG9yOiBQ
ZXRlciBaaWpsc3RyYSA8cGV0ZXJ6QGluZnJhZGVhZC5vcmc+CkRhdGU6ICAgRnJpIEp1biAxNyAx
Mzo1NDoyMyAyMDExICswMjAwCgogICAgbW06IGF2b2lkIHJlcGVhdGVkIGFub25fdm1hIGxvY2sv
dW5sb2NrIHNlcXVlbmNlcyBpbiB1bmxpbmtfYW5vbl92bWFzKCkKICAgIAogICAgVGhpcyBtYXRj
aGVzIHRoZSBhbm9uX3ZtYV9jbG9uZSgpIGNhc2UsIGFuZCB1c2VzIHRoZSBzYW1lIGxvY2sgaGVs
cGVyCiAgICBmdW5jdGlvbnMuICBCZWNhdXNlIG9mIHRoZSBuZWVkIHRvIHBvdGVudGlhbGx5IHJl
bGVhc2UgdGhlIGFub25fdm1hJ3MsCiAgICBpdCdzIGEgYml0IG1vcmUgY29tcGxleCwgdGhvdWdo
LgogICAgCiAgICBXZSB0cmF2ZXJzZSB0aGUgJ3ZtYS0+YW5vbl92bWFfY2hhaW4nIGluIHR3byBw
aGFzZXM6IHRoZSBmaXJzdCBsb29wIGdldHMKICAgIHRoZSBhbm9uX3ZtYSBsb2NrICh3aXRoIHRo
ZSBoZWxwZXIgZnVuY3Rpb24gdGhhdCBvbmx5IHRha2VzIHRoZSBsb2NrCiAgICBvbmNlIGZvciB0
aGUgd2hvbGUgbG9vcCksIGFuZCByZW1vdmVzIGFueSBlbnRyaWVzIHRoYXQgZG9uJ3QgbmVlZCBh
bnkKICAgIG1vcmUgcHJvY2Vzc2luZy4KICAgIAogICAgVGhlIHNlY29uZCBwaGFzZSBqdXN0IHRy
YXZlcnNlcyB0aGUgcmVtYWluaW5nIGxpc3QgZW50cmllcyAod2l0aG91dAogICAgaG9sZGluZyB0
aGUgYW5vbl92bWEgbG9jayksIGFuZCBkb2VzIGFueSBhY3R1YWwgZnJlZWluZyBvZiB0aGUKICAg
IGFub25fdm1hJ3MgdGhhdCBpcyByZXF1aXJlZC4KICAgIAogICAgU2lnbmVkLW9mZi1ieTogTGlu
dXMgVG9ydmFsZHMgPHRvcnZhbGRzQGxpbnV4LWZvdW5kYXRpb24ub3JnPgotLS0KIG1tL3JtYXAu
YyB8ICAgNDkgKysrKysrKysrKysrKysrKysrKysrKysrKysrKy0tLS0tLS0tLS0tLS0tLS0tLS0t
LQogMSBmaWxlcyBjaGFuZ2VkLCAyOCBpbnNlcnRpb25zKCspLCAyMSBkZWxldGlvbnMoLSkKCmRp
ZmYgLS1naXQgYS9tbS9ybWFwLmMgYi9tbS9ybWFwLmMKaW5kZXggZjI4NjY5N2M2MWRjLi42ODc1
NmE3N2VmODcgMTAwNjQ0Ci0tLSBhL21tL3JtYXAuYworKysgYi9tbS9ybWFwLmMKQEAgLTMyNCwz
NiArMzI0LDQzIEBAIGludCBhbm9uX3ZtYV9mb3JrKHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1h
LCBzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnB2bWEpCiAJcmV0dXJuIC1FTk9NRU07CiB9CiAKLXN0
YXRpYyB2b2lkIGFub25fdm1hX3VubGluayhzdHJ1Y3QgYW5vbl92bWFfY2hhaW4gKmFub25fdm1h
X2NoYWluKQotewotCXN0cnVjdCBhbm9uX3ZtYSAqYW5vbl92bWEgPSBhbm9uX3ZtYV9jaGFpbi0+
YW5vbl92bWE7Ci0JaW50IGVtcHR5OwotCi0JLyogSWYgYW5vbl92bWFfZm9yayBmYWlscywgd2Ug
Y2FuIGdldCBhbiBlbXB0eSBhbm9uX3ZtYV9jaGFpbi4gKi8KLQlpZiAoIWFub25fdm1hKQotCQly
ZXR1cm47Ci0KLQlhbm9uX3ZtYV9sb2NrKGFub25fdm1hKTsKLQlsaXN0X2RlbCgmYW5vbl92bWFf
Y2hhaW4tPnNhbWVfYW5vbl92bWEpOwotCi0JLyogV2UgbXVzdCBnYXJiYWdlIGNvbGxlY3QgdGhl
IGFub25fdm1hIGlmIGl0J3MgZW1wdHkgKi8KLQllbXB0eSA9IGxpc3RfZW1wdHkoJmFub25fdm1h
LT5oZWFkKTsKLQlhbm9uX3ZtYV91bmxvY2soYW5vbl92bWEpOwotCi0JaWYgKGVtcHR5KQotCQlw
dXRfYW5vbl92bWEoYW5vbl92bWEpOwotfQotCiB2b2lkIHVubGlua19hbm9uX3ZtYXMoc3RydWN0
IHZtX2FyZWFfc3RydWN0ICp2bWEpCiB7CiAJc3RydWN0IGFub25fdm1hX2NoYWluICphdmMsICpu
ZXh0OworCXN0cnVjdCBhbm9uX3ZtYSAqcm9vdCA9IE5VTEw7CiAKIAkvKgogCSAqIFVubGluayBl
YWNoIGFub25fdm1hIGNoYWluZWQgdG8gdGhlIFZNQS4gIFRoaXMgbGlzdCBpcyBvcmRlcmVkCiAJ
ICogZnJvbSBuZXdlc3QgdG8gb2xkZXN0LCBlbnN1cmluZyB0aGUgcm9vdCBhbm9uX3ZtYSBnZXRz
IGZyZWVkIGxhc3QuCiAJICovCiAJbGlzdF9mb3JfZWFjaF9lbnRyeV9zYWZlKGF2YywgbmV4dCwg
JnZtYS0+YW5vbl92bWFfY2hhaW4sIHNhbWVfdm1hKSB7Ci0JCWFub25fdm1hX3VubGluayhhdmMp
OworCQlzdHJ1Y3QgYW5vbl92bWEgKmFub25fdm1hID0gYXZjLT5hbm9uX3ZtYTsKKworCQlyb290
ID0gbG9ja19hbm9uX3ZtYV9yb290KHJvb3QsIGFub25fdm1hKTsKKwkJbGlzdF9kZWwoJmF2Yy0+
c2FtZV9hbm9uX3ZtYSk7CisKKwkJLyoKKwkJICogTGVhdmUgZW1wdHkgYW5vbl92bWFzIG9uIHRo
ZSBsaXN0IC0gd2UnbGwgbmVlZAorCQkgKiB0byBmcmVlIHRoZW0gb3V0c2lkZSB0aGUgbG9jay4K
KwkJICovCisJCWlmIChsaXN0X2VtcHR5KCZhbm9uX3ZtYS0+aGVhZCkpCisJCQljb250aW51ZTsK
KworCQlsaXN0X2RlbCgmYXZjLT5zYW1lX3ZtYSk7CisJCWFub25fdm1hX2NoYWluX2ZyZWUoYXZj
KTsKKwl9CisJdW5sb2NrX2Fub25fdm1hX3Jvb3Qocm9vdCk7CisKKwkvKgorCSAqIEl0ZXJhdGUg
dGhlIGxpc3Qgb25jZSBtb3JlLCBpdCBub3cgb25seSBjb250YWlucyBlbXB0eSBhbmQgdW5saW5r
ZWQKKwkgKiBhbm9uX3ZtYXMsIGRlc3Ryb3kgdGhlbS4gQ291bGQgbm90IGRvIGJlZm9yZSBkdWUg
dG8gX19wdXRfYW5vbl92bWEoKQorCSAqIG5lZWRpbmcgdG8gYWNxdWlyZSB0aGUgYW5vbl92bWEt
PnJvb3QtPm11dGV4LgorCSAqLworCWxpc3RfZm9yX2VhY2hfZW50cnlfc2FmZShhdmMsIG5leHQs
ICZ2bWEtPmFub25fdm1hX2NoYWluLCBzYW1lX3ZtYSkgeworCQlzdHJ1Y3QgYW5vbl92bWEgKmFu
b25fdm1hID0gYXZjLT5hbm9uX3ZtYTsKKworCQlwdXRfYW5vbl92bWEoYW5vbl92bWEpOworCiAJ
CWxpc3RfZGVsKCZhdmMtPnNhbWVfdm1hKTsKIAkJYW5vbl92bWFfY2hhaW5fZnJlZShhdmMpOwog
CX0K
--000e0cdfd88e931b0704a5ebba52--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
