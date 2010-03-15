Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7CD046B01C0
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 06:46:05 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp05.au.ibm.com (8.14.3/8.13.1) with ESMTP id o2FAgMuB000632
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 21:42:22 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2FAe8lR1658884
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 21:40:09 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2FAjvnb018477
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 21:45:57 +1100
Date: Mon, 15 Mar 2010 16:15:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot
 parameter
Message-ID: <20100315104555.GD18054@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100315072214.GA18054@balbir.in.ibm.com>
 <4B9DE635.8030208@redhat.com>
 <20100315080726.GB18054@balbir.in.ibm.com>
 <4B9DEF81.6020802@redhat.com>
 <20100315091720.GC18054@balbir.in.ibm.com>
 <4B9DFD9C.8030608@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4B9DFD9C.8030608@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* Avi Kivity <avi@redhat.com> [2010-03-15 11:27:56]:

> >>>The knobs are for
> >>>
> >>>1. Selective enablement
> >>>2. Selective control of the % of unmapped pages
> >>An alternative path is to enable KSM for page cache.  Then we have
> >>direct read-only guest access to host page cache, without any guest
> >>modifications required.  That will be pretty difficult to achieve
> >>though - will need a readonly bit in the page cache radix tree, and
> >>teach all paths to honour it.
> >>
> >Yes, it is, I've taken a quick look. I am not sure if de-duplication
> >would be the best approach, may be dropping the page in the page cache
> >might be a good first step. Data consistency would be much easier to
> >maintain that way, as long as the guest is not writing frequently to
> >that page, we don't need the page cache in the host.
> 
> Trimming the host page cache should happen automatically under
> pressure.  Since the page is cached by the guest, it won't be
> re-read, so the host page is not frequently used and then dropped.
>

Yes, agreed, but dropping is easier than tagging cache as read-only
and getting everybody to understand read-only cached pages. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
