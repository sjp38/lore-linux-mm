Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA19436
	for <linux-mm@kvack.org>; Thu, 18 Feb 1999 10:19:55 -0500
Date: Thu, 18 Feb 1999 15:06:06 GMT
Message-Id: <199902181506.PAA09793@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: MM question
In-Reply-To: <9902160001.AA15015@bigalpha.imi.com>
References: <9902160001.AA15015@bigalpha.imi.com>
Sender: owner-linux-mm@kvack.org
To: Jason Titus <jason@iatlas.com>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 15 Feb 1999 21:30:22 -0500, "Jason Titus" <jason@iatlas.com>
said:

> Is there a way to turn off/down the page caching and buffering?  I'm doing
> database work and am having a really time benchmarking other elements of the
> system due to Linux's friendly caching....

No.

You can tune a few different aspects of the VM's management of the
caches, but there is really no way to disable them completely.

> It sure would be nice to have more control over the caching, like being able
> to have a /etc/cache.conf file where you could set parameters and mark
> certain files/filetypes as priority cache items...

Why exactly do you need it?  For plain benchmarking, the standard
technique to defeat caching is to benchmark on files much larger than
physical memory.  

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
