Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 899386B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 05:19:50 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 57BD93EE0C0
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 18:19:47 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 39D3645DE72
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 18:19:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 13FD845DE6F
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 18:19:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EAEF81DB8042
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 18:19:46 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B5ECC1DB803E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 18:19:46 +0900 (JST)
Date: Thu, 16 Jun 2011 18:12:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
Message-Id: <20110616181251.caf484b6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110616042044.GA28563@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
	<20110613134701.2b23b8d8.kamezawa.hiroyu@jp.fujitsu.com>
	<20110616042044.GA28563@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ankita Garg <ankita@in.ibm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

On Thu, 16 Jun 2011 09:50:44 +0530
Ankita Garg <ankita@in.ibm.com> wrote:

> Hi,
> 
> On Mon, Jun 13, 2011 at 01:47:01PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Fri, 27 May 2011 18:01:28 +0530
> > Ankita Garg <ankita@in.ibm.com> wrote:
> > 
> > > Hi,
> > > 
> > 
> > I'm sorry if you've answered already.
> > 
> > Is memory hotplug is too bad and cannot be enhanced for this purpose ?
> > 
> > I wonder
> >   - make section-size smaller (IIUC, IBM's system has 16MB section size)
> > 
> >   - add per section statistics
> > 
> >   - add a kind of balloon driver which does software memory offline
> >     (which means making a contiguous chunk of free pages of section_size
> >      by page migration) in background with regard to memory usage statistics.
> >     If system says "need more memory!", balloon driver can online pages.
> > 
> > can work for your purpose. It can allow you page isolatation and
> > controls in 16MB unit.  If you need whole rework of memory hotplug, I think
> > it's better to rewrite memory hotplug, too.
> >
> 
> Interesting idea, but a few issues -
> 
> - Correctly predicting memory pressure is difficult and thereby being
>   able to online the required pages at the right time could be a
>   challenge

But it will be required for your purpose, anyway. Isn't it ?

> - Memory hotplug is a heavy operation, so the overhead involved may be
>   high

soft-offline of small amount of pages will not very heavy.
compaction and cma patches use the same kind of logic.


> - Powering off memory is just one of the ways in which memory power could
>   be saved. The platform can also dynamically transition areas of memory
>   into a  content-preserving lower power state if it is not referenced
>   for a pre-defined threshold of time. In such a case, we would need a
>   mechanism to soft offline the pages - i.e, no new allocations to be
>   directed to that memory
> 

Hmm, sounds like a similar idea of CleanCache ?

Reusing section is much easier than adding new one.., I think.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
