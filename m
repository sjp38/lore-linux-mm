Received: from talaria.fm.intel.com (talaria.fm.intel.com [10.1.192.39])
	by hermes.fm.intel.com (8.11.6/8.11.6/d: outer.mc,v 1.51 2002/09/23 20:43:23 dmccart Exp $) with ESMTP id h17MDb217492
	for <linux-mm@kvack.org>; Fri, 7 Feb 2003 22:13:37 GMT
Received: from fmsmsxvs041.fm.intel.com (fmsmsxvs041.fm.intel.com [132.233.42.126])
	by talaria.fm.intel.com (8.11.6/8.11.6/d: inner.mc,v 1.28 2003/01/13 19:44:39 dmccart Exp $) with SMTP id h17M4AK01913
	for <linux-mm@kvack.org>; Fri, 7 Feb 2003 22:04:10 GMT
content-class: urn:content-classes:message
Subject: RE: hugepage patches
Date: Fri, 7 Feb 2003 14:02:22 -0800
Message-ID: <6315617889C99D4BA7C14687DEC8DB4E023D2E6D@fmsmsx402.fm.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
From: "Seth, Rohit" <rohit.seth@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, "Seth, Rohit" <rohit.seth@intel.com>
Cc: davem@redhat.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The allocated pages will be zapped on the way back from do_mmap_pgoff
for the failure case.

> -----Original Message-----
> From: Andrew Morton [mailto:akpm@digeo.com] 
> Sent: Friday, February 07, 2003 2:00 PM
> To: Seth, Rohit
> Cc: davem@redhat.com; rohit.seth@intel.com; 
> davidm@napali.hpl.hp.com; anton@samba.org; 
> wli@holomorphy.com; linux-mm@kvack.org
> Subject: Re: hugepage patches
> 
> 
> "Seth, Rohit" <rohit.seth@intel.com> wrote:
> >
> > Andrew,
> > 
> > New allocation of hugepages is an atomic operation.  Partial 
> > allocations of hugepages is not a possibility.
> 
> Yes it is?  If you ask hugetlb_prefault() to fault in four 
> pages, and there are only two pages available then it will 
> instantiate just the two pages.
> 
> And updating i_size at the place where we add the page to 
> pagecache makes some sense..
> 
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
