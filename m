Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 46DC66B025E
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 04:15:07 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r18so11225653wmd.1
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 01:15:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w30si27856655wra.79.2017.02.02.01.15.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Feb 2017 01:15:05 -0800 (PST)
Date: Thu, 2 Feb 2017 10:15:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/5] userfaultfd: non-cooperative: add event for
 memory unmaps
Message-ID: <20170202091503.GA22823@dhcp22.suse.cz>
References: <1485542673-24387-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1485542673-24387-3-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1485542673-24387-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 27-01-17 20:44:30, Mike Rapoport wrote:
> When a non-cooperative userfaultfd monitor copies pages in the background,
> it may encounter regions that were already unmapped. Addition of
> UFFD_EVENT_UNMAP allows the uffd monitor to track precisely changes in the
> virtual memory layout.
> 
> Since there might be different uffd contexts for the affected VMAs, we
> first should create a temporary representation for the unmap event for each
> uffd context and then notify them one by one to the appropriate userfault
> file descriptors.
> 
> The event notification occurs after the mmap_sem has been released.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

This breaks NOMMU compilation
---
