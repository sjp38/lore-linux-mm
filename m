Received: from dukat.scot.redhat.com (sct@[195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA13478
	for <linux-mm@kvack.org>; Tue, 23 Mar 1999 12:32:23 -0500
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14071.53276.848923.609704@dukat.scot.redhat.com>
Date: Tue, 23 Mar 1999 17:32:12 +0000 (GMT)
Subject: Re: LINUX-MM 
In-Reply-To: <199903231549.KAA20478@x15-cruise-basselope>
References: <Pine.LNX.4.03.9903231514290.10060-100000@mirkwood.dummy.home>
	<199903231549.KAA20478@x15-cruise-basselope>
Sender: owner-linux-mm@kvack.org
To: Kev <klmitch@MIT.EDU>
Cc: Rik van Riel <riel@nl.linux.org>, Matthias Arnold <Matthias.Arnold@edda.imsid.uni-jena.de>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 23 Mar 1999 10:49:11 EST, Kev <klmitch@MIT.EDU> said:

>> IIRC there's a slight bug in some of the newer kernels
>> where the swap cache isn't being freed when you exit
>> your program, but only later on when the system tries
>> to reclaim memory...

> I believe the problem lies in the fact that there is not enough
> SysV shared memory available.

It's nothing to do with SysV shared memory. 

The behaviour is there, but the only impact on the normal user will be
that "free" lies a little.  No big deal: it just shows up as cache.  The
effect is only a matter of when we recover the memory, not whether we
recover it.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
