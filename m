Date: Mon, 3 Mar 2008 13:57:42 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 02/21] Use an indexed array for LRU variables
Message-ID: <20080303135742.233f6746@cuia.boston.redhat.com>
In-Reply-To: <20080229160320.GG28849@shadowen.org>
References: <20080228192908.126720629@redhat.com>
	<20080228192928.079732330@redhat.com>
	<20080229160320.GG28849@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, 29 Feb 2008 16:03:20 +0000
Andy Whitcroft <apw@shadowen.org> wrote:

> >  	/* First 128 byte cacheline (assuming 64 bit words) */
> >  	NR_FREE_PAGES,
> > -	NR_INACTIVE,
> > -	NR_ACTIVE,
> > +	NR_INACTIVE,	/* must match order of LRU_[IN]ACTIVE */
> > +	NR_ACTIVE,	/*  "     "     "   "       "         */
> 
> This little ordering constraint is a little nasty.  If we have enum_list
> available at this point then we can make sure that these order correctly
> automatically with something like this:

A little, true.

However, we need to line up with vmstat_text as well, so I suspect
the best way to make this friendlier to people new to this part of
the kernel would be to add more documentation, not more magic.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
