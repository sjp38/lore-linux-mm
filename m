Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3FFCC6B0279
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 12:34:54 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id g7so118978637pgr.3
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 09:34:54 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id x11si8258182pff.83.2017.06.19.09.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 09:34:53 -0700 (PDT)
Date: Mon, 19 Jun 2017 10:34:52 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH] dax: Fix inefficiency in dax_writeback_mapping_range()
Message-ID: <20170619163452.GA27087@linux.intel.com>
References: <20170619124531.21491-1-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170619124531.21491-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, stable@vger.kernel.org

On Mon, Jun 19, 2017 at 02:45:31PM +0200, Jan Kara wrote:
> dax_writeback_mapping_range() fails to update iteration index when
> searching radix tree for entries needing cache flushing. Thus each
> pagevec worth of entries is searched starting from the start which is
> inefficient and prone to livelocks. Update index properly.
> 
> CC: stable@vger.kernel.org
> Fixes: 9973c98ecfda3a1dfcab981665b5f1e39bcde64a
> Signed-off-by: Jan Kara <jack@suse.cz>

Yep, this seems good, thanks.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
