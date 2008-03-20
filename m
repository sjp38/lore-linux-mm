Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2KJDTvp021282
	for <linux-mm@kvack.org>; Thu, 20 Mar 2008 15:13:29 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2KJDSYZ048390
	for <linux-mm@kvack.org>; Thu, 20 Mar 2008 15:13:28 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2KJDSB1025960
	for <linux-mm@kvack.org>; Thu, 20 Mar 2008 15:13:28 -0400
Subject: Re: [RFC/PATCH 01/15] preparation: provide hook to enable pgstes
	in	user pagetable
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <47E29EC6.5050403@goop.org>
References: <1206028710.6690.21.camel@cotte.boeblingen.de.ibm.com>
	 <1206030278.6690.52.camel@cotte.boeblingen.de.ibm.com>
	 <47E29EC6.5050403@goop.org>
Content-Type: text/plain
Date: Thu, 20 Mar 2008 12:13:25 -0700
Message-Id: <1206040405.8232.24.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Carsten Otte <cotte@de.ibm.com>, virtualization@lists.linux-foundation.org, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>, Linux Memory Management List <linux-mm@kvack.org>, aliguori@us.ibm.com, EHRHARDT@de.ibm.com, arnd@arndb.de, hollisb@us.ibm.com, heiko.carstens@de.ibm.com, jeroney@us.ibm.com, borntraeger@de.ibm.com, schwidefsky@de.ibm.com, rvdheij@gmail.com, os@de.ibm.com, jblunck@suse.de, "Zhang, Xiantao" <xiantao.zhang@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-03-20 at 10:28 -0700, Jeremy Fitzhardinge wrote:
> Carsten Otte wrote:
> > +struct mm_struct *dup_mm(struct task_struct *tsk);
> 
> No prototypes in .c files.  Put this in an appropriate header.

Well, and more fundamentally: do we really want dup_mm() able to be
called from other code?

Maybe we need a bit more detailed justification why fork() itself isn't
good enough.  It looks to me like they basically need an arch-specific
argument to fork, telling the new process's page tables to take the
fancy new bit.

I'm really curious how this new stuff is going to get used.  Are you
basically replacing fork() when creating kvm guests?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
