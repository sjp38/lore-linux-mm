Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k113C0hV018891
	for <linux-mm@kvack.org>; Tue, 31 Jan 2006 22:12:00 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k113A51F269710
	for <linux-mm@kvack.org>; Tue, 31 Jan 2006 20:10:05 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k113C0rt017561
	for <linux-mm@kvack.org>; Tue, 31 Jan 2006 20:12:00 -0700
Subject: Re: [ckrm-tech] [PATCH 0/8] Pzone based CKRM memory resource
	controller
From: chandra seetharaman <sekharan@us.ibm.com>
Reply-To: sekharan@us.ibm.com
In-Reply-To: <20060131023000.7915.71955.sendpatchset@debian>
References: <20060119080408.24736.13148.sendpatchset@debian>
	 <20060131023000.7915.71955.sendpatchset@debian>
Content-Type: text/plain
Date: Tue, 31 Jan 2006 18:58:18 -0800
Message-Id: <1138762698.3938.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Kurosawa,

I like the idea of multiple controllers for a resource. Users will have
options to choose from. Thanks for doing it.

I have few questions:
 - how are shared pages handled ?
 - what is the plan to support "limit" ?
 - can you provide more information in stats ?
 - is it designed to work with cpumeter alone (i.e without ckrm) ?

comment/suggestion:
 - IMO, moving pages from a class at time of reclassification would be
   the right thing to do. May be we have to add a pointer to Chris patch
   and make sure it works as we expect.
 - instead of adding the pseudo zone related code to the core memory
   files, you can put them in a separate file.
 - Documentation on how to configure and use it would be good.
  
regards,

chandra
  
On Tue, 2006-01-31 at 11:30 +0900, KUROSAWA Takahiro wrote:
> I've split the patches into smaller pieces in order to increase
> readability.  The core part of the patchset is the fifth one with
> the subject "Add the pzone_create() function."
> 
> Changes since the last post:
> * Fixed a bug that pages allocated with __GFP_COLD are incorrectly handled.
> * Moved the PZONE bit in page flags next to the zone number bits in 
>   order to make changes by pzones smaller.
> * Moved the nr_zones locking functions outside of the CONFIG_PSEUDO_ZONE
>   because they are not directly related to pzones.
> 
> Thanks,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
