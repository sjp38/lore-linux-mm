Message-ID: <41DDA6CB.6050307@sgi.com>
Date: Thu, 06 Jan 2005 14:59:55 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: page migration patchset
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Paul Jackson <pj@sgi.com>, Steve Longerbeam <stevel@mwwireless.net>, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andi,

Under the topic of modifying a processes's mems_allowed bitmask,
Paul Jackson has been telling me that this is hard, in general.
This is unfortunate, as part of the page migration work I am
doing, it seems that part of the necessary work is to change
the NUMA memory policy so newly allocated pages go onto the
new nodes.

Now I know there is no locking protection around the mems_allowed
bitmask, so changing this while the process is still running
sounds hard.  But part of the plan I am working under assumes
that the process is stopped before it is migrated.  (Shared
pages that are only shared among processes all of whom are to be
moved would similarly be handled; pages shsared among migrated
and non-migrated processes, e. g. glibc pages, would not
typically need to be moved at all, since they likely reside
somewhere outside the set of nodes to be migrated from.)

But if the process is suspended, isn't all that is needed just
to do the obvious translation on the mems_allowed vector?
(Similarly for the dedicated node stuff, I forget the name for
that at the moment...)

Am I missing something big here that makes this task harder
than I am thinking it is?
-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
