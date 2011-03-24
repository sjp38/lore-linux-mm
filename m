Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DC8978D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 12:51:09 -0400 (EDT)
Received: by yws5 with SMTP id 5so89559yws.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 09:50:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1103240940570.32226@router.home>
References: <alpine.DEB.2.00.1103221635400.4521@tiger>
	<20110324142146.GA11682@elte.hu>
	<alpine.DEB.2.00.1103240940570.32226@router.home>
Date: Thu, 24 Mar 2011 18:50:57 +0200
Message-ID: <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
From: Pekka Enberg <penberg@kernel.org>
Content-Type: multipart/mixed; boundary=001636eee22b130adf049f3d489a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Ingo Molnar <mingo@elte.hu>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--001636eee22b130adf049f3d489a
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 24, 2011 at 4:41 PM, Christoph Lameter <cl@linux.com> wrote:
> On Thu, 24 Mar 2011, Ingo Molnar wrote:
>
>> FYI, some sort of boot crash has snuck upstream in the last 24 hours:
>>
>> =A0BUG: unable to handle kernel paging request at ffff87ffc147e020
>> =A0IP: [<ffffffff811aa762>] this_cpu_cmpxchg16b_emu+0x2/0x1c
>
> Hmmm.. This is the fallback code for the case that the processor does not
> support cmpxchg16b.

How does alternative_io() work? Does it require
alternative_instructions() to be executed. If so, the fallback code
won't be active when we enter kmem_cache_init(). Is there any reason
check_bugs() is called so late during boot? Can we do something like
the totally untested attached patch?

--001636eee22b130adf049f3d489a
Content-Type: application/octet-stream; name="check-bugs.patch"
Content-Disposition: attachment; filename="check-bugs.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_glnx4au21

ZGlmZiAtLWdpdCBhL2luaXQvbWFpbi5jIGIvaW5pdC9tYWluLmMKaW5kZXggNGE5NDc5ZS4uZTU3
ZDZhNyAxMDA2NDQKLS0tIGEvaW5pdC9tYWluLmMKKysrIGIvaW5pdC9tYWluLmMKQEAgLTUwOCw2
ICs1MDgsNyBAQCBhc21saW5rYWdlIHZvaWQgX19pbml0IHN0YXJ0X2tlcm5lbCh2b2lkKQogCXZm
c19jYWNoZXNfaW5pdF9lYXJseSgpOwogCXNvcnRfbWFpbl9leHRhYmxlKCk7CiAJdHJhcF9pbml0
KCk7CisJY2hlY2tfYnVncygpOwogCW1tX2luaXQoKTsKIAkvKgogCSAqIFNldCB1cCB0aGUgc2No
ZWR1bGVyIHByaW9yIHN0YXJ0aW5nIGFueSBpbnRlcnJ1cHRzIChzdWNoIGFzIHRoZQpAQCAtNjE0
LDggKzYxNSw2IEBAIGFzbWxpbmthZ2Ugdm9pZCBfX2luaXQgc3RhcnRfa2VybmVsKHZvaWQpCiAJ
dGFza3N0YXRzX2luaXRfZWFybHkoKTsKIAlkZWxheWFjY3RfaW5pdCgpOwogCi0JY2hlY2tfYnVn
cygpOwotCiAJYWNwaV9lYXJseV9pbml0KCk7IC8qIGJlZm9yZSBMQVBJQyBhbmQgU01QIGluaXQg
Ki8KIAlzZmlfaW5pdF9sYXRlKCk7CiAK
--001636eee22b130adf049f3d489a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
