Date: Fri, 13 Jun 2003 02:17:11 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.70-mm9
Message-Id: <20030613021711.402297df.akpm@digeo.com>
In-Reply-To: <20030613013337.1a6789d9.akpm@digeo.com>
References: <20030613013337.1a6789d9.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@digeo.com> wrote:
>
> +mark-inode-dirty-debug.patch

This will print "__mark_inode_dirty: this cannot happen" when the machine
first starts to swap.  Please ignore it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
