Date: Wed, 29 Aug 2007 01:57:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch][rfc] radix-tree: be a nice citizen
Message-Id: <20070829015702.7c8567c2.akpm@linux-foundation.org>
In-Reply-To: <20070829085039.GA32236@wotan.suse.de>
References: <20070829085039.GA32236@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 29 Aug 2007 10:50:39 +0200 Nick Piggin <npiggin@suse.de> wrote:

> ISTR that last time I sent you a patch to do the same thing, you
> had some objections. I can't remember what they were though, but
> I guess you didn't end up merging it.

So you can't remember what the problem was, and I have to work iyut
out again.  Is this efficient?

> I was reminded by the problem after seeing an atomic allocation
> failure trace from pagecache radix tree inesrtion.

wot?  radix-tree node allocation for pagecache insertion doesn't fail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
