Date: Thu, 8 Jun 2000 20:24:46 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: raid0 and buffers larger than PAGE_SIZE
Message-ID: <20000608202446.Q3886@redhat.com>
References: <20000607204444.A453@perlsupport.com> <20000608150821.G3886@redhat.com> <20000608121312.A601@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000608121312.A601@perlsupport.com>; from chip@valinux.com on Thu, Jun 08, 2000 at 12:13:13PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chip Salzenberg <chip@valinux.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Jun 08, 2000 at 12:13:13PM -0700, Chip Salzenberg wrote:
> According to Stephen C. Tweedie:
> > getblk() with blocksize > PAGE_SIZE is completely illegal.
> 
> Well, that answers _that_ question.
> 
> > Are you using a decent set of raid patches?
> 
> No patches, and apparently not decent.  :-(  I looked around with
> google and on ftp.kernel.org, but I couldn't find anything current.
> 
> Can you spare a URL for a fellow programmer down on his luck?

If you've got a Red Hat 6.2 CD around, it's in the kernel srpm. 
Otherwise, check Ingo's home page: you'll find it all at

	http://people.redhat.com/mingo/raid-patches/

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
