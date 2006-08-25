Subject: Re: [PATCH 4/6] nfs: Teach NFS about swap cache pages
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1156537214.26945.6.camel@lappy>
References: <20060825153709.24254.28118.sendpatchset@twins>
	 <20060825153751.24254.20709.sendpatchset@twins>
	 <1156536228.5927.17.camel@localhost>  <1156537214.26945.6.camel@lappy>
Content-Type: text/plain
Date: Fri, 25 Aug 2006 16:37:34 -0400
Message-Id: <1156538255.5927.46.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-08-25 at 22:20 +0200, Peter Zijlstra wrote:
> Indiscriminate search and replace followed by a manual check for
> correctness. They might not be needed, but they're not wrong either.
> 
> Would you prefer I take them out?

It won't give us any massive performance optimisations, but it is nice
to be able to avoid that call to test_bit() whenever possible.

Cheers,
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
