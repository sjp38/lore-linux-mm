Date: Tue, 13 May 2003 16:26:59 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC][PATCH] Interface to invalidate regions of mmaps
Message-ID: <20030513232659.GC8978@holomorphy.com>
References: <20030513133636.C2929@us.ibm.com> <20030513152141.5ab69f07.akpm@digeo.com> <3EC17BA3.7060403@zabbo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3EC17BA3.7060403@zabbo.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zach Brown <zab@zabbo.net>
Cc: Andrew Morton <akpm@digeo.com>, paulmck@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mjbligh@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, May 13, 2003 at 04:11:31PM -0700, Zach Brown wrote:
> but on the other hand, this doesn't solve another problem we have with
> opportunistic lock extents and sparse page cache populations.  Ideally
> we'd like a FS specific pointer in struct page so we can associate pages
> in the cache with a lock, but I can't imagine suggesting such a thing
> within earshot of wli.  so we'd still have to track the dirty offsets to
> avoid having to pass through offsets 0 ... i_size only to find that one
> page in the 8T file that was cached.

Nah, don't worry about sizeof(struct page) anymore; I'll just jack up
PAGE_SIZE to compensate.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
