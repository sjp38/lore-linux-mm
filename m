Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CBA9B6B0253
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 15:12:16 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so24407520wme.1
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 12:12:16 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id 38si1053505ljb.70.2016.07.26.12.12.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jul 2016 12:12:15 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id f93so889971lfi.0
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 12:12:15 -0700 (PDT)
Date: Tue, 26 Jul 2016 22:12:12 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv1, RFC 00/33] ext4: support of huge pages
Message-ID: <20160726191212.GA11776@node.shutemov.name>
References: <1469493335-3622-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160726172938.GA9284@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160726172938.GA9284@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Tue, Jul 26, 2016 at 01:29:38PM -0400, Theodore Ts'o wrote:
> On Tue, Jul 26, 2016 at 03:35:02AM +0300, Kirill A. Shutemov wrote:
> > Here's the first version of my patchset which intended to bring huge pages
> > to ext4. It's not yet ready for applying or serious use, but good enough
> > to show the approach.
> 
> Thanks.  The major issues I noticed when doing a quick scan of the
> patches you've already mentioned here.  I'll try to take a closer look
> in the next week or so when I have time.

Thanks.

> One random question --- in the huge=always approach, how much
> additional work would be needed to support file systems with a 64k
> block size on a system with 4k pages?

I think it's totally different story.

Here I have block size smaller than page size and it's not new to the
filesystem -- similar to 1k block size with 4k page size. So I was able to
re-use most of infrastructure to handle the situation.

Block size bigger than page size is backward task. I don't think I know
enough to understand how hard it would be. I guess not easy. :)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
