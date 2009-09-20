Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 52F056B010E
	for <linux-mm@kvack.org>; Sun, 20 Sep 2009 11:03:55 -0400 (EDT)
Received: by pzk31 with SMTP id 31so1758083pzk.23
        for <linux-mm@kvack.org>; Sun, 20 Sep 2009 08:03:55 -0700 (PDT)
Message-ID: <4AB6441D.5070805@vflare.org>
Date: Sun, 20 Sep 2009 20:32:53 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] send callback when swap slot is freed
References: <1253227412-24342-1-git-send-email-ngupta@vflare.org>	 <1253227412-24342-3-git-send-email-ngupta@vflare.org>	 <1253256805.4959.8.camel@penberg-laptop>	 <Pine.LNX.4.64.0909180809290.2882@sister.anvils>	 <1253260528.4959.13.camel@penberg-laptop>	 <Pine.LNX.4.64.0909180857170.5404@sister.anvils> <1253266391.4959.15.camel@penberg-laptop> <4AB3A16B.90009@vflare.org> <4AB487FD.5060207@cs.helsinki.fi>
In-Reply-To: <4AB487FD.5060207@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Ed Tomlinson <edt@aei.ca>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-mm-cc <linux-mm-cc@laptop.org>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

Hi Pekka,

On 09/19/2009 12:57 PM, Pekka Enberg wrote:
> 
> Nitin Gupta wrote:
>> It is understood that this swap notify callback is bit of a hack. I think
>> we will not gain much trying to beautify this hack. However, I agree with
>> Hugh's suggestion to rename this notify callback related
>> function/variables
>> to make it explicit that its completely ramzswap related. I will send
>> a path that affects these renames as reply to patch 0/4.
> 
> I don't quite agree and do think that my approach is a better long-term
> solution. That said, it's Hugh's call, not mine. Hugh?
> 

Ok, lets discard all this. I will soon start working on a generic notifier based
interface for various swap events: swapon, swapoff, swap slot free that I hope would
be more acceptable. I will now surely miss this merge window but I hope the end result
would be better.

The issue of swap_lock is still bugging me but I think atomic notifier list should
be acceptable for swap slot free event, at least for the initial revision. If this
particular event finds more users then we will have to work on reducing contention
on swap_lock (per-swap file lock?).

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
