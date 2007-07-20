Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6KLDfdY002228
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 17:13:41 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6KLDfj9169634
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 15:13:41 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6KLDfG8025207
	for <linux-mm@kvack.org>; Fri, 20 Jul 2007 15:13:41 -0600
Subject: Re: [PATCH] hugetlbfs read() support
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <46A03A17.8090708@yahoo.com.au>
References: <1184376214.15968.9.camel@dyn9047017100.beaverton.ibm.com>
	 <20070718221950.35bbdb76.akpm@linux-foundation.org>
	 <1184860309.18188.90.camel@dyn9047017100.beaverton.ibm.com>
	 <20070719095850.6e09b0e8.akpm@linux-foundation.org>
	 <46A03A17.8090708@yahoo.com.au>
Content-Type: text/plain
Date: Fri, 20 Jul 2007 14:15:33 -0700
Message-Id: <1184966133.21127.0.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Bill Irwin <bill.irwin@oracle.com>, nacc@us.ibm.com, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-07-20 at 14:29 +1000, Nick Piggin wrote:
> Andrew Morton wrote:
> > On Thu, 19 Jul 2007 08:51:49 -0700 Badari Pulavarty <pbadari@us.ibm.com> wrote:
> > 
> > 
> >>>>+		}
> >>>>+
> >>>>+		offset += ret;
> >>>>+		retval += ret;
> >>>>+		len -= ret;
> >>>>+		index += offset >> HPAGE_SHIFT;
> >>>>+		offset &= ~HPAGE_MASK;
> >>>>+
> >>>>+		page_cache_release(page);
> >>>>+		if (ret == nr && len)
> >>>>+			continue;
> >>>>+		goto out;
> >>>>+	}
> >>>>+out:
> >>>>+	return retval;
> >>>>+}
> >>>
> >>>This code doesn't have all the ghastly tricks which we deploy to handle
> >>>concurrent truncate.
> >>
> >>Do I need to ? Baaahh!!  I don't want to deal with them. 
> > 
> > 
> > Nick, can you think of any serious consequences of a read/truncate race in
> > there?  I can't..
> 
> As it doesn't allow writes, then I _think_ it should be OK. If you
> ever did want to add write(2) support, then you would have transient
> zeroes problems.

I have no plans to add write() support - unless there is real reason
for doing so.

> 
> But why not just hold i_mutex around the whole thing just to be safe?

Yeah. I can do that, just to be safe for future..

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
