Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B27746B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 08:56:18 -0400 (EDT)
Message-ID: <4BAB5D7F.5010401@cn.fujitsu.com>
Date: Thu, 25 Mar 2010 20:56:31 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH V2 4/4] cpuset,mm: update task's mems_allowed lazily
References: <4B94CD2D.8070401@cn.fujitsu.com> <alpine.DEB.2.00.1003081330370.18502@chino.kir.corp.google.com> <4B95F802.9020308@cn.fujitsu.com> <20100311081548.GJ5812@laptop> <4B98C6DE.3060602@cn.fujitsu.com> <20100311110317.GL5812@laptop> <4BAB39B9.7080600@cn.fujitsu.com>
In-Reply-To: <4BAB39B9.7080600@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

on 2010-3-25 18:23, Miao Xie wrote:
> on 2010-3-11 19:03, Nick Piggin wrote:
>> Well... I do think seqlocks would be a bit simpler because they don't
>> require this checking and synchronizing of this patch.
> 
> Hi, Nick Piggin
> 
> I have made a new patch which uses seqlock to protect mems_allowed and mempolicy.
> please review it.
> 
> title: [PATCH -mmotm] cpuset,mm: use seqlock to protect task->mempolicy and mems_allowed
> 

Sorry! Please ignore this patch, because I sent an old version. I'll send the new one later.

Regards!
Miao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
