Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D9916B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 07:12:48 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w63so4851778wrc.5
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 04:12:48 -0700 (PDT)
Received: from mail-wr0-x22f.google.com (mail-wr0-x22f.google.com. [2a00:1450:400c:c0c::22f])
        by mx.google.com with ESMTPS id p31si893881edb.358.2017.08.16.04.12.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 04:12:47 -0700 (PDT)
Received: by mail-wr0-x22f.google.com with SMTP id m57so12537526wrm.5
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 04:12:46 -0700 (PDT)
Date: Wed, 16 Aug 2017 14:12:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v5 4/5] fs, xfs: introduce MAP_DIRECT for creating
 block-map-atomic file ranges
Message-ID: <20170816111244.uxx6kvbi3cn5clqd@node.shutemov.name>
References: <150286944610.8837.9513410258028246174.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150286946864.8837.17147962029964281564.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150286946864.8837.17147962029964281564.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-api@vger.kernel.org, linux-nvdimm@lists.01.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, luto@kernel.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

On Wed, Aug 16, 2017 at 12:44:28AM -0700, Dan Williams wrote:
> @@ -1411,6 +1422,9 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
>  
>  			/* fall through */
>  		case MAP_PRIVATE:
> +			if ((flags & (MAP_PRIVATE|MAP_DIRECT))
> +					== (MAP_PRIVATE|MAP_DIRECT))
> +				return -EINVAL;

We've already checked for MAP_PRIVATE in this codepath. Simple (flags &
MAP_DIRECT) would be enough.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
