Date: Fri, 22 Sep 2000 02:18:05 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch *] VM deadlock fix
Message-ID: <20000922021805.D23007@athlon.random>
References: <Pine.LNX.4.21.0009211340110.18809-100000@duckman.distro.conectiva> <200009212223.PAA04238@pizda.ninka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200009212223.PAA04238@pizda.ninka.net>; from davem@redhat.com on Thu, Sep 21, 2000 at 03:23:17PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: riel@conectiva.com.br, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 21, 2000 at 03:23:17PM -0700, David S. Miller wrote:
> 
> How did you get away with adding a new member to task_struct yet not
> updating the INIT_TASK() macro appropriately? :-)  Does it really
> compile?

As far as sleep_time is ok to be set to zero its missing initialization is
right.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
