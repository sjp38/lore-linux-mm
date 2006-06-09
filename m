Date: Fri, 9 Jun 2006 16:07:30 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Light weight counter 1/1 Framework
Message-Id: <20060609160730.5a67ae6b.akpm@osdl.org>
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

This is getting to be a bit of a pain.  Could you please spend more time
reviewing and testing patches before sending them?

Says he, staring at this:

mm/page_alloc.c: In function 'page_alloc_cpu_notify':
mm/page_alloc.c:2891: error: 'per_cpu__page_states' undeclared (first use in this function)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
