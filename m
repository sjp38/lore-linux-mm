Date: Tue, 22 Oct 2002 18:49:39 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch] generic nonlinear mappings, 2.5.44-mm2-D0
Message-ID: <20021022184938.A2395@infradead.org>
References: <Pine.LNX.4.44.0210221936010.18790-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0210221936010.18790-100000@localhost.localdomain>; from mingo@elte.hu on Tue, Oct 22, 2002 at 07:57:00PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@zip.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 22, 2002 at 07:57:00PM +0200, Ingo Molnar wrote:
> the attached patch (ontop of 2.5.44-mm2) implements generic (swappable!)
> nonlinear mappings and sys_remap_file_pages() support. Ie. no more
> MAP_LOCKED restrictions and strange pagefault semantics.
> 
> to implement this i added a new pte concept: "file pte's". This means that
> upon swapout, shared-named mappings do not get cleared but get converted
> into file pte's, which can then be decoded by the pagefault path and can
> be looked up in the pagecache.
> 
> the normal linear pagefault path from now on does not assume linearity and
> decodes the offset in the pte. This also tests pte encoding/decoding in
> the pagecache case, and the ->populate functions.

Ingo,

what is the reason for that interface?  It looks like a gross performance
hack for misdesigned applications to me, kindof windowsish..

Is this for whoracle or something like that?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
