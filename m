Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2CC6B0304
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 19:04:52 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f188so120489754pgc.1
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 16:04:52 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n62si28724104pfa.62.2016.11.15.16.04.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 16:04:50 -0800 (PST)
Date: Tue, 15 Nov 2016 16:04:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: add ZONE_DEVICE statistics to smaps
Message-Id: <20161115160449.2b34c771aad710a8c8e06be0@linux-foundation.org>
In-Reply-To: <147881591739.39198.1358237993213024627.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <147881591739.39198.1358237993213024627.stgit@dwillia2-desk3.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-nvdimm@ml01.01.org, Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 10 Nov 2016 14:11:57 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> ZONE_DEVICE pages are mapped into a process via the filesystem-dax and
> device-dax mechanisms.  There are also proposals to use ZONE_DEVICE
> pages for other usages outside of dax.  Add statistics to smaps so
> applications can debug that they are obtaining the mappings they expect,
> or otherwise accounting them.
> 
> ...
>
>  fs/proc/task_mmu.c |   10 +++++++++-

Please update Documentation/filesystems/proc.txt.

(While there, please check to see if anything else is missed?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
