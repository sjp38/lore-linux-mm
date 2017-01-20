Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A25816B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 12:39:32 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 201so105147436pfw.5
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 09:39:32 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id s77si7442988pfa.20.2017.01.20.09.39.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jan 2017 09:39:31 -0800 (PST)
Date: Fri, 20 Jan 2017 10:39:30 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH] truncate: use i_blocksize()
Message-ID: <20170120173930.GB28887@linux.intel.com>
References: <0a58b38c7ddfbbc8f56cb8d815114bd4357a6016.1484895399.git.geliangtang@gmail.com>
 <9c8b2cd83c8f5653805d43debde9fa8817e02fc4.1484895804.git.geliangtang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9c8b2cd83c8f5653805d43debde9fa8817e02fc4.1484895804.git.geliangtang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geliang Tang <geliangtang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 20, 2017 at 10:29:54PM +0800, Geliang Tang wrote:
> Since i_blocksize() helper has been defined in fs.h, use it instead
> of open-coding.
> 
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>

Sure this seems correct.
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
