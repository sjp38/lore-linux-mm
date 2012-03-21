Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 8F4086B004D
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 13:55:59 -0400 (EDT)
Received: from localhost (localhost [127.0.0.1])
	by node6.dwd.de (Postfix) with ESMTP id 46B55C581D5
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 17:55:58 +0000 (UTC)
Received: from node6.dwd.de ([127.0.0.1])
	by localhost (node6.csg-cluster.lan [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id G-Vqn9YY9VZD for <linux-mm@kvack.org>;
	Wed, 21 Mar 2012 17:55:58 +0000 (UTC)
Date: Wed, 21 Mar 2012 17:55:54 +0000 (GMT)
From: Holger Kiehl <Holger.Kiehl@dwd.de>
Subject: Re: [RFC]swap: don't do discard if no discard option added
In-Reply-To: <alpine.LSU.2.00.1203202019140.1842@eggly.anvils>
Message-ID: <alpine.LRH.2.02.1203211620480.21654@diagnostix.dwd.de>
References: <4F68795E.9030304@kernel.org> <alpine.LSU.2.00.1203202019140.1842@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Martin K. Petersen" <martin.petersen@oracle.com>, linux-mm@kvack.org

On Tue, 20 Mar 2012, Hugh Dickins wrote:

> On Tue, 20 Mar 2012, Shaohua Li wrote:
>>
>> Even don't add discard option, swapon will do discard, this sounds buggy,
>> especially when discard is slow or buggy.
>
> It's not a bug in swapon, it's an intentional feature, made explicit in
> commit 339944663273 "swap: discard while swapping only if SWAP_FLAG_DISCARD"
> and in the swapon(2) manpage.  We were also careful in wording the swapon(8)
> manpage and the comment on SWAP_FLAG_DISCARD in swap.h - too lawyerly ;-?
>
> It appears to be a bug in the Vertex 2: I did receive one other such
> report on a Vertex 2 fourteen months ago, and in the absence of further
> reports, we decided to consider that user's drive defective.  I wonder
> if Holger's drive is defective, or if it's true of all Vertex 2s, or
> if it depends on the firmware revision, and a later revision fixes it.
>
I have three of those drives put together via MD to a raid 0 and I do
not think they are defective, since they worked (without discard) so far.
Firmware is also the new-es it's 1.35, just checked with OCZ website.

Thank you for the pointer with the firmware, I have posted a support
question at OCZ.

> If the latter (if there is a firmware revision which fixes it), then
> I think it's clear that SWAP_FLAG_DISCARD should continue to behave
> as it does at present, with discard at swapon independent of it.
>
> Holger, do you have the latest firmware on this drive?
>
Yes, it has the latest firmware.

> Have any other Vertex 2 users observed this behaviour?
>
> I've seen no such problem with the original OCZ Vertex, nor with
> their Vertex 3, nor with the Intel drives I've tried (and you
> report no problem with FusionIO's, though no advantage either).
>
> But if there's no good firmware for the Vertex 2, I'm not so sure
> what to do: two reports in fourteen months, on a superseded drive -
> is that strong enough to disable a feature which appeared to offer
> some advantage on others?
>
No, I agree that one should not disable a feature that is useful to so
many, for the reasons you mention. However, it would be good if there
is some way to disable this, other then having to always patch the kernel.

Regards,
Holger

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
