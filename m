Date: Tue, 25 Nov 2008 20:38:16 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH 8/9] swapfile: swapon randomize if nonrot
Message-ID: <20081126033815.GF25548@parisc-linux.org>
References: <Pine.LNX.4.64.0811252132580.17555@blonde.site> <Pine.LNX.4.64.0811252140230.17555@blonde.site> <Pine.LNX.4.64.0811252146090.20455@blonde.site> <20081125172039.c9a35460.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081125172039.c9a35460.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, dwmw2@infradead.org, jens.axboe@oracle.com, joern@logfs.org, James.Bottomley@HansenPartnership.com, djshin90@gmail.com, teheo@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 25, 2008 at 05:20:39PM -0800, Andrew Morton wrote:
> On Tue, 25 Nov 2008 21:46:56 +0000 (GMT)
> Hugh Dickins <hugh@veritas.com> wrote:
> 
> > But how to get my SD card, accessed by USB card reader, reported as NONROT?
> 
> Dunno.  udev rules, perhaps?

I didn't see patch 8/9, but the 'non-rotating' bit is in word 217 of the
inquiry data.  Unfortunately, Jeff insisted that we only report the
contents of that bit for devices claiming ATA-8 support, which is
ridiculous as even the Intel SSDs only claim conformance to ATA-7.

I notice that Jens was allowed to ignore Jeff's insane requirement and
doesn't have to check ATA revision at all.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
