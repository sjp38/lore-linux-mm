Subject: Re: mmap: is default non-populating behavior stable?
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <491070B5.2060209@nortel.com>
References: <490F73CD.4010705@gmail.com> <1225752083.7803.1644.camel@twins>
	 <490F8005.9020708@redhat.com>  <491070B5.2060209@nortel.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Tue, 04 Nov 2008 17:07:00 +0100
Message-Id: <1225814820.7803.1672.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Friesen <cfriesen@nortel.com>
Cc: Rik van Riel <riel@redhat.com>, "Eugene V. Lyubimkin" <jackyf.devel@gmail.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, hugh <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-11-04 at 09:56 -0600, Chris Friesen wrote:
> Rik van Riel wrote:
> > Peter Zijlstra wrote:
> 
> >> The exact interaction of mmap() and truncate() I'm not exactly clear on.
> > 
> > Truncate will reduce the size of the mmaps on the file to
> > match the new file size, so processes accessing beyond the
> > end of file will get a segmentation fault (SIGSEGV).
> 
> I suspect Peter was talking about using truncate() to set the initial 
> file size, effectively increasing rather than reducing it.

I was thinking of truncate() on an already mmap()'ed region, either
increasing or decreasing the size so that part of the mmap becomes
(in)valid.

I'm not sure how POSIX speaks of this.

I think Linux does the expected thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
