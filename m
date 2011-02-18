Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B497A8D0039
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 11:39:53 -0500 (EST)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p1IGdN1f032452
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 18 Feb 2011 08:39:23 -0800
Received: by iwl42 with SMTP id 42so502110iwl.14
        for <linux-mm@kvack.org>; Fri, 18 Feb 2011 08:39:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110218162623.GD4862@tiehlicka.suse.cz>
References: <20110216185234.GA11636@tiehlicka.suse.cz> <20110216193700.GA6377@elte.hu>
 <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
 <AANLkTi=xnbcs5BKj3cNE_aLtBO7W5m+2uaUacu7M8g_S@mail.gmail.com>
 <20110217090910.GA3781@tiehlicka.suse.cz> <AANLkTikPKpNHxDQAYBd3fiQsmVozLtCVDsNn=+eF_q2r@mail.gmail.com>
 <20110217163531.GF14168@elte.hu> <m1pqqqfpzh.fsf@fess.ebiederm.org>
 <AANLkTinB=EgDGNv-v-qD-MvHVAmstfP_CyyLNhhotkZx@mail.gmail.com>
 <20110218122938.GB26779@tiehlicka.suse.cz> <20110218162623.GD4862@tiehlicka.suse.cz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 18 Feb 2011 08:39:02 -0800
Message-ID: <AANLkTimO=M5xG_mnDBSxPKwSOTrp3JhHVBa8=wHsiVHY@mail.gmail.com>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in 2.6.38-rc4
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Eric Dumazet <eric.dumazet@gmail.com>

On Fri, Feb 18, 2011 at 8:26 AM, Michal Hocko <mhocko@suse.cz> wrote:
>> Now, I will try with the 2 patches patches in this thread. I will also
>> turn on DEBUG_LIST and DEBUG_PAGEALLOC.
>
> I am not able to reproduce with those 2 patches applied.

Thanks for verifying. Davem/EricD - you can add Michal's tested-by to
the patches too.

And I think we can consider this whole thing solved. It hopefully also
explains all the other random crashes that EricB saw - just random
memory corruption in other datastructures.

EricB - do all your stress-testers run ok now?

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
