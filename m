Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7EE7A6B0037
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 14:57:44 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id fp1so69340pdb.23
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 11:57:44 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id hp1si3225680pad.57.2014.04.24.11.57.43
        for <linux-mm@kvack.org>;
        Thu, 24 Apr 2014 11:57:43 -0700 (PDT)
Date: Thu, 24 Apr 2014 14:57:40 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v3 5/7] swap: Use bdev_read_page() / bdev_write_page()
Message-ID: <20140424185740.GE5886@linux.intel.com>
References: <cover.1397429628.git.matthew.r.wilcox@intel.com>
 <9fb0b4031b0fba312963a7cc21bf258d944cddcf.1397429628.git.matthew.r.wilcox@intel.com>
 <20140424111817.9cc62b2ff1e368c5cf27d262@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140424111817.9cc62b2ff1e368c5cf27d262@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Thu, Apr 24, 2014 at 11:18:17AM -0700, Andrew Morton wrote:
> On Sun, 13 Apr 2014 18:59:54 -0400 Matthew Wilcox <matthew.r.wilcox@intel.com> wrote:
> 
> >  mm/page_io.c | 23 +++++++++++++++++++++--
> >  1 file changed, 21 insertions(+), 2 deletions(-)
> 
> Some changelog here would be nice.  What were the reasons for the
> change?  Any observable performance changes?

Whoops ... I could swear I wrote one.  Wonder what happened to it.  Here
was all I had:

We can avoid allocating a BIO if we use the writepage path instead of
the Direct I/O path.

But that's kind of lame.  I don't have any performance numbers right now,
so how about we go with:

By calling the device driver to write the page directly, we avoid
allocating a BIO, which allows us to free memory without allocating
memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
