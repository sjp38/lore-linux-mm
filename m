Date: Mon, 20 Oct 2003 13:10:08 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [BUG] Re: 2.6.0-test8-mm1
Message-Id: <20031020131008.19125b7c.akpm@osdl.org>
In-Reply-To: <1066677679.2121.3.camel@debian>
References: <20031020020558.16d2a776.akpm@osdl.org>
	<1066677679.2121.3.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ramon.rey@hispalinux.es
Cc: rrey@ranty.pantax.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ramon Rey Vicente <rrey@ranty.pantax.net> wrote:
>
> The same problem with other kernel versions. I get it trying to delete
> my local 2.6 svn repository:
> 
> EXT3-fs error (device hdb1): ext3_free_blocks: Freeing blocks in system
> zones - Block = 512, count = 1

This is consistent with a corrupted filesystem.  Have you forced a fsck
against that partition?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
