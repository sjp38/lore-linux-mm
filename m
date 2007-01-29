Date: Mon, 29 Jan 2007 12:00:56 -0800
From: Mark Fasheh <mark.fasheh@oracle.com>
Subject: Re: page_mkwrite caller is racy?
Message-ID: <20070129200056.GC8176@ca-server1.us.oracle.com>
Reply-To: Mark Fasheh <mark.fasheh@oracle.com>
References: <45BDCA8A.4050809@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45BDCA8A.4050809@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, David Howells <dhowells@redhat.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 29, 2007 at 09:20:58PM +1100, Nick Piggin wrote:
> But it is sad that this thing got merged without any callers to even know
> how it is intended to work. Must it be able to sleep?

Ocfs2 absolutely needs to be able to sleep in there in order to take cluster
locks, do allocation, etc. I suspect ext3 and other file systems will want
to sleep in there when they start caring about being able to allocate the
page before it gets written to.

For an example of what I'm talking about, there's a shared_writeable_mmap
branch in ocfs2.git which makes use of ->page_mkwrite(). It's got some other
small problems which need fixing (when I get the time to do so), but
generally it should illustrate what we're likely to do.

Thanks,
	--Mark

--
Mark Fasheh
Senior Software Developer, Oracle
mark.fasheh@oracle.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
