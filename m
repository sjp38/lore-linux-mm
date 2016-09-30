Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 274466B0038
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 05:07:51 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 7so64021943pfa.2
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 02:07:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id s89si18945711pfi.286.2016.09.30.02.07.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Sep 2016 02:07:48 -0700 (PDT)
Date: Fri, 30 Sep 2016 02:07:48 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 01/20] mm: Change type of vmf->virtual_address
Message-ID: <20160930090748.GA24352@infradead.org>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-2-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474992504-20133-2-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Looks fine,

Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
