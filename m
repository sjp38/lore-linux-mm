Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 272FC6B026C
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 11:01:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y15-v6so1432277eds.14
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 08:01:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e19-v6si1827608eja.24.2018.10.02.08.01.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 08:01:30 -0700 (PDT)
Date: Tue, 2 Oct 2018 17:01:24 +0200
From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181002150123.GD4963@linux-x5ow.site>
References: <20181002100531.GC4135@quack2.suse.cz>
 <20181002121039.GA3274@linux-x5ow.site>
 <20181002142010.GB4963@linux-x5ow.site>
 <20181002144547.GA26735@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181002144547.GA26735@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, mhocko@suse.cz, Dan Williams <dan.j.williams@intel.com>

On Tue, Oct 02, 2018 at 07:45:47AM -0700, Christoph Hellwig wrote:
> How does an application "make use of DAX"?  What actual user visible
> semantics are associated with a file that has this flag set?

There may not be any user visible semantics of DAX, but there are
promises we gave to application developers praising DAX as _the_
method to map data on persistent memory and get around "the penalty of
the page cache" (however big this is).

As I said in another mail to this thread, applications have started to
poke in procfs to see whether they can use DAX or not.

Party A has promised party B something and they started checking for
it, then commit e1fb4a086495 "dax: remove VM_MIXEDMAP for fsdax and
device dax" removed the way they checked if the kernel can keep up
with this promise.

So technically e1fb4a086495 is a user visible regression and in the
past we have reverted patches introducing these, even if the patch is
generally correct and poking in /proc/self/smaps is a bad idea.

I just wanted to give them a documented way to check for this
promise. Being neutral if this promise is right or wrong, good or bad,
or whatever. That's not my call, but I prefer not having angry users,
yelling at me because of broken applications.

Byte,
	Johannes
-- 
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nurnberg
GF: Felix Imendorffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nurnberg)
Key fingerprint = EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
