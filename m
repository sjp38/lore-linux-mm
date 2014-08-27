Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id E58576B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 19:04:55 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id mc6so207841lab.1
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 16:04:54 -0700 (PDT)
Received: from lxorguk.ukuu.org.uk (7.3.c.8.2.a.e.f.f.f.8.1.0.3.2.0.9.6.0.7.2.3.f.b.0.b.8.0.1.0.0.2.ip6.arpa. [2001:8b0:bf32:7069:230:18ff:fea2:8c37])
        by mx.google.com with ESMTPS id mq2si2833256lbb.9.2014.08.27.16.04.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Aug 2014 16:04:53 -0700 (PDT)
Date: Thu, 28 Aug 2014 00:04:40 +0100
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v10 00/21] Support ext4 on NV-DIMMs
Message-ID: <20140828000440.5d9f5bff@alan.etchedpixels.co.uk>
In-Reply-To: <20140827143055.5210c5fb9696e460b456eb26@linux-foundation.org>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
	<20140827130613.c8f6790093d279a447196f17@linux-foundation.org>
	<alpine.DEB.2.11.1408271616070.17080@gentwo.org>
	<20140827143055.5210c5fb9696e460b456eb26@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Wed, 27 Aug 2014 14:30:55 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 27 Aug 2014 16:22:20 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:
> 
> > > Some explanation of why one would use ext4 instead of, say,
> > > suitably-modified ramfs/tmpfs/rd/etc?
> > 
> > The NVDIMM contents survive reboot and therefore ramfs and friends wont
> > work with it.
> 
> See "suitably modified".  Presumably this type of memory would need to
> come from a particular page allocator zone.  ramfs would be unweildy
> due to its use to dentry/inode caches, but rd/etc should be feasible.

If you took one of the existing ramfs types you would then need to

- make it persistent in its storage, and put all the objects in the store
- add journalling for failures mid transaction. Your dimm may retain its
  bits but if your CPU reset mid fs operation its got to be recovered
- write an fsck tool for it
- validate it

at which point it's probably turned into ext4 8)

It's persistent but that doesn't solve the 'my box crashed' problem. 

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
