Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA09629
	for <linux-mm@kvack.org>; Mon, 10 May 1999 15:37:50 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14135.13698.659905.454361@dukat.scot.redhat.com>
Date: Mon, 10 May 1999 20:37:38 +0100 (BST)
Subject: Re: [PATCH] dirty pages in memory & co.
In-Reply-To: <m1pv4ddj3z.fsf@flinx.ccr.net>
References: <m1pv4ddj3z.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On 07 May 1999 09:56:00 -0500, ebiederm+eric@ccr.net (Eric W. Biederman)
said:

>        It looks like I need 2 variations on generic_file_write at the
>        moment. 
>        1) for network filesystems that can get away without filling
>           the page on a partial write.
>        2) for block based filesystems that must fill the page on a
>           partial write because they can't write arbitrary chunks of
>           data.

I'd be very worried by (1): sounds like a partial write followed by a
read of the full page could show up garbage in the page cache if you do
this.  If NFS skips the page clearing for partial writes, how does it
avoid returning garbage later?

--Stephen


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
