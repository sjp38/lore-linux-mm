Date: Sun, 29 Aug 2004 18:54:59 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap partition
Message-ID: <20040829165458.GD11219@suse.de>
References: <20040826144155.GH2912@suse.de> <412E13DB.6040102@seagha.com> <412E31EE.3090102@pandora.be> <41308C62.7030904@seagha.com> <20040828125028.2fa2a12b.akpm@osdl.org> <4130F55A.90705@pandora.be> <20040828144303.0ae2bebe.akpm@osdl.org> <20040828215411.GY5492@holomorphy.com> <20040828151349.00f742f4.akpm@osdl.org> <20040828222816.GZ5492@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040828222816.GZ5492@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@osdl.org>, karl.vogel@pandora.be, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 28 2004, William Lee Irwin III wrote:
> >> I was under the impression this had something to do with IO
> >> schedulers.
> 
> On Sat, Aug 28, 2004 at 03:13:49PM -0700, Andrew Morton wrote:
> > Separate issue.
> 
> It certainly appears to be the deciding factor from the thread.

Has nothing to do with the io scheduler itself, apart from the fact that
CFQ exposes the problem by setting a larger q->nr_requests. And that is
the very deciding factor, not the io scheduler.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
