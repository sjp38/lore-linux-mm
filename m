Date: Mon, 22 Sep 2003 15:09:33 -0400 (EDT)
From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: How best to bypass the page cache from within a kernel module?
In-Reply-To: <3F6F44AF.2030807@sgi.com>
Message-ID: <Pine.LNX.4.44L0.0309221508490.2840-100000@ida.rowland.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Sep 2003, Ray Bryant wrote:

> Take a look at invalidate_inode_pages()....

William Lee Irwin made the same suggestion.  It turned out to be just what 
I needed.

Thanks, guys!

Alan Stern

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
