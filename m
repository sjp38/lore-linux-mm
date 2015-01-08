Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7D46F6B0038
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 12:36:15 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id p10so12355757pdj.13
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 09:36:15 -0800 (PST)
Received: from mail.samba.org (fn.samba.org. [2001:470:1f05:1a07::1])
        by mx.google.com with ESMTPS id yl3si9712058pac.62.2015.01.08.09.36.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 09:36:13 -0800 (PST)
Date: Thu, 8 Jan 2015 09:36:10 -0800
From: Jeremy Allison <jra@samba.org>
Subject: Re: [PATCH v12 00/20] DAX: Page cache bypass for filesystems on
 memory storage
Message-ID: <20150108173610.GB6189@samba2>
Reply-To: Jeremy Allison <jra@samba.org>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
 <20141210140347.GA23252@infradead.org>
 <20141210141211.GD2220@wil.cx>
 <20150105184143.GA665@infradead.org>
 <20150106004714.6d63023c.akpm@linux-foundation.org>
 <CANP1eJHOMSP8GYc_1pi8ciZZFWR0dH=N5a4HA=RYezohDmm+Rg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANP1eJHOMSP8GYc_1pi8ciZZFWR0dH=N5a4HA=RYezohDmm+Rg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Milosz Tanski <milosz@adfin.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <willy@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Jan 08, 2015 at 11:28:40AM -0500, Milosz Tanski wrote:
> >
> 
> Andrew I  got busier with my other job related things between the
> Thanksgiving & Christmas then anticipated. However, I have updated and
> taken apart the patchset into two pieces (preadv2 and pwritev2). That
> should make evaluating the two separately easier. With the help of
> Volker I hacked up preadv2 support into samba and I hopefully have
> some numbers from it soon. Finally, I'm putting together a test case

I'd be very interested in seeing that patch code and those
numbers !

Cheers,

	Jeremy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
