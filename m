Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C52746B0401
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 19:07:08 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id w189so135213627pfb.4
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 16:07:08 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id d2si7879813pli.110.2017.03.09.16.07.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 16:07:08 -0800 (PST)
Date: Thu, 9 Mar 2017 17:07:07 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 2/9] mm: drop "wait" parameter from write_one_page
Message-ID: <20170310000707.GB30285@linux.intel.com>
References: <20170308162934.21989-1-jlayton@redhat.com>
 <20170308162934.21989-3-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170308162934.21989-3-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@zeniv.linux.org.uk, akpm@linux-foundation.org, konishi.ryusuke@lab.ntt.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nilfs@vger.kernel.org, ross.zwisler@linux.intel.com, jack@suse.cz, neilb@suse.com, openosd@gmail.com, adilger@dilger.ca, James.Bottomley@HansenPartnership.com

On Wed, Mar 08, 2017 at 11:29:27AM -0500, Jeff Layton wrote:
> The callers all set it to 1. Also, make it clear that this function will
> not set any sort of AS_* error, and that the caller must do so if
> necessary. No existing caller uses this on normal files, so none of them
> need it.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
