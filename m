Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA5DB6B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 05:17:27 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 1so12465559wmz.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 02:17:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f3si6489228wma.80.2016.07.27.02.17.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jul 2016 02:17:26 -0700 (PDT)
Date: Wed, 27 Jul 2016 11:17:23 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCHv1, RFC 00/33] ext4: support of huge pages
Message-ID: <20160727091723.GG6860@quack2.suse.cz>
References: <1469493335-3622-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160726172938.GA9284@thunk.org>
 <20160726191212.GA11776@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160726191212.GA11776@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Theodore Ts'o <tytso@mit.edu>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Tue 26-07-16 22:12:12, Kirill A. Shutemov wrote:
> On Tue, Jul 26, 2016 at 01:29:38PM -0400, Theodore Ts'o wrote:
> > On Tue, Jul 26, 2016 at 03:35:02AM +0300, Kirill A. Shutemov wrote:
> > > Here's the first version of my patchset which intended to bring huge pages
> > > to ext4. It's not yet ready for applying or serious use, but good enough
> > > to show the approach.
> > 
> > Thanks.  The major issues I noticed when doing a quick scan of the
> > patches you've already mentioned here.  I'll try to take a closer look
> > in the next week or so when I have time.
> 
> Thanks.
> 
> > One random question --- in the huge=always approach, how much
> > additional work would be needed to support file systems with a 64k
> > block size on a system with 4k pages?
> 
> I think it's totally different story.
> 
> Here I have block size smaller than page size and it's not new to the
> filesystem -- similar to 1k block size with 4k page size. So I was able to
> re-use most of infrastructure to handle the situation.
> 
> Block size bigger than page size is backward task. I don't think I know
> enough to understand how hard it would be. I guess not easy. :)

I think Ted wanted to ask: When you always have huge pages in page cache,
block size of 64k is smaller than the page size of the page cache so there
are chances it could work. Or is there anything which still exposes the
fact that actual pages are 4k even in huge=always case?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
