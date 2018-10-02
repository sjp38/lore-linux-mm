Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id F2F786B0276
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 10:52:09 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d40-v6so2967015pla.14
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 07:52:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l129-v6si12958337pga.219.2018.10.02.07.52.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Oct 2018 07:52:09 -0700 (PDT)
Date: Tue, 2 Oct 2018 07:52:06 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181002145206.GA10903@infradead.org>
References: <20181002100531.GC4135@quack2.suse.cz>
 <20181002121039.GA3274@linux-x5ow.site>
 <20181002142959.GD9127@quack2.suse.cz>
 <20181002143713.GA19845@infradead.org>
 <20181002144412.GC4963@linux-x5ow.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181002144412.GC4963@linux-x5ow.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org

On Tue, Oct 02, 2018 at 04:44:13PM +0200, Johannes Thumshirn wrote:
> On Tue, Oct 02, 2018 at 07:37:13AM -0700, Christoph Hellwig wrote:
> > No, it should not.  DAX is an implementation detail thay may change
> > or go away at any time.
> 
> Well we had an issue with an application checking for dax, this is how
> we landed here in the first place.

So what exacty is that "DAX" they are querying about (and no, I'm not
joking, nor being philosophical).
