Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA05881
	for <linux-mm@kvack.org>; Wed, 19 Aug 1998 09:50:53 -0400
Date: Wed, 19 Aug 1998 13:01:41 +0100
Message-Id: <199808191201.NAA00882@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: VFS buffer monitoring 
In-Reply-To: <199808181530.LAA23097@blue.seas.upenn.edu>
References: <199808181530.LAA23097@blue.seas.upenn.edu>
Sender: owner-linux-mm@kvack.org
To: Vladimir Dergachev <vladimid@seas.upenn.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 18 Aug 1998 11:30:59 -0400 (EDT), "Vladimir Dergachev"
<vladimid@seas.upenn.edu> said:

>       2) I looked around in the kernel source and it looks to me that 
>          this stuff isn't visible outside of kernel.. 

Yep.

>          So should I just go and change kernel directly or can I still
>          get by with writing a module ? (or maybe even better , just
>          an ordinary program ? )

You'll need to modify the kernel (linux/fs/buffer.c); the buffer lookup
information is not exported to modules.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
