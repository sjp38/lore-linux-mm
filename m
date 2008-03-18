Date: Tue, 18 Mar 2008 09:49:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/8] mm: allow not updating BDI stats in
 end_page_writeback()
Message-Id: <20080318094900.b2f1340e.akpm@linux-foundation.org>
In-Reply-To: <E1Jbe8O-0006H7-E4@pomaz-ex.szeredi.hu>
References: <20080317191908.123631326@szeredi.hu>
	<20080317191945.122011759@szeredi.hu>
	<1205840031.8514.346.camel@twins>
	<E1JbaTH-0005jN-4r@pomaz-ex.szeredi.hu>
	<1205843375.8514.357.camel@twins>
	<E1JbbHf-0005rm-R5@pomaz-ex.szeredi.hu>
	<1205845702.8514.365.camel@twins>
	<E1JbcKL-00060V-9N@pomaz-ex.szeredi.hu>
	<1205848760.8514.366.camel@twins>
	<E1Jbe8O-0006H7-E4@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: peterz@infradead.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Mar 2008 16:53:52 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:

> On a related note, is there a reason why bdi_cap_writeback_dirty() and
> friends need to be macros instead of inline functions?

None whatsoever.

>  If not I'd clean that up as well.

Goodness.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
