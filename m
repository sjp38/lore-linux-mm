Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m66EUSRv093180
	for <linux-mm@kvack.org>; Sun, 6 Jul 2008 14:30:28 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m66EUReJ2359366
	for <linux-mm@kvack.org>; Sun, 6 Jul 2008 15:30:27 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m66EUREp001793
	for <linux-mm@kvack.org>; Sun, 6 Jul 2008 15:30:27 +0100
Subject: Re: [PATCH] Make CONFIG_MIGRATION available for s390
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Reply-To: gerald.schaefer@de.ibm.com
In-Reply-To: <20080705150659.024F.E1E9C6FF@jp.fujitsu.com>
References: <1215183539.4834.12.camel@localhost.localdomain>
	 <20080705130203.e7df168c.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080705150659.024F.E1E9C6FF@jp.fujitsu.com>
Content-Type: text/plain
Date: Sun, 06 Jul 2008 16:30:25 +0200
Message-Id: <1215354625.9842.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sat, 2008-07-05 at 15:14 +0900, Yasunori Goto wrote:
> > >  config MIGRATION
> > >  	bool "Page migration"
> > >  	def_bool y
> > > -	depends on NUMA
> > > +	depends on NUMA || S390
> 
> Hmm. I think ARCH_ENABLE_MEMORY_HOTREMOVE is better than S390.

Right, that makes more sense. I also noticed that my patch will produce
a compile error when CONFIG_NUMA is set but CONFIG_MIGRATION is not,
because policy_zone is missing in that case. Since policy_zone is only
used for NUMA, a better solution would be to use an "#ifdef CONFIG_NUMA"
within vma_migratable(). I will send a new version of the patch.

Thanks,
Gerald


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
