Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id C85D06B0253
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 15:42:41 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id 126so121374455ybo.4
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 12:42:41 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id v77si14960136ywc.267.2016.12.13.12.42.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 12:42:40 -0800 (PST)
Date: Tue, 13 Dec 2016 15:42:31 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 0/6 v3] dax: Page invalidation fixes
Message-ID: <20161213204231.k2kdsdxqgtqjqzo4@thunk.org>
References: <20161212164708.23244-1-jack@suse.cz>
 <20161213115209.GG15362@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161213115209.GG15362@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@ml01.01.org

On Tue, Dec 13, 2016 at 12:52:09PM +0100, Jan Kara wrote:
> OK, with the final ack from Johannes and since this is mostly DAX stuff,
> can we take this through NVDIMM tree and push to Linus either late in the
> merge window or for -rc2? These patches require my DAX patches sitting in mm
> tree so they can be included in any git tree only once those patches land
> in Linus' tree (which may happen only once Dave and Ted push out their
> stuff - this is the most convoluted merge window I'd ever to deal with ;-)...
> Dan?

I've sent out the pull request for ext4.... which includes the
dax-4.0-iomap-pmd and fscrypt branch.  Yes, convoluted.  :-)

		      	      	       	    - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
