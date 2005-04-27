From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17007.52609.465222.106632@gargle.gargle.HOWL>
Date: Wed, 27 Apr 2005 21:36:01 +0400
Subject: Re: [PATCH/RFC 0/4] VM: Manual and Automatic page cache reclaim
In-Reply-To: <20050427150848.GR8018@localhost>
References: <20050427150848.GR8018@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Hicks <mort@sgi.com>
Cc: Ray Bryant <raybry@sgi.com>, ak@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Martin Hicks writes:

[...]

 > 
 > The reclaim code.  It extends shrink_list() so it can be used to scan
 > the active list as well.  The core of all of this is
 > reclaim_clean_pages().  It tries to remove a specified number of pages
 > from a zone's cache.  It does this without swapping or doing writebacks.
 > The goal here is to free easily freeable pages.

That's probably not very relevant for the scenario you describe, but
reclaiming free pages first looks quite similar to the behavior Linux
had when there were separate inactive_clean and inactive_dirty queues in
VM. Problem with that approach was that by skipping dirty pages, LRU was
destroyed, and system shortly starts reclaiming hot read-only pages,
ignoring cold but dirty ones.

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
