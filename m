Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 95A7362003F
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:27:49 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp01.au.ibm.com (8.14.3/8.13.1) with ESMTP id o2HGPbsx014171
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 03:25:37 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2HGLqKh1552448
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 03:21:52 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2HGRh99003731
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 03:27:44 +1100
Date: Wed, 17 Mar 2010 21:57:39 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot
 parameter
Message-ID: <20100317162739.GU18054@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100315072214.GA18054@balbir.in.ibm.com>
 <4B9DE635.8030208@redhat.com>
 <20100315080726.GB18054@balbir.in.ibm.com>
 <4B9DEF81.6020802@redhat.com>
 <20100315202353.GJ3840@arachsys.com>
 <4B9EC60A.2070101@codemonkey.ws>
 <20100317151409.GY31148@arachsys.com>
 <4BA0FB83.1010502@codemonkey.ws>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4BA0FB83.1010502@codemonkey.ws>
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: Chris Webb <chris@arachsys.com>, Avi Kivity <avi@redhat.com>, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* Anthony Liguori <anthony@codemonkey.ws> [2010-03-17 10:55:47]:

> On 03/17/2010 10:14 AM, Chris Webb wrote:
> >Anthony Liguori<anthony@codemonkey.ws>  writes:
> >
> >>This really gets down to your definition of "safe" behaviour.  As it
> >>stands, if you suffer a power outage, it may lead to guest
> >>corruption.
> >>
> >>While we are correct in advertising a write-cache, write-caches are
> >>volatile and should a drive lose power, it could lead to data
> >>corruption.  Enterprise disks tend to have battery backed write
> >>caches to prevent this.
> >>
> >>In the set up you're emulating, the host is acting as a giant write
> >>cache.  Should your host fail, you can get data corruption.
> >Hi Anthony. I suspected my post might spark an interesting discussion!
> >
> >Before considering anything like this, we did quite a bit of testing with
> >OSes in qemu-kvm guests running filesystem-intensive work, using an ipmitool
> >power off to kill the host. I didn't manage to corrupt any ext3, ext4 or
> >NTFS filesystems despite these efforts.
> >
> >Is your claim here that:-
> >
> >   (a) qemu doesn't emulate a disk write cache correctly; or
> >
> >   (b) operating systems are inherently unsafe running on top of a disk with
> >       a write-cache; or
> >
> >   (c) installations that are already broken and lose data with a physical
> >       drive with a write-cache can lose much more in this case because the
> >       write cache is much bigger?
> 
> This is the closest to the most accurate.
> 
> It basically boils down to this: most enterprises use a disks with
> battery backed write caches.  Having the host act as a giant write
> cache means that you can lose data.
> 

Dirty limits can help control how much we lose, but also affect how
much we write out.

> I agree that a well behaved file system will not become corrupt, but
> my contention is that for many types of applications, data lose ==
> corruption and not all file systems are well behaved.  And it's
> certainly valid to argue about whether common filesystems are
> "broken" but from a purely pragmatic perspective, this is going to
> be the case.
>

I think it is a trade-off for end users to decide on. cache=writeback
does provide performance benefits, but can cause data loss.


-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
