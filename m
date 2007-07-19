Date: Thu, 19 Jul 2007 09:58:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hugetlbfs read() support
Message-Id: <20070719095850.6e09b0e8.akpm@linux-foundation.org>
In-Reply-To: <1184860309.18188.90.camel@dyn9047017100.beaverton.ibm.com>
References: <1184376214.15968.9.camel@dyn9047017100.beaverton.ibm.com>
	<20070718221950.35bbdb76.akpm@linux-foundation.org>
	<1184860309.18188.90.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Bill Irwin <bill.irwin@oracle.com>, nacc@us.ibm.com, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Jul 2007 08:51:49 -0700 Badari Pulavarty <pbadari@us.ibm.com> wrote:

> > > +		}
> > > +
> > > +		offset += ret;
> > > +		retval += ret;
> > > +		len -= ret;
> > > +		index += offset >> HPAGE_SHIFT;
> > > +		offset &= ~HPAGE_MASK;
> > > +
> > > +		page_cache_release(page);
> > > +		if (ret == nr && len)
> > > +			continue;
> > > +		goto out;
> > > +	}
> > > +out:
> > > +	return retval;
> > > +}
> > 
> > This code doesn't have all the ghastly tricks which we deploy to handle
> > concurrent truncate.
> 
> Do I need to ? Baaahh!!  I don't want to deal with them. 

Nick, can you think of any serious consequences of a read/truncate race in
there?  I can't..

> All I want is a simple read() to get my oprofile working.
> Please advise.

Did you consider changing oprofile userspace to read the executable with
mmap?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
