Subject: Re: [PATCH 7/6] Lost bits - fix PG_writeback vs PG_private race in
	NFS
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1156538662.26945.21.camel@lappy>
References: <20060825153709.24254.28118.sendpatchset@twins>
	 <1156523815.16027.43.camel@taijtu>  <1156536687.5927.25.camel@localhost>
	 <1156538662.26945.21.camel@lappy>
Content-Type: text/plain
Date: Fri, 25 Aug 2006 17:19:12 -0400
Message-Id: <1156540752.5927.66.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-08-25 at 22:44 +0200, Peter Zijlstra wrote:
> The VM doesn't really like PG_private set on PG_swapcache pages, I guess
> I'll have to rectify that and leave the NFS behaviour as is.

You might want to consider disabling NFS data cache revalidation on swap
files since it doesn't really make sense to have other clients change
the file while you are using it.

If you do, you could also skip setting PG_private on swap pages, since
there ought to be no further races with invalidate_inode_pages2() to
deal with.

Cheers,
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
