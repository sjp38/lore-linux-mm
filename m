Subject: Re: [rtf] [patch] 2.3.99-pre6-3 overly swappy
References: <Pine.LNX.4.21.0004201538200.8445-100000@devserv.devel.redhat.com>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Ben LaHaise's message of "Thu, 20 Apr 2000 15:43:23 -0400 (EDT)"
Date: 21 Apr 2000 02:25:10 +0200
Message-ID: <ytt4s8wb8rd.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

>>>>> "ben" == Ben LaHaise <bcrl@redhat.com> writes:

ben> The balance between swap and shrink_mmap was upset by the recent per-zone
ben> changes: kswapd wakeups now call swap_out 3 times as much as before,
ben> resulting in increased page faults and swap out activity, especially
ben> under heavy io.  This patch seems to help quite a bit -- can other people
ben> give this a try?

Hi Ben
   I have tested your patch here, with high loads (around 34), the
   system doesn't use swap (like with 2.3.51).  With 2.3.99 it uses a
   lot of swap.  The system has anyway around 60 MB RAM unused,
   i.e. It don't have to use swap.

   I have tested also the other patchs from Rik, here they improving
   responsiveness a lot, the mouse moves smoothly.  With them the
   system has a lot of memory in swap, but not a lot of swap traffic,
   i.e, it swaps the applications that I am not using in that moment. 

   I have tried to mix the two, yours and him, and no way, the system
   begins working OK, but in some moments, the system begins to trash
   (very heavily).  Indeed I boot the machine with mem=64MB (normally
   with 256MB), the same precesses for testing and the machine dies
   in the middle of the trashing (no keyboard, no mouse, no response)
   and the disk sound very loud.

   Hope this helps, if you want more information, me to make some tests
   or something, let me know.

Best regards, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
