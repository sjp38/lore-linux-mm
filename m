Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8B81A6B01BB
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 07:10:27 -0400 (EDT)
Received: by pvg2 with SMTP id 2so5560895pvg.14
        for <linux-mm@kvack.org>; Mon, 29 Mar 2010 04:10:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <17cb70ee1003270356g7fba07b0xf558583484748dc3@mail.gmail.com>
References: <17cb70ee1003270356g7fba07b0xf558583484748dc3@mail.gmail.com>
Date: Mon, 29 Mar 2010 13:10:25 +0200
Message-ID: <17cb70ee1003290410o72b244abrbc8d41ddf2fde5f4@mail.gmail.com>
Subject: Re: On using allocation in sysctl handler
From: Auguste Mome <augustmome@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I did the allocation inside a lock, that's the real problem, not the
GFP thing. Really sorry for the noise.

On Sat, Mar 27, 2010 at 12:56 PM, Auguste Mome <augustmome@gmail.com> wrote:
> Hi,
> I added an allocation GFP_KERNEL inside a sysctl handler and got the error
> BUG: sleeping function called from invalid context
> in_atomic(): 1, irqs_disabled(): 0, pid: 723, name: sysctl
>
> Is it obvious error and I should use GFP_ATOMIC?
> I guess yes, but it just happens since I switched to a 2.6.30 on ppc, and it did
> not happen on 2.6.30 x86.
> So I'm not sure if something is wrong on ppc, of if something changed
> recently in sysctl,
> or simply my code was wrong and the check has improved in memory system.
>
> Thanks,
> Auguste.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
