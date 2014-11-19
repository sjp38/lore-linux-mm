Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2F6976B0038
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 08:14:11 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so1812044wiv.1
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 05:14:10 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vm10si2570410wjc.57.2014.11.19.05.14.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Nov 2014 05:14:10 -0800 (PST)
Date: Wed, 19 Nov 2014 13:14:06 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/7] Replace _PAGE_NUMA with PAGE_NONE protections
Message-ID: <20141119131406.GH2725@suse.de>
References: <1415971986-16143-1-git-send-email-mgorman@suse.de>
 <5466C8A5.3000402@oracle.com>
 <20141118154246.GB2725@suse.de>
 <546B74F5.10004@oracle.com>
 <87tx1w78hi.fsf@linux.vnet.ibm.com>
 <546B7F73.6090805@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <546B7F73.6090805@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Nov 18, 2014 at 12:18:43PM -0500, Sasha Levin wrote:
> On 11/18/2014 11:56 AM, Aneesh Kumar K.V wrote:
> >>> 4. Similarly, does the kernel boot properly without without patches?
> >> >
> >> > Yes, the kernel works fine without the patches both with and without fake
> >> > numa.
> > 
> > Hmm that is interesting. I am not sure how writeback_fid can be
> > related. We use writeback fid to enable client side caching with 9p
> > (cache=loose). We use this fid to write back dirty pages later. Can you
> > share the qemu command line used, 9p mount options and the test details ? 
> 
> I'm using kvmtool rather than qemu. rootfs is created via kernel parameters:
> 
> root=/dev/root rw rootflags=rw,trans=virtio,version=9p2000.L rootfstype=9p
> 
> The test is just running trinity, there's no 9p or mm specific test going on.
> 
> I've attached my .config.
> 

Ok, based on that I was able to reproduce the problem. I hope to have a
V2 before the end of the week. Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
