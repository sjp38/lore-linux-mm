Date: Mon, 28 Jan 2008 18:57:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Pull request: DMA pool updates
Message-Id: <20080128185701.752fe2c8.akpm@linux-foundation.org>
In-Reply-To: <20080129024524.GA20198@parisc-linux.org>
References: <20080129001147.GD31101@parisc-linux.org>
	<20080128170734.3101b6aa.akpm@linux-foundation.org>
	<20080129024524.GA20198@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jan 2008 19:45:25 -0700 Matthew Wilcox <matthew@wil.cx> wrote:

> > afaik these patches have been tested by nobody except thyself?
> 
> I've tested them myself, then I sent them to the perf team who ran the
> (4 hour long) benchmark, and they reported success.  As with many patches
> these days, they sank into a pit of indifference.

I like to think that's because everyone is all fired up about bugfixes and
the regression reports.  heh.

It's a simple matter for me to add another git tree, which gets things a
bit more exposure.

>  Perhaps I need to
> take a leaf from my former government's book and sex up my patch
> descriptions a bit.

Well these two pulls came with effectively no description at all.  Put
yourself in Linus's position...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
