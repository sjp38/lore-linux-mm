Date: Wed, 23 May 2001 10:35:18 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Running out of vmalloc space
Message-ID: <20010523103518.X8080@redhat.com>
References: <3B04069C.49787EC2@fc.hp.com> <20010517183931.V2617@redhat.com> <3B045546.312BA42E@fc.hp.com> <3B0AF30D.8D25806A@fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3B0AF30D.8D25806A@fc.hp.com>; from dp@fc.hp.com on Tue, May 22, 2001 at 05:15:26PM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Pinedo <dp@fc.hp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, May 22, 2001 at 05:15:26PM -0600, David Pinedo wrote:
> I followed up on the suggestion of several folks to not map the graphics
> board into kernel vm space. While investigating how to do that, I
> discovered that the frame buffer space did not need to be mapped -- it
> was already being mapped with the control space. So instead of needing
> (32M+16M)*2=96M of vmalloc space, I only need 32M*2=64M. That change
> seemed easier than figuring out how not to map the board into kernel vm
> space, so...

...so you'll end up with a driver which will work fine as long as
nobody tries to load it in parallel with another driver which tries to
pull the same stunt.  It's an easy way out which doesn't work if
everybody takes the same easy way out.

I *really* think you need to be avoiding the mapping in the first
place if at all possible.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
