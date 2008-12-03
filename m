Date: Tue, 2 Dec 2008 16:57:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/8] badpage: simplify page_alloc flag check+clear
Message-Id: <20081202165755.0306b56f.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0812021357390.28623@blonde.anvils>
References: <Pine.LNX.4.64.0812010032210.10131@blonde.site>
	<Pine.LNX.4.64.0812010038220.11401@blonde.site>
	<Pine.LNX.4.64.0812010843230.15331@quilx.com>
	<Pine.LNX.4.64.0812012349330.18893@blonde.anvils>
	<Pine.LNX.4.64.0812012014150.30344@quilx.com>
	<Pine.LNX.4.64.0812020947440.5306@blonde.anvils>
	<Pine.LNX.4.64.0812020710371.9474@quilx.com>
	<Pine.LNX.4.64.0812021357390.28623@blonde.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: cl@linux-foundation.org, rja@sgi.com, nickpiggin@yahoo.com.au, davej@redhat.com, arjan@infradead.org, schwidefsky@de.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Dec 2008 14:12:05 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> On Tue, 2 Dec 2008, Christoph Lameter wrote:
> > On Tue, 2 Dec 2008, Hugh Dickins wrote:
> > 
> > > > But they are always clear on free. The checking is irrelevant.
> > >
> > > How about CHECK_PAGE_FLAGS_CLEAR_AT_FREE?
> > 
> > Strange name.
> 
> Looks like I'm not going to be able to satisfy you then.  I didn't
> introduce the names in the patch, so let's leave them as is for now,
> and everybody can muse on what they should get called in the end.

It's unclear to me where your discussion with Christoph ended up, so I
went the merge-it-and-see-who-shouts-at-me route.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
