Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m87FXXXT028309
	for <linux-mm@kvack.org>; Sun, 7 Sep 2008 21:03:33 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m87FXU2C1769558
	for <linux-mm@kvack.org>; Sun, 7 Sep 2008 21:03:33 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m87FXTkX008806
	for <linux-mm@kvack.org>; Sun, 7 Sep 2008 21:03:30 +0530
Message-ID: <48C3F444.4060908@linux.vnet.ibm.com>
Date: Sun, 07 Sep 2008 21:03:24 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH][mmotm]memcg: handle null dereference of mm->owner
References: <20080905165017.b2715fe4.nishimura@mxp.nes.nec.co.jp> <20080905174021.9fa29b01.kamezawa.hiroyu@jp.fujitsu.com> <6599ad830809050903s7e1a1004i6b31660502c0dcf2@mail.gmail.com>
In-Reply-To: <6599ad830809050903s7e1a1004i6b31660502c0dcf2@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Fri, Sep 5, 2008 at 1:40 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> BTW, I have a question to Balbir and Paul. (I'm sorry I missed the discussion.)
>> Recently I wonder why we need MM_OWNER.
>>
>> - What's bad with thread's cgroup ?
> 
> Because lots of mm operations take place in a context where we don't
> have a thread pointer, and hence no cgroup.
> 

Right, Thanks! Allocating memory is not that big a problem (we usually know the
context), while freeing memory, we can't assume that current is freeing it

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
