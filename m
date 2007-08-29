Date: Wed, 29 Aug 2007 11:03:01 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] radix-tree: be a nice citizen
Message-ID: <20070829090301.GB32236@wotan.suse.de>
References: <20070829085039.GA32236@wotan.suse.de> <20070829015702.7c8567c2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070829015702.7c8567c2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 29, 2007 at 01:57:02AM -0700, Andrew Morton wrote:
> On Wed, 29 Aug 2007 10:50:39 +0200 Nick Piggin <npiggin@suse.de> wrote:
> 
> > ISTR that last time I sent you a patch to do the same thing, you
> > had some objections. I can't remember what they were though, but
> > I guess you didn't end up merging it.
> 
> So you can't remember what the problem was, and I have to work iyut
> out again.  Is this efficient?

No, but better than leaving it unfixed. It was years ago. I did try
to find it.

 
> > I was reminded by the problem after seeing an atomic allocation
> > failure trace from pagecache radix tree inesrtion.
> 
> wot?  radix-tree node allocation for pagecache insertion doesn't fail.

The atomic allocation that's part of node allocation can.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
