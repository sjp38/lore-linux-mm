Date: Fri, 9 Jun 2006 16:15:31 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Light weight counter 1/1 Framework
Message-Id: <20060609161531.249de5e1.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0606091537350.3036@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0606091216320.1174@schroedinger.engr.sgi.com>
	<20060609143333.39b29109.akpm@osdl.org>
	<Pine.LNX.4.64.0606091537350.3036@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, ak@suse.de, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> Eventcounter fixups

And the kernel still doesn't actually compile with this patch applied.  You
need to also apply light-weight-counters-counter-conversion.patch to make
page_alloc.c compile.  So either we break git-bisect or I fold two
inappropriate patches together or I need to patchwrangle it somehow.

<checks>

Yes, I need to fold them all together.

And fix the unused-variable warnings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
