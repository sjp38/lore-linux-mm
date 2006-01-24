Date: Tue, 24 Jan 2006 17:50:07 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH/RFC] Shared page tables
Message-ID: <07A9BE6C2CADACD27B259191@[10.1.1.4]>
In-Reply-To: <200601241743.28889.raybry@mpdtxmail.amd.com>
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
 <200601231758.08397.raybry@mpdtxmail.amd.com>
 <6BC41571790505903C7D3CD6@[10.1.1.4]>
 <200601241743.28889.raybry@mpdtxmail.amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@mpdtxmail.amd.com>
Cc: Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Those are interesting numbers.  That's pretty much the showcase for
sharing, yeah.

--On Tuesday, January 24, 2006 17:43:28 -0600 Ray Bryant
<raybry@mpdtxmail.amd.com> wrote:

> Of course, it would be more dramatic with a real DB application, but that
> is  going to take a bit longer to get running, perhaps a couple of months
> by the  time all is said and done.

I must mention here that I think most DB performance suites do their forks
up front, then never fork during the test, so fork performance doesn't
really factor in as much.  There are other reasons shared page tables helps
there, though.

> Now I am off to figure out how Andi's mmap() randomization patch
> interacts  with all of this stuff.

mmap() randomization doesn't affect fork at all, since by definition all
regions are at the same address in the child as the parent (ie good for
sharing).  The trickier case is where processes independently mmap() a
region.

Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
