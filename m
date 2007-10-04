Date: Wed, 3 Oct 2007 21:36:31 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [14/18] Configure stack size
Message-ID: <20071003213631.7a047dde@laptopd505.fenrus.org>
In-Reply-To: <20071004040004.936534357@sgi.com>
References: <20071004035935.042951211@sgi.com>
	<20071004040004.936534357@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@suse.de, travis@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 03 Oct 2007 20:59:49 -0700
Christoph Lameter <clameter@sgi.com> wrote:

> Make the stack size configurable now that we can fallback to vmalloc
> if necessary. SGI NUMA configurations may need more stack because
> cpumasks and nodemasks are at times kept on the stack. With the
> coming 16k cpu support this is going to be 2k just for the mask. This
> patch allows to run with 16k or 32k kernel stacks on x86_74.

there is still code that does DMA from and to the stack....
how would this work with virtual allocated stack?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
