Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 001B46B00EE
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 11:04:40 -0400 (EDT)
Date: Fri, 29 Jul 2011 10:04:36 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
In-Reply-To: <alpine.DEB.2.00.1107290145080.3279@tiger>
Message-ID: <alpine.DEB.2.00.1107291002570.16178@router.home>
References: <alpine.DEB.2.00.1107290145080.3279@tiger>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 29 Jul 2011, Pekka Enberg wrote:

> We haven't come up with a solution to keep struct page size the same but I
> think it's a reasonable trade-off.

The change requires the page struct to be aligned to a double word
boundary. There is actually no variable added to the page struct. Its just
the alignment requirement that causes padding to be added after each page
struct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
