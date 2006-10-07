Date: Sat, 7 Oct 2006 13:43:56 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 2/3] mm: fault vs invalidate/truncate race fix
Message-Id: <20061007134356.d48cdf45.akpm@osdl.org>
In-Reply-To: <20061007105842.14024.85533.sendpatchset@linux.site>
References: <20061007105758.14024.70048.sendpatchset@linux.site>
	<20061007105842.14024.85533.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>, Mark Fasheh <mark.fasheh@oracle.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat,  7 Oct 2006 15:06:21 +0200 (CEST)
Nick Piggin <npiggin@suse.de> wrote:

> Fix the race between invalidate_inode_pages and do_no_page.

Changes have occurred in ocfs2.  The fixup is pretty obvious, but this is
one which Mark will need to have a think about please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
