Date: Mon, 23 Oct 2000 17:54:02 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Another wish item for your TODO list...
Message-ID: <20001023175402.B2772@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

Just a quick thought --- at some point it would be good if we could
add logic to the core VM so that for sequentially accessed files,
reclaiming any page of the file from cache would evict the _whole_ of
the file from cache.

For large files, we're not going to try to cache the whole thing
anyway.  For small files, reading the whole file back in later isn't
much more expensive than reading back a few fragments if the rest
still happens to be in cache.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
