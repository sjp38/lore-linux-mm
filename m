Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 068A36B000A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 02:25:28 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h37-v6so6054697pgh.4
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 23:25:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a6-v6si6913128pgw.391.2018.10.04.23.25.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Oct 2018 23:25:26 -0700 (PDT)
Date: Thu, 4 Oct 2018 23:25:24 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181005062524.GA30582@infradead.org>
References: <20181002100531.GC4135@quack2.suse.cz>
 <20181002121039.GA3274@linux-x5ow.site>
 <20181002142010.GB4963@linux-x5ow.site>
 <20181002144547.GA26735@infradead.org>
 <20181002150123.GD4963@linux-x5ow.site>
 <20181002150634.GA22209@infradead.org>
 <20181004100949.GF6682@linux-x5ow.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181004100949.GF6682@linux-x5ow.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, mhocko@suse.cz, Dan Williams <dan.j.williams@intel.com>

On Thu, Oct 04, 2018 at 12:09:49PM +0200, Johannes Thumshirn wrote:
> On Tue, Oct 02, 2018 at 08:06:34AM -0700, Christoph Hellwig wrote:
> > There is no promise, sorry.
> 
> Well there have been lot's of articles on for instance lwn.net [1] [2]
> [3] describing how to avoid the "overhead" of the page cache when
> running on persistent memory.

Since when is an article on some website a promise (of what exactly)
by linux kernel developers?
