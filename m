Date: Thu, 1 Mar 2007 23:01:31 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH/RFC 2.6.20 1/2] fbdev, mm: Deferred IO support
Message-ID: <20070301140131.GA6603@linux-sh.org>
References: <20070225051312.17454.80741.sendpatchset@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070225051312.17454.80741.sendpatchset@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jaya Kumar <jayakumar.lkml@gmail.com>
Cc: linux-fbdev-devel@lists.sourceforge.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, Feb 25, 2007 at 06:13:12AM +0100, Jaya Kumar wrote:
> This patch implements deferred IO support in fbdev. Deferred IO is a way to
> delay and repurpose IO. This implementation is done using mm's page_mkwrite
> and page_mkclean hooks in order to detect, delay and then rewrite IO. This
> functionality is used by hecubafb.
> 
Any updates on this? If there are no other concerns, it would be nice to
at least get this in to -mm for testing if nothing else.

Jaya, can you roll the fsync() patch in to your defio patch? There's not
much point in keeping them separate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
