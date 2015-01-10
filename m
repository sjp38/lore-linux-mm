Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 774196B0032
	for <linux-mm@kvack.org>; Fri,  9 Jan 2015 19:41:46 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id l2so10840680wgh.7
        for <linux-mm@kvack.org>; Fri, 09 Jan 2015 16:41:45 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id u9si22293898wja.95.2015.01.09.16.41.45
        for <linux-mm@kvack.org>;
        Fri, 09 Jan 2015 16:41:45 -0800 (PST)
Date: Sat, 10 Jan 2015 02:41:43 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm/page_alloc.c: drop dead destroy_compound_page()
Message-ID: <20150110004143.GA32424@node.dhcp.inet.fi>
References: <1420458382-161038-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20150107134039.25d4edfad92b62f3eee8b570@linux-foundation.org>
 <20150108141004.AB3461A2@black.fi.intel.com>
 <20150109162419.b52796aee45d6747399d2ebb@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150109162419.b52796aee45d6747399d2ebb@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, aarcange@redhat.com, linux-mm@kvack.org

On Fri, Jan 09, 2015 at 04:24:19PM -0800, Andrew Morton wrote:
> On Thu,  8 Jan 2015 16:10:04 +0200 (EET) "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > Something like this?
> > 
> > >From 5fd481c1c521112e9cea407f5a2644c9f93d0e14 Mon Sep 17 00:00:00 2001
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > Date: Thu, 8 Jan 2015 15:59:23 +0200
> > Subject: [PATCH] mm: more checks on free_pages_prepare() for tail pages
> > 
> > Apart form being dead, destroy_compound_page() did some potentially
> > useful checks. Let's re-introduce them in free_pages_prepare(), where
> > they can be acctually triggered.
> > 
> > compound_order() assert is already in free_pages_prepare(). We have few
> > checks for tail pages left.
> > 
> 
> I'm thinking we avoid the overhead unless CONFIG_DEBUG_VM?

That's why there's "if (!IS_ENABLED(CONFIG_DEBUG_VM))". Is it wrong in
some way?
I didn't check, but I assume compiler is smart enough to get rid of
free_tail_pages_check() if CONFIG_DEBUG_VM is not defined. No?


-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
