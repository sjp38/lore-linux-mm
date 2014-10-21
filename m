Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id B0FC96B0069
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 21:05:03 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id tr6so183198ieb.30
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 18:05:03 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com. [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id n2si14751952iga.1.2014.10.20.18.05.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Oct 2014 18:05:03 -0700 (PDT)
Received: by mail-ie0-f178.google.com with SMTP id rl12so198883iec.9
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 18:05:02 -0700 (PDT)
Date: Mon, 20 Oct 2014 18:05:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH] add pagesize field to /proc/pid/numa_maps
In-Reply-To: <1413847634-20039-1-git-send-email-pholasek@redhat.com>
Message-ID: <alpine.DEB.2.02.1410201803540.2345@chino.kir.corp.google.com>
References: <1413847634-20039-1-git-send-email-pholasek@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Holasek <pholasek@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>

On Tue, 21 Oct 2014, Petr Holasek wrote:

> There were some similar attempts to add vma's pagesize to numa_maps in the past,
> so I've distilled the most straightforward one - adding pagesize field
> expressing size in kbytes to each line. Although page size can be also obtained
> from smaps file, adding pagesize to numa_maps makes the interface more compact
> and easier to use without need for traversing other files.
> 
> New numa_maps output looks like that:
> 
> 2aaaaac00000 default file=/dev/hugepages/hugepagefile huge pagesize=2097152 dirty=1 N0=1
> 7f302441a000 default file=/usr/lib64/libc-2.17.so pagesize=4096 mapped=65 mapmax=38 N0=65
> 
> Signed-off-by: Petr Holasek <pholasek@redhat.com>

I guess the existing "huge" is insufficient on platforms that support 
multiple hugepage sizes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
