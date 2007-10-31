Date: Wed, 31 Oct 2007 19:31:42 +0300
From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 00/33] Swap over NFS -v14
Message-ID: <20071031163141.GA24400@2ka.mipt.ru>
References: <20071030160401.296770000@chello.nl> <200710311426.33223.nickpiggin@yahoo.com.au> <20071030.213753.126064697.davem@davemloft.net> <20071031085041.GA4362@infradead.org> <1193828206.27652.145.camel@twins> <170fa0d20710310754h55d768bdgb67f30b54174e680@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <170fa0d20710310754h55d768bdgb67f30b54174e680@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Snitzer <snitzer@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Hellwig <hch@infradead.org>, David Miller <davem@davemloft.net>, nickpiggin@yahoo.com.au, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

Hi.

On Wed, Oct 31, 2007 at 10:54:02AM -0400, Mike Snitzer (snitzer@gmail.com) wrote:
> > Trouble with that part is that we don't have any sane network block
> > devices atm, NBD is utter crap, and iSCSI is too complex to be called
> > sane.
> >
> > Maybe Evgeniy's Distributed storage thingy would work, will have a look
> > at that.
> 
> Andrew recently asked Evgeniy if his DST was ready for merging; to
> which Evgeniy basically said yes:
> http://lkml.org/lkml/2007/10/27/54
> 
> It would be great if DST could be merged; whereby addressing the fact
> that NBD is lacking for net-vm.  If DST were scrutinized in the
> context of net-vm it should help it get the review that is needed for
> merging.

By popular request I'm working on adding strong checksumming of the data
transferred, so I can not say that Andrew will want to merge this during
development phase. I expect to complete it quite soon (it is in testing
stage right now) though with new release scheduled this week. It will
also include some small features for userspace (hapiness).

Memory management is not changed.

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
