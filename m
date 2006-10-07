Date: Sat, 7 Oct 2006 13:43:45 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 3/3] mm: add arch_alloc_page
Message-Id: <20061007134345.0fa1d250.akpm@osdl.org>
In-Reply-To: <20061007105824.14024.85405.sendpatchset@linux.site>
References: <20061007105758.14024.70048.sendpatchset@linux.site>
	<20061007105824.14024.85405.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat,  7 Oct 2006 15:06:04 +0200 (CEST)
Nick Piggin <npiggin@suse.de> wrote:

> Add an arch_alloc_page to match arch_free_page.

umm.. why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
