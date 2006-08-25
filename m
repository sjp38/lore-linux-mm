From: Andi Kleen <ak@suse.de>
Subject: Re: ext3 fsync being starved for a long time by cp and cronjob
Date: Fri, 25 Aug 2006 14:51:50 +0200
References: <200608251353.51748.ak@suse.de> <200608251430.56655.ak@suse.de> <20060825123448.GD24258@kernel.dk>
In-Reply-To: <20060825123448.GD24258@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200608251451.50663.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: akpm@osdl.org, linux-mm@kvack.org, ext2-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Friday 25 August 2006 14:34, Jens Axboe wrote:
> On Fri, Aug 25 2006, Andi Kleen wrote:
> > On Friday 25 August 2006 14:26, Jens Axboe wrote:
> > > On Fri, Aug 25 2006, Andi Kleen wrote:
> > > > 
> > > > > Does deadline do better?
> > > > 
> > > > It's not really repeatable workload. It's just my workstation which
> > > > got into this unpleasant state while me trying to get work done.
> > > > 
> > > > I can change it to deadline and see if I see this still again, but it might
> > > > take some time.
> > > 
> > > Yeah, a test case might be simpler to write and test with. I'll see if I
> > > can come up with something.
> > 
> > So you think it's the elevator? I was about to blame JBD.
> 
> Not sure, it might be ext3. Hence the deadline test would be useful. All
> I know for sure is that the io scheduling for fsync() can be improved.
> Did you try data=writeback?

No. And I would prefer to not try that because I would have to run
my workstation with it for a long time, and ordered seems somewhat
safer for that.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
