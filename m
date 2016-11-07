Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 73C856B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 09:59:15 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 144so29232149pfv.5
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 06:59:15 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id o1si8060106pge.141.2016.11.07.06.59.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 06:59:14 -0800 (PST)
Date: Mon, 7 Nov 2016 06:59:05 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCHv3 15/41] filemap: handle huge pages in
 do_generic_file_read()
Message-ID: <20161107145905.GA14668@infradead.org>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-16-kirill.shutemov@linux.intel.com>
 <20161013093313.GB26241@quack2.suse.cz>
 <20161031181035.GA7007@node.shutemov.name>
 <20161101163940.GA5459@quack2.suse.cz>
 <20161102083204.GB13949@node.shutemov.name>
 <20161103204012.GC24234@quack2.suse.cz>
 <20161107110736.GA13280@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161107110736.GA13280@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Mon, Nov 07, 2016 at 02:07:36PM +0300, Kirill A. Shutemov wrote:
> Just to clarify: is it show-stopper or we can live with buffer_head list
> for now?

I'm not Jan, but I will NAK anything that looks like the current THP
series.  It's a great prototype, but it also shows up all the area
that we need to fix first, and the buffer_head chain is one of them.

> Hm. Okay, I'll try to check what I can do to make it more maintainable.
> My worry is that it will make the patchset even bigger...

So start splitting out parts that are useful on their own, or spent
time on fixing fundamental underlying issues that will make it smaller
as a side effect.  That's how everyone else does kernel development.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
