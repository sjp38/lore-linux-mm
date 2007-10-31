Received: by an-out-0708.google.com with SMTP id d30so18532and
        for <linux-mm@kvack.org>; Wed, 31 Oct 2007 07:54:05 -0700 (PDT)
Message-ID: <170fa0d20710310754h55d768bdgb67f30b54174e680@mail.gmail.com>
Date: Wed, 31 Oct 2007 10:54:02 -0400
From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Re: [PATCH 00/33] Swap over NFS -v14
In-Reply-To: <1193828206.27652.145.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071030160401.296770000@chello.nl>
	 <200710311426.33223.nickpiggin@yahoo.com.au>
	 <20071030.213753.126064697.davem@davemloft.net>
	 <20071031085041.GA4362@infradead.org>
	 <1193828206.27652.145.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Hellwig <hch@infradead.org>, David Miller <davem@davemloft.net>, nickpiggin@yahoo.com.au, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Evgeniy Polyakov <johnpol@2ka.mipt.ru>
List-ID: <linux-mm.kvack.org>

On 10/31/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> On Wed, 2007-10-31 at 08:50 +0000, Christoph Hellwig wrote:
> > On Tue, Oct 30, 2007 at 09:37:53PM -0700, David Miller wrote:
> > > Don't be misled.  Swapping over NFS is just a scarecrow for the
> > > seemingly real impetus behind these changes which is network storage
> > > stuff like iSCSI.
> >
> > So can we please do swap over network storage only first?  All these
> > VM bits look conceptually sane to me, while the changes to the swap
> > code to support nfs are real crackpipe material.
>
> Yeah, I know how you stand on that. I just wanted to post all this
> before going off into the woods reworking it all.
...
> > So please get the VM bits for swap over network blockdevices in first,
>
> Trouble with that part is that we don't have any sane network block
> devices atm, NBD is utter crap, and iSCSI is too complex to be called
> sane.
>
> Maybe Evgeniy's Distributed storage thingy would work, will have a look
> at that.

Andrew recently asked Evgeniy if his DST was ready for merging; to
which Evgeniy basically said yes:
http://lkml.org/lkml/2007/10/27/54

It would be great if DST could be merged; whereby addressing the fact
that NBD is lacking for net-vm.  If DST were scrutinized in the
context of net-vm it should help it get the review that is needed for
merging.

Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
