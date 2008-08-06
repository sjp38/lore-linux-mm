From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 12/17] vfs: pagecache usage optimization for pagesize!=blocksize
Date: Wed, 6 Aug 2008 15:36:31 +1000
References: <200807282246.m6SMkaHT032267@imap1.linux-foundation.org> <20080728230031.GA22218@infradead.org> <200808041719.43293.nickpiggin@yahoo.com.au>
In-Reply-To: <200808041719.43293.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200808061536.32275.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org, hifumi.hisashi@oss.ntt.co.jp, jack@ucw.cz, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Any updates with this, please?

On Monday 04 August 2008 17:19, Nick Piggin wrote:
> On Tuesday 29 July 2008 09:00, Christoph Hellwig wrote:
> > On Mon, Jul 28, 2008 at 03:46:36PM -0700, akpm@linux-foundation.org wrote:
> > > From: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>
> > >
> > > When we read some part of a file through pagecache, if there is a
> > > pagecache of corresponding index but this page is not uptodate, read IO
> > > is issued and this page will be uptodate.
> >
> > I was under the impression we wanted to do this in a nicer way than
> > the hacky method?
>
> This patch unfortunately appears like it may introduce an
> uninitialized memory leak due to a data race between one
> thread initializing a buffer then marking it uptodate, and
> the other testing buffer uptodate then reading from the
> buffer (buffer, read as: page memory covered by buffer head).
>
> For reference, this is basically the same class of data race
> that I fixed 0ed361dec36945f3116ee1338638ada9a8920905
>
> I should have picked up on this before it was merged, but I
> was kind of rushed to review other things before they got
> merged.
>
> I don't think this patch got quite enough justification to
> warrant just blindly putting barriers in the buffer bitops.
> The best-case numbers for it were reasonable enough when the
> downside was only an extra branch or two in a relatively slow
> path. I don't really know how best to go from here (maybe
> someone can argue it is not a problem or come up with a better
> fix?).
>
> Thanks,
> Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
