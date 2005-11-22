Date: Tue, 22 Nov 2005 12:55:02 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] properly account readahead file major faults
In-Reply-To: <20051122062321.GA30413@logos.cnet>
Message-ID: <Pine.LNX.4.61.0511221249470.24803@goblin.wat.veritas.com>
References: <20051121140038.GA27349@logos.cnet> <20051122042443.GA4588@mail.ustc.edu.cn>
 <20051122062321.GA30413@logos.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Wu Fengguang <wfg@mail.ustc.edu.cn>, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Nov 2005, Marcelo Tosatti wrote:
> 
> Pages which hit the first time in cache due to readahead _have_ caused
> IO, and as such they should be counted as major faults.

Have caused IO, or have benefitted from IO which was done earlier?

It sounds debatable, each will have their own idea of what's major.

Maybe PageUptodate at the time the entry is found in the page cache
should come into it?  !PageUptodate implying that we'll be waiting
for read to complete.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
