Date: Sun, 30 May 2004 03:15:59 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: mmap() > phys mem problem
Message-Id: <20040530031559.329acf68.akpm@osdl.org>
In-Reply-To: <40B9A855.3030102@yahoo.com.au>
References: <Pine.LNX.4.44.0405251523250.18898-100000@pygar.sc.orionmulti.com>
	<Pine.LNX.4.55L.0405282208210.32578@imladris.surriel.com>
	<Pine.LNX.4.60.0405292144350.1068@stimpy>
	<40B9A855.3030102@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: rlm@orionmulti.com, riel@surriel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> wrote:
>
>  -				err = WRITEPAGE_ACTIVATE;
>  +				nfs_flush_inode(inode, 0, 0, FLUSH_STABLE);

err, absolutely.  I thought we fixed that months ago...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
