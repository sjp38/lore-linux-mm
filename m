Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2136A6B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 13:08:07 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id 4so140433988pfd.0
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 10:08:07 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id tr1si11252723pab.135.2016.03.21.10.08.06
        for <linux-mm@kvack.org>;
        Mon, 21 Mar 2016 10:08:06 -0700 (PDT)
Date: Mon, 21 Mar 2016 20:07:53 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 1/3] mm, fs: get rid of PAGE_CACHE_* and
 page_cache_{get,release} macros
Message-ID: <20160321170753.GB141158@black.fi.intel.com>
References: <1458561998-126622-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1458561998-126622-2-git-send-email-kirill.shutemov@linux.intel.com>
 <CA+55aFx=E66fSEFu5brOsyCgYWXhyNzGjHmN-JZFmXdeVywpqg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFx=E66fSEFu5brOsyCgYWXhyNzGjHmN-JZFmXdeVywpqg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Mon, Mar 21, 2016 at 10:02:23AM -0700, Linus Torvalds wrote:
> On Mon, Mar 21, 2016 at 5:06 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> >
> > This patch contains automated changes generated with coccinelle using
> > script below. For some reason, coccinelle doesn't patch header files.
> > I've called spatch for them manually.
> 
> Looks good.
> 
> Mind reminding me and re-sending the patches about this after the
> merge window is over? Maybe around rc2 or so?

Sure.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
