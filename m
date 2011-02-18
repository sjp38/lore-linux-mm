Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EBE7F8D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 23:58:34 -0500 (EST)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p1I4vxA2003487
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 20:57:59 -0800
Received: by iwc10 with SMTP id 10so3274490iwc.14
        for <linux-mm@kvack.org>; Thu, 17 Feb 2011 20:57:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110217.204036.226788819.davem@davemloft.net>
References: <m1sjvm822m.fsf@fess.ebiederm.org> <AANLkTimzP0UNRXutkt1zJ+OGhmeg6ga87HFyMuZQmpMj@mail.gmail.com>
 <AANLkTi=kEEip7UjtLqvo0Hpz8uwjVdx334hYnPsoNXis@mail.gmail.com> <20110217.204036.226788819.davem@davemloft.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 17 Feb 2011 20:57:39 -0800
Message-ID: <AANLkTin2XX-HHFqnAajUYPU23WeuOZk7vvGczmijUEy=@mail.gmail.com>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in 2.6.38-rc4
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: ebiederm@xmission.com, mingo@elte.hu, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, eric.dumazet@gmail.com, opurdila@ixiacom.com

On Thu, Feb 17, 2011 at 8:40 PM, David Miller <davem@davemloft.net> wrote:
>
> I looked at Eric's (and your) patch before I wrote my reply :-)

It was Eric Biederman that was missing from some of the discussion.
Too many Eric's, and two separate threads for the same bug that I'm
involved in.

                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
