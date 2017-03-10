Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A811C280903
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 19:21:08 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 77so133047359pgc.5
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 16:21:08 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id b185si1205444pfg.247.2017.03.09.16.21.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 16:21:07 -0800 (PST)
Date: Thu, 9 Mar 2017 17:21:06 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 5/9] dax: set error in mapping when writeback fails
Message-ID: <20170310002106.GD30285@linux.intel.com>
References: <20170308162934.21989-1-jlayton@redhat.com>
 <20170308162934.21989-6-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170308162934.21989-6-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@zeniv.linux.org.uk, akpm@linux-foundation.org, konishi.ryusuke@lab.ntt.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org, ross.zwisler@linux.intel.com, jack@suse.cz, neilb@suse.com, openosd@gmail.com, adilger@dilger.ca, James.Bottomley@HansenPartnership.com

On Wed, Mar 08, 2017 at 11:29:30AM -0500, Jeff Layton wrote:
> In order to get proper error codes from fsync, we must set an error in
> the mapping range when writeback fails.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Yep, paired with the changes to filmap_write_and_wait() and
filemap_write_and_wait_range(), this seems fine.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
