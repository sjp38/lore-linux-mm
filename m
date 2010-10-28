Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3D0B66B00BA
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 13:39:47 -0400 (EDT)
Subject: Re: [PATCH] parisc: fix compile failure with kmap_atomic changes
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <20101028171302.5D8944CFC@hiauly1.hia.nrc.ca>
References: <20101028171302.5D8944CFC@hiauly1.hia.nrc.ca>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Oct 2010 12:39:40 -0500
Message-ID: <1288287580.3043.159.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: John David Anglin <dave@hiauly1.hia.nrc.ca>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-parisc@vger.kernel.org, peterz@infradead.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-10-28 at 13:13 -0400, John David Anglin wrote:
> > On Thu, 2010-10-28 at 01:18 -0400, John David Anglin wrote:
> > > Signed-off-by: John David Anglin  <dave.anglin@nrc-cnrc.gc.ca>
> > > 
> > > Sent effectively the same change to parisc-linux list months ago...
> > 
> > You did?  Why didn't you send it to Peter?  When I grumbled at him on
> > IRC for breaking parisc (as well as quite a few other 64 bit
> > architectures in mainline) he had no idea there was a problem.
> 
> For example, it is in the diff recently posted here:
> http://permalink.gmane.org/gmane.linux.ports.parisc/3173
> This diff is from last May.

Um, so that doesn't fix the compile failure.

The specific problem is that kmap_atomic no longer takes the index
argument because Peter moved it to a stack based implementation.  All
our kmap_atomic primitives in asm/cacheflush.h still have the extra
index argument which causes a compile failure.

To fix it, I had to run through a bunch of renames and extra argument
removals.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
