Date: Fri, 18 May 2001 11:21:03 +0300
From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: Running out of vmalloc space
Message-ID: <20010518112103.M5947@mea-ext.zmailer.org>
References: <A33AEFDC2EC0D411851900D0B73EBEF766DC8B@NAPA>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <A33AEFDC2EC0D411851900D0B73EBEF766DC8B@NAPA>; from hji@netscreen.com on Thu, May 17, 2001 at 02:58:29PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hua Ji <hji@netscreen.com>
Cc: Christoph Hellwig <hch@caldera.de>, David Pinedo <dp@fc.hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 17, 2001 at 02:58:29PM -0700, Hua Ji wrote:
> FYI:
>   http://www.linux-mm.org/more_than_1GB.shtml
> The above url gives a good introduction for what we are discussing. 

No.  That is repeating Kanoj's patch logic.  What got into 2.4 kernel
is slightly different.

But like Stephen wondered, is there truly need to map the cards entirely
into KERNEL space at all ?    It is fairly trivial to create mmap() driver
function to map them to user-space process.

In display drivers I can understand a need to map parts (control registers,
including command pipeline insert points) of the cards to kernel, but not
all of the buffer spaces -- at least not all the time.

/Matti Aarnio
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
