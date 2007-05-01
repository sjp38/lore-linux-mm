Date: Tue, 1 May 2007 14:09:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.22 -mm merge plans: slub
Message-Id: <20070501140911.1606a918.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0705011345360.26494@schroedinger.engr.sgi.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
	<20070501125559.9ab42896.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
	<20070501133618.93793687.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0705011345360.26494@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 May 2007 13:46:26 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 1 May 2007, Andrew Morton wrote:
> 
> > otoh I could do some frantic patch mangling and make it easier to carry
> > slub out-of-tree, but do we gain much from that?
> 
> Then we may loose all the slab API cleanups? Yuck. I really do not want 
> redo those....

No, I meant that I'd look at splitting those patches up into
one-against-mainline and one-against-slub.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
