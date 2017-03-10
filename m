Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 398386B0400
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 19:06:51 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e129so136231410pfh.1
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 16:06:51 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e39si7859572plg.309.2017.03.09.16.06.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 16:06:50 -0800 (PST)
Date: Thu, 9 Mar 2017 17:06:48 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 1/9] mm: fix mapping_set_error call in
 me_pagecache_dirty
Message-ID: <20170310000648.GA30285@linux.intel.com>
References: <20170308162934.21989-1-jlayton@redhat.com>
 <20170308162934.21989-2-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170308162934.21989-2-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@zeniv.linux.org.uk, akpm@linux-foundation.org, konishi.ryusuke@lab.ntt.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org, ross.zwisler@linux.intel.com, jack@suse.cz, neilb@suse.com, openosd@gmail.com, adilger@dilger.ca, James.Bottomley@HansenPartnership.com

On Wed, Mar 08, 2017 at 11:29:26AM -0500, Jeff Layton wrote:
> The error code should be negative. Since this ends up in the default
> case anyway, this is harmless, but it's less confusing to negate it.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
