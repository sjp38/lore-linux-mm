Date: Mon, 14 Jan 2002 22:46:03 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] page coloring for 2.4.17 kernel
Message-ID: <20020114224603.N5057@redhat.com>
References: <3.0.6.32.20020113204610.007c7a60@boo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3.0.6.32.20020113204610.007c7a60@boo.net>; from jasonp@boo.net on Sun, Jan 13, 2002 at 08:46:10PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jason Papadopoulos <jasonp@boo.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, Jan 13, 2002 at 08:46:10PM -0500, Jason Papadopoulos wrote:
> Hello. Please be patient with this, my first post to linux-mm.
> The included patch modifies the free list in the 2.4.17 kernel
> to support round-robin page coloring. It seems to work okay
> on an Alpha and speeds up a lot of number-crunching code I
> have lying around (lmbench reports some higher bandwidths too).
> The patch is a port of the 2.2.20 version that I recently posted
> to the linux kernelmailing list.

Do you have numbers to show the sort of performance difference it
makes?

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
