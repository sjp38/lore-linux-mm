Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2QBk9BD020481
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 22:46:09 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2QBn2Gr234426
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 22:49:02 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2QBjLqx015609
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 22:45:21 +1100
Message-ID: <47EA3684.60107@linux.vnet.ibm.com>
Date: Wed, 26 Mar 2008 17:11:56 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][-mm] Memory controller add mm->owner
References: <20080324140142.28786.97267.sendpatchset@localhost.localdomain> <6599ad830803240803s5160101bi2bf68b36085f777f@mail.gmail.com> <47E7D51E.4050304@linux.vnet.ibm.com> <6599ad830803240934g2a70d904m1ca5548f8644c906@mail.gmail.com> <47E7E5D0.9020904@linux.vnet.ibm.com> <6599ad830803241046l61e2965t52fd28e165d5df7a@mail.gmail.com> <47E8E4F3.6090604@linux.vnet.ibm.com>  <47EA2592.7090600@linux.vnet.ibm.com> <6599ad830803260420v236127cfydd8cf828fcce65bb@mail.gmail.com>
In-Reply-To: <6599ad830803260420v236127cfydd8cf828fcce65bb@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Wed, Mar 26, 2008 at 3:29 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  >>
>>  >> - in the worst case, it's not going to be worse than doing a
>>  >> for_each_thread() loop
>>  >>
>>
>>  This will have to be the common case, since you never know what combination of
>>  clone calls did CLONE_VM and what did CLONE_THREAD. At exit time, we need to pay
>>  a for_each_process() overhead.
> 
> I'm not convinced of this. All we have to do is find some other
> process p where p->mm == current->mm and make it the new owner.
> Exactly what sequence of clone() calls was used to cause the sharing
> isn't really relevant. I really think that a suitable candidate will
> be found amongst your children or your first sibling in 99.9% of those
> cases where more than one process is using an mm.
> 

Hmmm.. the 99.9% of the time is just guess work (not measured, could be possibly
true). I see and understand your code below. But before I try and implement
something like that, I was wondering why zap_threads() does not have that
heuristic. That should explain my inhibition.

Can anyone elaborate on zap_threads further?

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
