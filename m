Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8F8866B0071
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 20:08:57 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5B07IQi015085
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 20:07:18 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5B07YOb132998
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 20:07:34 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5B07YEQ030239
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 20:07:34 -0400
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page
 cache control
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20100610142512.GB5191@balbir.in.ibm.com>
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
	 <20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com>
	 <4C10B3AF.7020908@redhat.com>  <20100610142512.GB5191@balbir.in.ibm.com>
Content-Type: text/plain
Date: Thu, 10 Jun 2010 17:07:32 -0700
Message-Id: <1276214852.6437.1427.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Avi Kivity <avi@redhat.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-06-10 at 19:55 +0530, Balbir Singh wrote:
> > I'm not sure victimizing unmapped cache pages is a good idea.
> > Shouldn't page selection use the LRU for recency information instead
> > of the cost of guest reclaim?  Dropping a frequently used unmapped
> > cache page can be more expensive than dropping an unused text page
> > that was loaded as part of some executable's initialization and
> > forgotten.
> 
> We victimize the unmapped cache only if it is unused (in LRU order).
> We don't force the issue too much. We also have free slab cache to go
> after.

Just to be clear, let's say we have a mapped page (say of /sbin/init)
that's been unreferenced since _just_ after the system booted.  We also
have an unmapped page cache page of a file often used at runtime, say
one from /etc/resolv.conf or /etc/passwd.

Which page will be preferred for eviction with this patch set?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
