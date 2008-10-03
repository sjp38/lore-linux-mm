Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m935A2UT004057
	for <linux-mm@kvack.org>; Fri, 3 Oct 2008 15:10:02 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m935AaI2296106
	for <linux-mm@kvack.org>; Fri, 3 Oct 2008 15:10:38 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m935AZaG001367
	for <linux-mm@kvack.org>; Fri, 3 Oct 2008 15:10:35 +1000
Message-ID: <48E5A938.9090703@linux.vnet.ibm.com>
Date: Fri, 03 Oct 2008 10:40:16 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] mm owner: fix race between swapoff and exit
References: <Pine.LNX.4.64.0809250117220.26422@blonde.site> <48DCC068.30706@gmail.com> <Pine.LNX.4.64.0809261344190.27666@blonde.site> <20081002161159.735cbb85.akpm@linux-foundation.org>
In-Reply-To: <20081002161159.735cbb85.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, jirislaby@gmail.com, torvalds@linux-foundation.org, nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyuki@jp.fujitsu.com, lizf@cn.fujitsu.com, menage@google.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Fri, 26 Sep 2008 14:36:55 +0100 (BST)
> Hugh Dickins <hugh@veritas.com> wrote:
> 
>>> BTW there is also mm->owner = NULL; movement in the patch to the line before
>>> the callbacks are invoked which I don't understand much (why to inform
>>> anybody about NULL->NULL change?), but the first hunk seems reasonable to me.
>> You draw attention to the second hunk of
>> memrlimit-setup-the-memrlimit-controller-mm_owner-fix
>> (shown below).  It's just nonsense, isn't it, reverting the fix you
>> already made?  Perhaps it's not the patch Balbir and Zefan actually
>> submitted, but a mismerge of that with the fluctuating state of
>> all these accumulated fixes in the mm tree, and nobody properly
>> tested the issue in question on the resulting tree.
>>
>> Or is the whole patch pointless, the first hunk just an attempt
>> to handle the nonsense of the second hunk?
>>
>> I wish there were a lot more care and a lot less churn in this area.
> 
> I really don't see those patches going anywhere and they are, to some
> extent, getting in the way of real work.
> 
> I'm thinking lets-drop-them-all thoughts.

Andrew,

There has been some discussion around memrlimits, the main argument against
those patches by Dave Hansen and Paul Menage has been that no application can
deal with mmap()/malloc() failures. My argument has been that applications that
can deal with them should not be penalized and we have no overcommit support for
cgroups (I don't mind the back port that Andrea did for overcommit support).
I've listed the pros and cons in a separate set of emails to lkml. The
discussion can be found at
http://kerneltrap.org/mailarchive/linux-kernel/2008/8/19/2988814

Although, I find it to be useful and non-users can decide not to enable any
limits, if we are not going to build consensus on this feature, we might as well
drop it :(

-- 
	Balbir

PS: When we do the mlock controller, we'll probably redo some of the
infrastructure that we have memrlimits, but at the moment other things are
keeping me occupied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
