Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D168A8D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 23:39:01 -0500 (EST)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p1I4cTEZ002109
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 20:38:29 -0800
Received: by iwc10 with SMTP id 10so3263025iwc.14
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 20:38:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTimzP0UNRXutkt1zJ+OGhmeg6ga87HFyMuZQmpMj@mail.gmail.com>
References: <20110216185234.GA11636@tiehlicka.suse.cz> <20110216193700.GA6377@elte.hu>
 <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
 <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
 <20110217090910.GA3781@tiehlicka.suse.cz> <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
 <20110217163531.GF14168@elte.hu> <m1pqqqfpzh.fsf@fess.ebiederm.org>
 <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
 <m1sjvm822m.fsf@fess.ebiederm.org> <AANLkTimzP0UNRXutkt1zJ+OGhmeg6ga87HFyMuZQmpMj@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 17 Feb 2011 20:38:09 -0800
Message-ID: <AANLkTi=kEEip7UjtLqvo0Hpz8uwjVdx334hYnPsoNXis@mail.gmail.com>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in 2.6.38-rc4
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Ingo Molnar <mingo@elte.hu>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, Octavian Purdila <opurdila@ixiacom.com>, David Miller <davem@davemloft.net>

On Thu, Feb 17, 2011 at 8:30 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> The patch from Eric Dumazet (which adds a few more cases to my patch
> and hopefully catches them all) almost certainly fixes this rather
> nasty memory corruption.

Oh, but you weren't cc'd on that part of the thread, since the thread
got started from Michal Hocko's similar trouble. So you may have never
even noticed that patch, or my "improved LIST_DEBUG" patch in the same
thread)

You can find Eric Dumazet's patch on lkml (see the background at

  http://lkml.org/lkml/2011/2/17/267

and you'll see Dumazet's reply and my improved list debugging too).

Eric Dumazet: have you made any other changes to that patch? Or should
Eric (too many Eric's in this thread ;) just test the patch you
posted?

                          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
