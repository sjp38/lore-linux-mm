Subject: Re: [PATCH] low-latency zap_page_range()
From: Robert Love <rml@tech9.net>
In-Reply-To: <1030653602.939.2677.camel@phantasy>
References: <1030635100.939.2551.camel@phantasy>
	<3D6E844C.4E756D10@zip.com.au>  <1030653602.939.2677.camel@phantasy>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 29 Aug 2002 16:46:43 -0400
Message-Id: <1030654004.12110.2685.camel@phantasy>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2002-08-29 at 16:40, Robert Love wrote:

> On Thu, 2002-08-29 at 16:30, Andrew Morton wrote:
> 
> > However with your change, we'll only ever put 256 pages into the
> > mmu_gather_t.  Half of that thing's buffer is unused and the
> > invalidation rate will be doubled during teardown of large
> > address ranges.
> 
> Agreed.  Go for it.

Oh and put a comment in there explaining what you just said to me :)

	Robert Love


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
