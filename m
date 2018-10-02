Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 17FAB6B0270
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 11:31:03 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e5-v6so1496555eda.4
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 08:31:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m21-v6si802956edj.236.2018.10.02.08.31.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 08:31:01 -0700 (PDT)
Date: Tue, 2 Oct 2018 17:31:00 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181002153100.GG9127@quack2.suse.cz>
References: <20181002100531.GC4135@quack2.suse.cz>
 <20181002121039.GA3274@linux-x5ow.site>
 <20181002142959.GD9127@quack2.suse.cz>
 <20181002143713.GA19845@infradead.org>
 <20181002144412.GC4963@linux-x5ow.site>
 <20181002145206.GA10903@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181002145206.GA10903@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Johannes Thumshirn <jthumshirn@suse.de>, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org

On Tue 02-10-18 07:52:06, Christoph Hellwig wrote:
> On Tue, Oct 02, 2018 at 04:44:13PM +0200, Johannes Thumshirn wrote:
> > On Tue, Oct 02, 2018 at 07:37:13AM -0700, Christoph Hellwig wrote:
> > > No, it should not.  DAX is an implementation detail thay may change
> > > or go away at any time.
> > 
> > Well we had an issue with an application checking for dax, this is how
> > we landed here in the first place.
> 
> So what exacty is that "DAX" they are querying about (and no, I'm not
> joking, nor being philosophical).

I believe the application we are speaking about is mostly concerned about
the memory overhead of the page cache. Think of a machine that has ~ 1TB of
DRAM, the database running on it is about that size as well and they want
database state stored somewhere persistently - which they may want to do by
modifying mmaped database files if they do small updates... So they really
want to be able to use close to all DRAM for the DB and not leave slack
space for the kernel page cache to cache 1TB of database files.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
