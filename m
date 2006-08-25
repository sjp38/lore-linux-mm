Date: Fri, 25 Aug 2006 14:26:15 +0200
From: Jens Axboe <axboe@kernel.dk>
Subject: Re: ext3 fsync being starved for a long time by cp and cronjob
Message-ID: <20060825122615.GB24258@kernel.dk>
References: <200608251353.51748.ak@suse.de> <20060825120709.GZ24258@kernel.dk> <200608251422.48287.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200608251422.48287.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, linux-mm@kvack.org, ext2-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Fri, Aug 25 2006, Andi Kleen wrote:
> 
> > Does deadline do better?
> 
> It's not really repeatable workload. It's just my workstation which
> got into this unpleasant state while me trying to get work done.
> 
> I can change it to deadline and see if I see this still again, but it might
> take some time.

Yeah, a test case might be simpler to write and test with. I'll see if I
can come up with something.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
