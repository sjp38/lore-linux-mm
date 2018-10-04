Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CF0606B0269
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 06:09:51 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g36-v6so5236270edb.3
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 03:09:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h4-v6si2269124ejx.230.2018.10.04.03.09.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 03:09:50 -0700 (PDT)
Date: Thu, 4 Oct 2018 12:09:49 +0200
From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181004100949.GF6682@linux-x5ow.site>
References: <20181002100531.GC4135@quack2.suse.cz>
 <20181002121039.GA3274@linux-x5ow.site>
 <20181002142010.GB4963@linux-x5ow.site>
 <20181002144547.GA26735@infradead.org>
 <20181002150123.GD4963@linux-x5ow.site>
 <20181002150634.GA22209@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181002150634.GA22209@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, mhocko@suse.cz, Dan Williams <dan.j.williams@intel.com>

On Tue, Oct 02, 2018 at 08:06:34AM -0700, Christoph Hellwig wrote:
> There is no promise, sorry.

Well there have been lot's of articles on for instance lwn.net [1] [2]
[3] describing how to avoid the "overhead" of the page cache when
running on persistent memory.

So if I would be a database developer, I'd look into them and see how
I could exploit this for my needs.

So even if we don't want to call it a promise, it was at least an
advertisement and people are now taking our word for it.

[1] https://lwn.net/Articles/610174/
[2] https://lwn.net/Articles/717953/
[3] https://lwn.net/Articles/684828/ 

Byte,
	      Johannes
-- 
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nurnberg
GF: Felix Imendorffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nurnberg)
Key fingerprint = EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
