Date: Tue, 7 Aug 2001 23:19:41 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: [PATCH] kill flush_dirty_buffers
Message-ID: <20010807231941.A4587@suse.de>
References: <Pine.LNX.4.33L.0108061538360.1439-100000@duckman.distro.conectiva> <0108062153340J.00294@starship>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0108062153340J.00294@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Chris Mason <mason@suse.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 06 2001, Daniel Phillips wrote:
> This suggests that buffer flushing needs to be per-device.

Yep, and either stopped as soon as the queue free lists are empty or
done independently per queue. One thought I had was to actually move the
dirty list to the queues (or at least separated) and have the plugs
_pull_ the buffers out instead of the other way around.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
