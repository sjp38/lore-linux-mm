Date: Tue, 26 Feb 2008 09:56:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/28] Swap over NFS -v16
Message-Id: <20080226095605.62edc0f3.akpm@linux-foundation.org>
In-Reply-To: <1204023042.6242.271.camel@lappy>
References: <20080220144610.548202000@chello.nl>
	<20080223000620.7fee8ff8.akpm@linux-foundation.org>
	<18371.43950.150842.429997@notabene.brown>
	<1204023042.6242.271.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Neil Brown <neilb@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Tue, 26 Feb 2008 11:50:42 +0100 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> On Tue, 2008-02-26 at 17:03 +1100, Neil Brown wrote:
> > On Saturday February 23, akpm@linux-foundation.org wrote:
>  
> > > What is the NFS and net people's take on all of this?
> > 
> > Well I'm only vaguely an NFS person, barely a net person, sporadically
> > an mm person, but I've had a look and it seems to mostly make sense.
> 
> Thanks for taking a look, and giving such elaborate feedback. I'll try
> and address these issues asap, but first let me reply to a few points
> here.

Neil's overview of what-all-this-is and how-it-all-works is really good. 
I'd suggest that you take it over, flesh it out and attach it firmly to the
patchset.  It really helps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
