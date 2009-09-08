Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7EB066B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 14:57:01 -0400 (EDT)
Message-ID: <4AA6A8FC.9080301@redhat.com>
Date: Tue, 08 Sep 2009 14:57:00 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/8] mm: add get_dump_page
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils> <Pine.LNX.4.64.0909072231120.15430@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0909072231120.15430@sister.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Howells <dhowells@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> In preparation for the next patch, add a simple get_dump_page(addr)
> interface for the CONFIG_ELF_CORE dumpers to use, instead of calling
> get_user_pages() directly.  They're not interested in errors: they
> just want to use holes as much as possible, to save space and make
> sure that the data is aligned where the headers said it would be.
> 
> Oh, and don't use that horrid DUMP_SEEK(off) macro!
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
