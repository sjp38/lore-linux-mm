Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA15633
	for <linux-mm@kvack.org>; Mon, 8 Feb 1999 06:22:36 -0500
Date: Mon, 8 Feb 1999 11:22:15 GMT
Message-Id: <199902081122.LAA02263@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Large memory system
In-Reply-To: <19990130083631.B9427@msc.cornell.edu>
References: <19990130083631.B9427@msc.cornell.edu>
Sender: owner-linux-mm@kvack.org
To: Daniel Blakeley <daniel@msc.cornell.edu>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 30 Jan 1999 08:36:31 -0500, Daniel Blakeley
<daniel@msc.cornell.edu> said:

> I've jumped the gun a little bit and recommended a Professor buy 4GB
> of RAM on a Xeon machine to run Linux on and he did.  After he got it
> I read the large memory howto which states that the max memory size
> for Linux 2.2.x is 2GB physical/2GB virtual.  The memory size seems to
> limited by the 32bit nature of the x86 architecture.  The Xeon seems
> to have a 36bit memory addressing mode.  Can Linux be easily expanded
> to use the 36bit addressing?

It's not exactly trivial, but it can (and will) be done.  For now, you
can only use 4G on a 64-bit architecture (Alpha or Sparc64), but
basically we know how to address it on Intel too, transparently to the
user.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
