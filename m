Subject: Re: [PATCH 7/6] Lost bits - fix PG_writeback vs PG_private race in
	NFS
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1156523815.16027.43.camel@taijtu>
References: <20060825153709.24254.28118.sendpatchset@twins>
	 <1156523815.16027.43.camel@taijtu>
Content-Type: text/plain
Date: Fri, 25 Aug 2006 16:11:27 -0400
Message-Id: <1156536687.5927.25.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-08-25 at 18:36 +0200, Peter Zijlstra wrote:
> Make sure we clear PG_writeback after we clear PG_private, otherwise
> weird and wonderfull stuff will happen.
> 
NACK.

Look carefully at the case of unstable writes: your patch does nothing
to guarantee that PG_writeback is cleared after PG_private for that
case.
Anyhow, you don't explain exactly what is wrong with clearing
PG_writeback before PG_private.

Cheers,
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
