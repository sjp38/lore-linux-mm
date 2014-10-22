Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 84E9B6B0073
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 08:14:11 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id v10so235312qac.39
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 05:14:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r8si27547476qaj.16.2014.10.22.05.14.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Oct 2014 05:14:10 -0700 (PDT)
Date: Wed, 22 Oct 2014 14:14:03 +0200
From: Petr Holasek <pholasek@redhat.com>
Subject: Re: [RFC][PATCH] add pagesize field to /proc/pid/numa_maps
Message-ID: <20141022121403.GI2804@localhost.localdomain>
References: <1413847634-20039-1-git-send-email-pholasek@redhat.com>
 <alpine.DEB.2.02.1410201803540.2345@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1410201803540.2345@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>

On Mon, 20 Oct 2014, David Rientjes <rientjes@google.com> wrote:
> On Tue, 21 Oct 2014, Petr Holasek wrote:
> 
> > There were some similar attempts to add vma's pagesize to numa_maps in the past,
> > so I've distilled the most straightforward one - adding pagesize field
> > expressing size in kbytes to each line. Although page size can be also obtained
> > from smaps file, adding pagesize to numa_maps makes the interface more compact
> > and easier to use without need for traversing other files.
> > 
> > New numa_maps output looks like that:
> > 
> > 2aaaaac00000 default file=/dev/hugepages/hugepagefile huge pagesize=2097152 dirty=1 N0=1
> > 7f302441a000 default file=/usr/lib64/libc-2.17.so pagesize=4096 mapped=65 mapmax=38 N0=65
> > 
> > Signed-off-by: Petr Holasek <pholasek@redhat.com>
> 
> I guess the existing "huge" is insufficient on platforms that support 
> multiple hugepage sizes.

Why do you think so? pagesize= could also distinguish between multiple hugepage
sizes.

-- 
Petr Holasek
pholasek@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
