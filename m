Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A8AA56B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 11:30:03 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 144so30794070pfv.5
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 08:30:03 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id d85si32021826pfb.163.2016.11.07.08.03.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 08:03:22 -0800 (PST)
Date: Mon, 7 Nov 2016 19:03:17 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 15/41] filemap: handle huge pages in
 do_generic_file_read()
Message-ID: <20161107160317.jwdbqopivo7g2j2i@black.fi.intel.com>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
 <20160915115523.29737-16-kirill.shutemov@linux.intel.com>
 <20161013093313.GB26241@quack2.suse.cz>
 <20161031181035.GA7007@node.shutemov.name>
 <20161101163940.GA5459@quack2.suse.cz>
 <20161102143612.GA4790@infradead.org>
 <20161107111305.GB13280@node.shutemov.name>
 <20161107150103.GA17451@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161107150103.GA17451@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Jan Kara <jack@suse.cz>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Mon, Nov 07, 2016 at 07:01:03AM -0800, Christoph Hellwig wrote:
> On Mon, Nov 07, 2016 at 02:13:05PM +0300, Kirill A. Shutemov wrote:
> > It looks like a huge limitation to me.
> 
> The DAX PMD fault code can live just fine with it.

There's no way out for DAX as we map backing storage directly into
userspace. There's no such limitation for page-cache. And I don't see a
point to introduce such limitation artificially.

Backing storage fragmentation can be a weight on decision whether we want
to allocate huge page, but it shouldn't be show-stopper.

> And without it performance would suck anyway.

It depends on workload, obviously.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
