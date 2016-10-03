Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1B6246B0069
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 05:32:53 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id rz1so12613737pab.0
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 02:32:53 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id ft3si36125424pad.98.2016.10.03.02.32.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Oct 2016 02:32:52 -0700 (PDT)
Date: Mon, 3 Oct 2016 02:32:48 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/20 v3] dax: Clear dirty bits after flushing caches
Message-ID: <20161003093248.GA27720@infradead.org>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <20160930091418.GC24352@infradead.org>
 <20161003075902.GG6457@quack2.suse.cz>
 <20161003080337.GA13688@infradead.org>
 <20161003081549.GH6457@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161003081549.GH6457@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Oct 03, 2016 at 10:15:49AM +0200, Jan Kara wrote:
> Yeah, so DAX path is special because it installs its own PTE directly from
> the fault handler which we don't do in any other case (only driver fault
> handlers commonly do this but those generally don't care about
> ->page_mkwrite or file mappings for that matter).
> 
> I don't say there are no simplifications or unifications possible, but I'd
> prefer to leave them for a bit later once the current churn with ongoing
> work somewhat settles...

Allright, let's keep it simple for now.  Being said this series clearly
is 4.9 material, but any chance to get a respin of the invalidate_pages
series as that might still be 4.8 material?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
