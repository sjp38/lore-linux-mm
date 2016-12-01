Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 105C36B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 17:13:13 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x23so124629326pgx.6
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 14:13:13 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id j26si1826609pfj.194.2016.12.01.14.13.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 14:13:12 -0800 (PST)
Date: Thu, 1 Dec 2016 15:13:11 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 4/6] dax: Finish fault completely when loading holes
Message-ID: <20161201221311.GA13739@linux.intel.com>
References: <1479980796-26161-1-git-send-email-jack@suse.cz>
 <1479980796-26161-5-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479980796-26161-5-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Johannes Weiner <hannes@cmpxchg.org>

On Thu, Nov 24, 2016 at 10:46:34AM +0100, Jan Kara wrote:
> The only case when we do not finish the page fault completely is when we
> are loading hole pages into a radix tree. Avoid this special case and
> finish the fault in that case as well inside the DAX fault handler. It
> will allow us for easier iomap handling.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

This seems correct to me.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
