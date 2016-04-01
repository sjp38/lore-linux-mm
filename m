Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2480A6B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 21:33:33 -0400 (EDT)
Received: by mail-io0-f170.google.com with SMTP id q128so132896986iof.3
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 18:33:33 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id a7si13231781ioe.40.2016.03.31.18.33.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 18:33:31 -0700 (PDT)
Received: by mail-ig0-x22d.google.com with SMTP id ma7so5354883igc.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 18:33:31 -0700 (PDT)
Date: Thu, 31 Mar 2016 20:33:29 -0500
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: Bloat caused by unnecessary calls to compound_head()?
Message-ID: <20160401013329.GB1323@zzz>
References: <20160326185049.GA4257@zzz>
 <20160327194649.GA9638@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160327194649.GA9638@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, Hugh Dickins <hughd@google.com>

On Sun, Mar 27, 2016 at 10:46:49PM +0300, Kirill A. Shutemov wrote:
> The idea is to introduce new type to indicate head page --
> 'struct head_page' -- it's compatible with struct page on memory layout,
> but distinct from C point of view. compound_head() should return pointer
> of that type. For the proof-of-concept I've introduced new helper --
> compound_head_t().
> 

Well, it's good for optimizing the specific case of mark_page_accessed().  I'm
more worried about the general level of bloat, since the Page* macros are used
in so many places.  And generating page-flags.h with a script is something to be
avoided if at all possible.

I wasn't following the discussion around the original page-flags patchset.  Can
you point me to a discussion of the benefits of the page "policy" checks --- why
are they suddenly needed when they weren't before?  Or any helpful comments in
the code?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
