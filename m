Date: Sun, 24 Jun 2007 03:53:55 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC] fsblock
Message-ID: <20070624015355.GE17609@wotan.suse.de>
References: <20070624014528.GA17609@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070624014528.GA17609@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Just clarify a few things. Don't you hate rereading a long work you
wrote? (oh, you're supposed to do that *before* you press send?).

On Sun, Jun 24, 2007 at 03:45:28AM +0200, Nick Piggin wrote:
> 
> I'm announcing "fsblock" now because it is quite intrusive and so I'd
> like to get some thoughts about significantly changing this core part
> of the kernel.
> 
> fsblock is a rewrite of the "buffer layer" (ding dong the witch is
> dead), which I have been working on, on and off and is now at the stage
> where some of the basics are working-ish. This email is going to be
> long...
> 
> Firstly, what is the buffer layer?  The buffer layer isn't really a
> buffer layer as in the buffer cache of unix: the block device cache
> is unified with the pagecache (in terms of the pagecache, a blkdev
> file is just like any other, but with a 1:1 mapping between offset
> and block).

I mean, in Linux, the block device cache is unified. UNIX I believe
did all its caching in a buffer cache, below the filesystem.

 
> - Large block support. I can mount and run an 8K block size minix3 fs on
>   my 4K page system and it didn't require anything special in the fs. We

Oh, and I don't have a Linux mkfs that makes minixv3 filesystems.
I had an image kindly made for me because I don't use minix. If
you want to test large block support, I won't email it to you though:
you can just convert ext2 or ext3 to fsblock ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
