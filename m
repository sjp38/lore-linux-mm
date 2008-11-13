Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mADBXPLL009083
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 13 Nov 2008 20:33:25 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5277E45DE54
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 20:33:25 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E12D45DE50
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 20:33:25 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 10B871DB803E
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 20:33:25 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BDD611DB8040
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 20:33:24 +0900 (JST)
Date: Thu, 13 Nov 2008 20:32:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
 one page into another
Message-Id: <20081113203247.b5e24e26.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <491C038F.5020007@redhat.com>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>
	<1226409701-14831-2-git-send-email-ieidus@redhat.com>
	<1226409701-14831-3-git-send-email-ieidus@redhat.com>
	<20081111114555.eb808843.akpm@linux-foundation.org>
	<4919F1C0.2050009@redhat.com>
	<Pine.LNX.4.64.0811111520590.27767@quilx.com>
	<4919F7EE.3070501@redhat.com>
	<Pine.LNX.4.64.0811111527500.27767@quilx.com>
	<20081111222421.GL10818@random.random>
	<20081112111931.0e40c27d.kamezawa.hiroyu@jp.fujitsu.com>
	<491AAA84.5040801@redhat.com>
	<491AB9D0.7060802@qumranet.com>
	<20081113151129.35c17962.kamezawa.hiroyu@jp.fujitsu.com>
	<491C038F.5020007@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <ieidus@redhat.com>
Cc: Izik Eidus <izik@qumranet.com>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Thu, 13 Nov 2008 12:38:07 +0200
Izik Eidus <ieidus@redhat.com> wrote:
> > If KSM pages are on radix-tree, it will be accounted automatically.
> > Now, we have "Unevictable" LRU and mlocked() pages are smartly isolated into its
> > own LRU. So, just doing
> >
> >  - inode's radix-tree
> >  - make all pages mlocked.
> >  - provide special page fault handler for your purpose
> >   
> 
> Well in this version that i am going to merge the pages arent going to 
> be swappable,
> Latter after Ksm will get merged we will make the KsmPages swappable...
good to hear

> so i think working with cgroups would be effective / useful only when 
> KsmPages will start be swappable...
> Do you agree?
> (What i am saying is that right now lets dont count the KsmPages inside 
> the cgroup, lets do it when KsmPages
> will be swappable)
> 
ok.

> If you feel this pages should be counted in the cgroup i have no problem 
> to do it via hooks like page migration is doing.
> 
> thanks.
> 
> > is simple one. But ok, whatever implementation you'll do, I have to check it
> > and consider whether it should be tracked or not. Then, add codes to memcg to
> > track it or ignore it or comments on your patches ;)
> >
> > It's helpful to add me to CC: when you post this set again.
> >   
> 
> Sure will.
> 

If necessary, I'll have to add "ignore in this case" hook in memcg.
(ex. checking PageKSM flag in memcg.)

If you are sufferred from memcg in your test, cgroup_disable=memory boot option
will allow you to disable memcg.


Thanks,
-Kame








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
