Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E3CEC6B0038
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 01:28:33 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 3so14733094pgd.3
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 22:28:33 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y10si26769739pge.222.2016.11.21.22.28.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 22:28:32 -0800 (PST)
Date: Mon, 21 Nov 2016 22:28:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mm PATCH v3 21/23] mm: Add support for releasing multiple
 instances of a page
Message-Id: <20161121222829.30e2bf67c58af5f1c91d1a1b@linux-foundation.org>
In-Reply-To: <CAKgT0UfoS-JC66hHV14E-hgmrhGdz4oYpmHve=01A1X8o8O=rw@mail.gmail.com>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
	<20161110113606.76501.70752.stgit@ahduyck-blue-test.jf.intel.com>
	<20161118152716.3f7acf6e25f142846909b2f6@linux-foundation.org>
	<CAKgT0UfoS-JC66hHV14E-hgmrhGdz4oYpmHve=01A1X8o8O=rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, linux-mm <linux-mm@kvack.org>, Netdev <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, 21 Nov 2016 08:21:39 -0800 Alexander Duyck <alexander.duyck@gmail.com> wrote:

> >> +                     __free_pages_ok(page, order);
> >> +     }
> >> +}
> >> +EXPORT_SYMBOL(__page_frag_drain);
> >
> > It's an exported-to-modules library function.  It should be documented,
> > please?  The page-frag API is only partially documented, but that's no
> > excuse.
> 
> Okay.  I assume you want the documentation as a follow-up patch since
> I received a notice that the patch was added to -mm?

Yes please.  Or a replacement patch which I'll temporarily turn into a
delta, either is fine.

> If you would like I could look at doing a couple of renaming patches
> so that we make the API a bit more consistent.  I could move the
> __alloc and __free to what you have suggested, and then take a look at
> trying to rename the refill/drain to be a bit more consistent in terms
> of what they are supposed to work on and how they are supposed to be
> used.

I think that would be better - it's hardly high-priority but a bit of
attention to the documentation and naming conventions would help tidy
things up.  When you can't find anything else to do ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
