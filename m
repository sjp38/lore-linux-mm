Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 42BDC6B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 03:38:27 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BEFD93EE0B6
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 16:38:22 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A2C8945DE75
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 16:38:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 89D3245DE73
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 16:38:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BF1F1DB8037
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 16:38:22 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 37BAA1DB803E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 16:38:22 +0900 (JST)
Message-ID: <4DF1C9DE.4070605@jp.fujitsu.com>
Date: Fri, 10 Jun 2011 16:38:06 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Make GFP_DMA allocations w/o ZONE_DMA emit a warning
 instead of failing
References: <1306922672-9012-1-git-send-email-dbaryshkov@gmail.com> <BANLkTinBkdVd90g3-uiQP41z1S1sXUdRmQ@mail.gmail.com> <BANLkTikrRRzGLbMD47_xJz+xpgftCm1C2A@mail.gmail.com> <alpine.DEB.2.00.1106011017260.13089@chino.kir.corp.google.com> <20110601181918.GO3660@n2100.arm.linux.org.uk> <alpine.LFD.2.02.1106012043080.3078@ionos> <alpine.DEB.2.00.1106011205410.17065@chino.kir.corp.google.com> <alpine.LFD.2.02.1106012134120.3078@ionos>
In-Reply-To: <alpine.LFD.2.02.1106012134120.3078@ionos>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de
Cc: rientjes@google.com, linux@arm.linux.org.uk, dbaryshkov@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, akpm@linux-foundation.org, pavel@ucw.cz

(2011/06/02 4:46), Thomas Gleixner wrote:
> On Wed, 1 Jun 2011, David Rientjes wrote:
>> On Wed, 1 Jun 2011, Thomas Gleixner wrote:
>>
>>>> That is NOT an unreasonable request, but it seems that its far too much
>>>> to ask of you.
>>>
>>> Full ack.
>>>
>>> David,
>>>
>>> stop that nonsense already. You changed the behaviour and broke stuff
>>> which was working fine before for whatever reason. That behaviour was
>>> in the kernel for ages and we tolerated the abuse.
>>>
>>
>> Did I nack this patch and not realize it?
> 
> No, you did not realize anything.
>  
>> Does my patch fix the warning for pxaficp_ir that would still be emitted 
>> with this patch?  If the driver uses GFP_DMA and nobody from the arm side 
> 
> Your patch does not fix anything. It papers over the problem and
> that's the f@&^%%@^#ing wrong approach.
> 
> And just to be clear. You CANNOT fix a warning. You can fix the code
> which causes the warning, but that's not what your patch is
> doing. Your patch HIDES the problem.
> 
>> is prepared to remove it yet, then I'd suggest merging my patch until that 
>> can be determined.  Otherwise, you have no guarantees about where the 
>> memory is actually coming from.
> 
> Did you actually try to understand what I wrote? 
> 
> You decided that it's a BUG just because it should not be allowed. So
> you changed the behaviour, which was perfectly fine before.
> 
> Now you try to paper over the problem by selecting ZONE_DMA and refuse
> to give a grace period of _ONE_ kernel release.
> 
> IOW, you are preventing that the abusers of GFP_DMA are fixed
> properly.
> 
> I can see that you neither have the bandwidth nor the knowledge to
> analyse each user of GFP_DMA. And that should tell you something.
> 
> If you cannot fix it yourself, then f*(&!@$#ng not break it.


Then, the revert patch is here.
