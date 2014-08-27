Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id CC0156B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 17:31:01 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so1392815pad.37
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 14:31:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id if4si2983463pbb.22.2014.08.27.14.30.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Aug 2014 14:30:58 -0700 (PDT)
Date: Wed, 27 Aug 2014 14:30:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 00/21] Support ext4 on NV-DIMMs
Message-Id: <20140827143055.5210c5fb9696e460b456eb26@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.11.1408271616070.17080@gentwo.org>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
	<20140827130613.c8f6790093d279a447196f17@linux-foundation.org>
	<alpine.DEB.2.11.1408271616070.17080@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Wed, 27 Aug 2014 16:22:20 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:

> > Some explanation of why one would use ext4 instead of, say,
> > suitably-modified ramfs/tmpfs/rd/etc?
> 
> The NVDIMM contents survive reboot and therefore ramfs and friends wont
> work with it.

See "suitably modified".  Presumably this type of memory would need to
come from a particular page allocator zone.  ramfs would be unweildy
due to its use to dentry/inode caches, but rd/etc should be feasible.

I dunno, I'm not proposing implementations - I'm asking obvious
questions.  Stuff which should have been addressed in the changelogs
before one even starts to read the code...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
