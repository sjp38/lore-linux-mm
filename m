Date: Thu, 8 Jan 2004 00:23:29 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: a new version of memory hotremove patch
Message-Id: <20040108002329.3faee471.akpm@osdl.org>
In-Reply-To: <20040108073634.8A9947007A@sv1.valinux.co.jp>
References: <20040108073634.8A9947007A@sv1.valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Cc: lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

IWAMOTO Toshihiro <iwamoto@valinux.co.jp> wrote:
>
> - If a page is in mapping->io_pages when remap happens, it will be
>    moved to dirty_pages.  Tracking page->list to find out the list
>    which page is connected to would be too expensive, and I have no other
>    idea.

That sounds like a reasonable thing to do.  The only impact would be that
an fsync() which is currently in progress could fail to write the page, so
the page is still dirty after the fsync() returns.

If this is the biggest problem, you've done well ;)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
