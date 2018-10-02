Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 76AAC6B0005
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 10:45:49 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id e3-v6so2655783pld.13
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 07:45:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b20-v6si7772528pgk.360.2018.10.02.07.45.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Oct 2018 07:45:48 -0700 (PDT)
Date: Tue, 2 Oct 2018 07:45:47 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181002144547.GA26735@infradead.org>
References: <20181002100531.GC4135@quack2.suse.cz>
 <20181002121039.GA3274@linux-x5ow.site>
 <20181002142010.GB4963@linux-x5ow.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181002142010.GB4963@linux-x5ow.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, mhocko@suse.cz, Dan Williams <dan.j.williams@intel.com>

On Tue, Oct 02, 2018 at 04:20:10PM +0200, Johannes Thumshirn wrote:
>     Provide a F_GETDAX fcntl(2) command so an application can query
>     whether it can make use of DAX or not.

How does an application "make use of DAX"?  What actual user visible
semantics are associated with a file that has this flag set?
