Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A54C6B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 17:00:17 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q21-v6so5601895pff.4
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 14:00:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d31-v6si6747455pla.190.2018.07.05.14.00.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 05 Jul 2018 14:00:15 -0700 (PDT)
Date: Thu, 5 Jul 2018 14:00:07 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 13/13] libnvdimm, namespace: Publish page structure init
 state / control
Message-ID: <20180705210007.GC28447@bombadil.infradead.org>
References: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153077341292.40830.11333232703318633087.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180705082931.echvdqipgvwhghf2@linux-x5ow.site>
 <CAPcyv4h1L6ZMCqWXhWD_ZJ=sH7SVzuUGMG2Ln=6Cy6sR4S=VUw@mail.gmail.com>
 <20180705144941.drfiwhqcnqqorqu3@linux-x5ow.site>
 <20180705132455.2a40de08dbe3a9bb384fb870@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180705132455.2a40de08dbe3a9bb384fb870@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Thumshirn <jthumshirn@suse.de>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Vishal Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, Jeff Moyer <jmoyer@redhat.com>, Christoph Hellwig <hch@lst.de>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jul 05, 2018 at 01:24:55PM -0700, Andrew Morton wrote:
> On Thu, 5 Jul 2018 16:49:41 +0200 Johannes Thumshirn <jthumshirn@suse.de> wrote:
> 
> > On Thu, Jul 05, 2018 at 07:46:05AM -0700, Dan Williams wrote:
> > > ...but that also allows 'echo "syncAndThenSomeGarbage" >
> > > /sys/.../memmap_state' to succeed.
> > 
> > Yep it does :-(.
> > 
> > Damn
> 
> sysfs_streq()

Thanks!  I didn't know that one existed.

It's kind of a shame that we realised this was a problem and decided
to solve it this way back in 2008 instead of realising that no driver
actually cares whether there's a \n or not and stripping off the \n
before the driver gets to see it.  Probably too late to fix that now.
