Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA10990
	for <linux-mm@kvack.org>; Thu, 21 Jan 1999 10:12:08 -0500
Date: Thu, 21 Jan 1999 15:11:57 GMT
Message-Id: <199901211511.PAA01303@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Large Swap
In-Reply-To: <36A67DC2.DF27FFEE@sybase.com>
References: <36A67DC2.DF27FFEE@sybase.com>
Sender: owner-linux-mm@kvack.org
To: Jason Froebe <jfroebe@sybase.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 20 Jan 1999 19:07:14 -0600, Jason Froebe <jfroebe@sybase.com>
said:

> Hi,
> I'm sorry if I'm asking in the wrong mailing list but I'm in a
> rush.  A few days ago a message was posted to the linux-mm list
> describing swap space > 128mb files.  What exactly do I need for
> this capability?  

The mkswap from a recent (2.9g is the current) "util-linux" package is
all you need.  The 2.1/2.2 kernel will automatically recognise a large
swap partition once you have built one.

> Also, if this is in the 2.1.x and 2.2.x has it been put in the 2.0.x
> kernels?

No, but it would not be hard to back-port.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
