Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA16492
	for <linux-mm@kvack.org>; Tue, 19 Jan 1999 09:32:54 -0500
Date: Tue, 19 Jan 1999 14:32:34 GMT
Message-Id: <199901191432.OAA05326@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Why don't shared anonymous mappings work?
In-Reply-To: <199901132131.OAA09149@nyx10.nyx.net>
References: <199901132131.OAA09149@nyx10.nyx.net>
Sender: owner-linux-mm@kvack.org
To: Colin Plumb <colin@nyx.net>
Cc: sct@redhat.com, linux-mm@kvack.orgStephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 13 Jan 1999 14:31:41 -0700 (MST), Colin Plumb <colin@nyx.net>
said:

> Um, I just thought of another problem with shared anonymous pages.
> It's similar to the zero-page issue you raised, but it's no longer
> a single special case.

> Copy-on-write and shared mappings.  Let's say that process 1 has a COW
> copy of page X.  Then the page is shared (via mmap /proc/1/mem or some
> such) with process 2.  Now process A writes to the page.

Invalid argument.  This is *precisely* why mmap of /proc/X/mem is
broken.  We don't need to implement reasonable semantics for that case,
because there _are_ no reasonable semantics for a page which can be both
MAP_PRIVATE and MAP_SHARED in the same process.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
