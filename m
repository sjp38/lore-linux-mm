Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8FBD96B0255
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 13:37:52 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so41681978pac.3
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 10:37:52 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id yt2si4780834pbb.196.2015.08.13.10.37.50
        for <linux-mm@kvack.org>;
        Thu, 13 Aug 2015 10:37:51 -0700 (PDT)
Message-ID: <55CCD5EC.8000509@sr71.net>
Date: Thu, 13 Aug 2015 10:37:48 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH v5 2/5] allow mapping page-less memremaped areas into
 KVA
References: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com> <20150813030109.36703.21738.stgit@otcpl-skl-sds-2.jf.intel.com> <55CC3222.5090503@plexistor.com> <20150813143744.GA17375@lst.de> <55CCAE57.20009@plexistor.com>
In-Reply-To: <55CCAE57.20009@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org, axboe@kernel.dk, riel@redhat.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, mgorman@suse.de, torvalds@linux-foundation.org

On 08/13/2015 07:48 AM, Boaz Harrosh wrote:
> There is already an object that holds a relationship of physical
> to Kernel-virtual. It is called a memory-section. Why not just
> widen its definition?

Memory sections are purely there to map physical address ranges back to
metadata about them.  *Originally* for 'struct page', but widened a bit
subsequently.  But, it's *never* been connected to kernel-virtual
addresses in any way that I can think of.

So, that's a curious statement.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
