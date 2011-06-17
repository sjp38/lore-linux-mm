Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AE6A66B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 11:29:09 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp01.au.ibm.com (8.14.4/8.13.1) with ESMTP id p5HFOmFm026685
	for <linux-mm@kvack.org>; Sat, 18 Jun 2011 01:24:48 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5HFSBdA1417424
	for <linux-mm@kvack.org>; Sat, 18 Jun 2011 01:28:11 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5HFT5Ap000530
	for <linux-mm@kvack.org>; Sat, 18 Jun 2011 01:29:05 +1000
Date: Fri, 17 Jun 2011 20:58:45 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
Message-ID: <20110617152845.GA13574@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
 <20110613134701.2b23b8d8.kamezawa.hiroyu@jp.fujitsu.com>
 <20110616042044.GA28563@in.ibm.com>
 <20110616181251.caf484b6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110616181251.caf484b6.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

Hi,

On Thu, Jun 16, 2011 at 06:12:51PM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 16 Jun 2011 09:50:44 +0530
> Ankita Garg <ankita@in.ibm.com> wrote:
> 
> > Hi,
> > 
> > On Mon, Jun 13, 2011 at 01:47:01PM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Fri, 27 May 2011 18:01:28 +0530
> > > Ankita Garg <ankita@in.ibm.com> wrote:
> > > 
> > > > Hi,
> > > > 
> > > 
> > > I'm sorry if you've answered already.
> > > 
> > > Is memory hotplug is too bad and cannot be enhanced for this purpose ?
> > > 
> > > I wonder
> > >   - make section-size smaller (IIUC, IBM's system has 16MB section size)
> > > 
> > >   - add per section statistics
> > > 
> > >   - add a kind of balloon driver which does software memory offline
> > >     (which means making a contiguous chunk of free pages of section_size
> > >      by page migration) in background with regard to memory usage statistics.
> > >     If system says "need more memory!", balloon driver can online pages.
> > > 
> > > can work for your purpose. It can allow you page isolatation and
> > > controls in 16MB unit.  If you need whole rework of memory hotplug, I think
> > > it's better to rewrite memory hotplug, too.
> > >
> > 
> > Interesting idea, but a few issues -
> > 
> > - Correctly predicting memory pressure is difficult and thereby being
> >   able to online the required pages at the right time could be a
> >   challenge
> 
> But it will be required for your purpose, anyway. Isn't it ?
> 
> > - Memory hotplug is a heavy operation, so the overhead involved may be
> >   high
> 
> soft-offline of small amount of pages will not very heavy.
> compaction and cma patches use the same kind of logic.
> 
> 
> > - Powering off memory is just one of the ways in which memory power could
> >   be saved. The platform can also dynamically transition areas of memory
> >   into a  content-preserving lower power state if it is not referenced
> >   for a pre-defined threshold of time. In such a case, we would need a
> >   mechanism to soft offline the pages - i.e, no new allocations to be
> >   directed to that memory
> > 
> 
> Hmm, sounds like a similar idea of CleanCache ?
> 
> Reusing section is much easier than adding new one.., I think.
> 

But sections do not define the granualarity at which memory operations
are done right ? i.e, allocations/deallocations or reclaim cannot be
directed to a section or a group of sections ?

-- 
Regards,
Ankita Garg (ankita@in.ibm.com)
Linux Technology Center
IBM India Systems & Technology Labs,
Bangalore, India

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
