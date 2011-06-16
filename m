Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6D96C6B00EB
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 00:20:59 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp09.au.ibm.com (8.14.4/8.13.1) with ESMTP id p5G4KnCY032679
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:20:49 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5G4JumA1351846
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:19:57 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5G4KmVx016822
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:20:48 +1000
Date: Thu, 16 Jun 2011 09:50:44 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
Message-ID: <20110616042044.GA28563@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
 <20110613134701.2b23b8d8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110613134701.2b23b8d8.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

Hi,

On Mon, Jun 13, 2011 at 01:47:01PM +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 27 May 2011 18:01:28 +0530
> Ankita Garg <ankita@in.ibm.com> wrote:
> 
> > Hi,
> > 
> 
> I'm sorry if you've answered already.
> 
> Is memory hotplug is too bad and cannot be enhanced for this purpose ?
> 
> I wonder
>   - make section-size smaller (IIUC, IBM's system has 16MB section size)
> 
>   - add per section statistics
> 
>   - add a kind of balloon driver which does software memory offline
>     (which means making a contiguous chunk of free pages of section_size
>      by page migration) in background with regard to memory usage statistics.
>     If system says "need more memory!", balloon driver can online pages.
> 
> can work for your purpose. It can allow you page isolatation and
> controls in 16MB unit.  If you need whole rework of memory hotplug, I think
> it's better to rewrite memory hotplug, too.
>

Interesting idea, but a few issues -

- Correctly predicting memory pressure is difficult and thereby being
  able to online the required pages at the right time could be a
  challenge
- Memory hotplug is a heavy operation, so the overhead involved may be
  high
- Powering off memory is just one of the ways in which memory power could
  be saved. The platform can also dynamically transition areas of memory
  into a  content-preserving lower power state if it is not referenced
  for a pre-defined threshold of time. In such a case, we would need a
  mechanism to soft offline the pages - i.e, no new allocations to be
  directed to that memory

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
