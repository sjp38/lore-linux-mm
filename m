Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 315678D003B
	for <linux-mm@kvack.org>; Sat, 26 Mar 2011 21:29:20 -0400 (EDT)
Date: Sat, 26 Mar 2011 20:29:14 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Disable the lockless allocator
In-Reply-To: <AANLkTinTzKQkRcE2JvP_BpR0YMj82gppAmNo7RqgftCG@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1103262028170.1004@router.home>
References: <alpine.DEB.2.00.1103221635400.4521@tiger> <20110324142146.GA11682@elte.hu> <alpine.DEB.2.00.1103240940570.32226@router.home> <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com> <20110324172653.GA28507@elte.hu> <20110324185258.GA28370@elte.hu>
 <alpine.LFD.2.00.1103242005530.31464@localhost6.localdomain6> <20110324192247.GA5477@elte.hu> <AANLkTinBwM9egao496WnaNLAPUxhMyJmkusmxt+ARtnV@mail.gmail.com> <20110326112725.GA28612@elte.hu> <20110326114736.GA8251@elte.hu> <1301161507.2979.105.camel@edumazet-laptop>
 <alpine.DEB.2.00.1103261406420.24195@router.home> <alpine.DEB.2.00.1103261428200.25375@router.home> <alpine.DEB.2.00.1103261440160.25375@router.home> <AANLkTinTzKQkRcE2JvP_BpR0YMj82gppAmNo7RqgftCG@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY=0015177407b69c6eb6049f6a184f
Content-ID: <alpine.DEB.2.00.1103262028171.1004@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0015177407b69c6eb6049f6a184f
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.00.1103262028172.1004@router.home>

On Sat, 26 Mar 2011, Linus Torvalds wrote:

> Wouldn't something like the attached be better?

On first glance I cannot find fault with it.
--0015177407b69c6eb6049f6a184f
Content-Type: TEXT/X-PATCH; CHARSET=US-ASCII; NAME=patch.diff
Content-Transfer-Encoding: BASE64
Content-ID: <alpine.DEB.2.00.1103262028173.1004@router.home>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME=patch.diff

IGFyY2gveDg2L2luY2x1ZGUvYXNtL3BlcmNwdS5oIHwgICAxMCArKysrKystLS0tCiAxIGZpbGVz
IGNoYW5nZWQsIDYgaW5zZXJ0aW9ucygrKSwgNCBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9h
cmNoL3g4Ni9pbmNsdWRlL2FzbS9wZXJjcHUuaCBiL2FyY2gveDg2L2luY2x1ZGUvYXNtL3BlcmNw
dS5oCmluZGV4IGEwOWUxZjAuLmQ0NzViNDMgMTAwNjQ0Ci0tLSBhL2FyY2gveDg2L2luY2x1ZGUv
YXNtL3BlcmNwdS5oCisrKyBiL2FyY2gveDg2L2luY2x1ZGUvYXNtL3BlcmNwdS5oCkBAIC00NSw3
ICs0NSw3IEBACiAjaW5jbHVkZSA8bGludXgvc3RyaW5naWZ5Lmg+CiAKICNpZmRlZiBDT05GSUdf
U01QCi0jZGVmaW5lIF9fcGVyY3B1X2FyZyh4KQkJIiUlIl9fc3RyaW5naWZ5KF9fcGVyY3B1X3Nl
ZykiOiVQIiAjeAorI2RlZmluZSBfX3BlcmNwdV9wcmVmaXgJCSIlJSJfX3N0cmluZ2lmeShfX3Bl
cmNwdV9zZWcpIjoiCiAjZGVmaW5lIF9fbXlfY3B1X29mZnNldAkJcGVyY3B1X3JlYWQodGhpc19j
cHVfb2ZmKQogCiAvKgpAQCAtNjIsOSArNjIsMTEgQEAKIAkodHlwZW9mKCoocHRyKSkgX19rZXJu
ZWwgX19mb3JjZSAqKXRjcF9wdHJfXzsJXAogfSkKICNlbHNlCi0jZGVmaW5lIF9fcGVyY3B1X2Fy
Zyh4KQkJIiVQIiAjeAorI2RlZmluZSBfX3BlcmNwdV9wcmVmaXgJCSIiCiAjZW5kaWYKIAorI2Rl
ZmluZSBfX3BlcmNwdV9hcmcoeCkJCV9fcGVyY3B1X3ByZWZpeCAiJVAiICN4CisKIC8qCiAgKiBJ
bml0aWFsaXplZCBwb2ludGVycyB0byBwZXItY3B1IHZhcmlhYmxlcyBuZWVkZWQgZm9yIHRoZSBi
b290CiAgKiBwcm9jZXNzb3IgbmVlZCB0byB1c2UgdGhlc2UgbWFjcm9zIHRvIGdldCB0aGUgcHJv
cGVyIGFkZHJlc3MKQEAgLTUxNiwxMSArNTE4LDExIEBAIGRvIHsJCQkJCQkJCQlcCiAJdHlwZW9m
KG8yKSBfX24yID0gbjI7CQkJCQkJXAogCXR5cGVvZihvMikgX19kdW1teTsJCQkJCQlcCiAJYWx0
ZXJuYXRpdmVfaW8oImNhbGwgdGhpc19jcHVfY21weGNoZzE2Yl9lbXVcblx0IiBQNl9OT1A0LAlc
Ci0JCSAgICAgICAiY21weGNoZzE2YiAlJWdzOiglJXJzaSlcblx0c2V0eiAlMFxuXHQiLAlcCisJ
CSAgICAgICAiY21weGNoZzE2YiAiIF9fcGVyY3B1X3ByZWZpeCAiKCUlcnNpKVxuXHRzZXR6ICUw
XG5cdCIsCVwKIAkJICAgICAgIFg4Nl9GRUFUVVJFX0NYMTYsCQkJCVwKIAkJICAgICAgIEFTTV9P
VVRQVVQyKCI9YSIoX19yZXQpLCAiPWQiKF9fZHVtbXkpKSwJCVwKIAkJICAgICAgICJTIiAoJnBj
cDEpLCAiYiIoX19uMSksICJjIihfX24yKSwJCVwKLQkJICAgICAgICJhIihfX28xKSwgImQiKF9f
bzIpKTsJCQkJXAorCQkgICAgICAgImEiKF9fbzEpLCAiZCIoX19vMikgOiAibWVtb3J5Iik7CQlc
CiAJX19yZXQ7CQkJCQkJCQlcCiB9KQogCg==
--0015177407b69c6eb6049f6a184f--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
