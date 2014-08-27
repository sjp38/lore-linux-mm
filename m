Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 54FCD6B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 17:22:24 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so1362460pad.41
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 14:22:24 -0700 (PDT)
Received: from qmta11.emeryville.ca.mail.comcast.net (qmta11.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:211])
        by mx.google.com with ESMTP id du1si2508357pdb.189.2014.08.27.14.22.23
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 14:22:23 -0700 (PDT)
Date: Wed, 27 Aug 2014 16:22:20 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v10 00/21] Support ext4 on NV-DIMMs
In-Reply-To: <20140827130613.c8f6790093d279a447196f17@linux-foundation.org>
Message-ID: <alpine.DEB.2.11.1408271616070.17080@gentwo.org>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com> <20140827130613.c8f6790093d279a447196f17@linux-foundation.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Wed, 27 Aug 2014, Andrew Morton wrote:

> Sat down to read all this but I'm finding it rather unwieldy - it's
> just a great blob of code.  Is there some overall
> what-it-does-and-how-it-does-it roadmap?

Matthew gave a talk about DAX at the kernel summit. Its a great feature
because this is another piece of the bare metal hardware technology that
is being improved by him.

> Some explanation of why one would use ext4 instead of, say,
> suitably-modified ramfs/tmpfs/rd/etc?

The NVDIMM contents survive reboot and therefore ramfs and friends wont
work with it.

> Performance testing results?

This is obviously avoiding kernel buffering and therefore decreasing
kernel overhead for non volatile memory. Avoids useless duplication of
data from the non volatile memory into regular ram and allows direct
access to non volatile memory from user space in a controlled fashion.

I think this should be a priority item.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
