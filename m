Subject: Re: 2.6.22 -mm merge plans
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <84144f020705010217j738e461ey6b09fd738574fb70@mail.gmail.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	 <84144f020705010217j738e461ey6b09fd738574fb70@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 01 May 2007 11:37:50 +0200
Message-Id: <1178012270.24217.1.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hch@lst.de, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, 2007-05-01 at 12:17 +0300, Pekka Enberg wrote:
> On 5/1/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> >  revoke-special-mmap-handling.patch
> 
> [snip]
> 
> > Hold.  This is tricky stuff and I don't think we've seen sufficient
> > reviewing, testing and acking yet?
> 
> Agreed. While Peter and Nick have done some review of the patches, I
> would really like VFS maintainers to review them before merge.
> Christoph, have you had the chance to take a look at it?

I'll have another look at it; also, I'll try to work through Mel's
patches once again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
