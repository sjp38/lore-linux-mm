Message-ID: <3AE1DCA8.A6EF6802@earthlink.net>
Date: Sat, 21 Apr 2001 13:16:56 -0600
From: "Joseph A. Knapka" <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
References: <mibudt848g9vrhaac88qjdpnaut4hajooa@4ax.com> <Pine.LNX.4.30.0104201203280.20939-100000@fs131-224.f-secure.com> <sb72ets3sek2ncsjg08sk5tmj7v9hmt4p7@4ax.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "James A. Sutherland" <jas88@cam.ac.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"James A. Sutherland" wrote:
> 
> Note that process suspension already happens, but with too fine a
> granularity (the scheduler) - that's what causes the problem. If one
> process were able to run uninterrupted for, say, a second, it would
> get useful work done, then you could switch to another. The current
> scheduling doesn't give enough time for that under thrashing
> conditions.

This suggests that a very simple approach might be to just increase
the scheduling granularity as the machine begins to thrash. IOW,
use the existing scheduler as the "suspension scheduler".

-- Joe
 

-- 
"If I ever get reincarnated... let me make certain I don't come back
 as a paperclip." -- protagonist, H Murakami's "Hard-boiled Wonderland"
// Linux MM Documentation in progress:
// http://home.earthlink.net/~jknapka/linux-mm/vmoutline.html
* Evolution is an "unproven theory" in the same sense that gravity is. *
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
