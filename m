Date: Fri, 14 Apr 2000 14:30:55 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.3.99x: SMP race in getblk()?
In-Reply-To: <20000414001735.U831@loth.demon.co.uk>
Message-ID: <Pine.LNX.4.21.0004141423490.9980-100000@maclaurin.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Dodd <steved@loth.demon.co.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 14 Apr 2000, Steve Dodd wrote:

>[CC'd to linux-mm at Rik's suggestion]
>
>This is a first attempt at a fix for what I /think/ is a potential race
>condition in getblk. There seems to be a small window where multiple

Good spotting, that is conceptually necessary. However right now it
coulnd't trigger in real life since it seems the fs are all calling getblk
with the big kernel lock held. But really the raw device access was just
harmed by that SMP race condition.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
