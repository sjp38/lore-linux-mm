Received: from dukat.scot.redhat.com (sct@[195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA24174
	for <linux-mm@kvack.org>; Wed, 24 Mar 1999 09:39:41 -0500
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14072.63745.848487.218980@dukat.scot.redhat.com>
Date: Wed, 24 Mar 1999 14:38:57 +0000 (GMT)
Subject: Re: LINUX-MM
In-Reply-To: <36F8F7DD.6DF9E048@imsid.uni-jena.de>
References: <Pine.LNX.4.03.9903231514290.10060-100000@mirkwood.dummy.home>
	<199903231549.KAA20478@x15-cruise-basselope>
	<14071.53276.848923.609704@dukat.scot.redhat.com>
	<36F895C4.1801DBE6@imsid.uni-jena.de>
	<14072.61375.667166.523842@dukat.scot.redhat.com>
	<36F8F7DD.6DF9E048@imsid.uni-jena.de>
Sender: owner-linux-mm@kvack.org
To: Matthias Arnold <Matthias.Arnold@edda.imsid.uni-jena.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 24 Mar 1999 15:34:05 +0100, Matthias Arnold
<Matthias.Arnold@edda.imsid.uni-jena.de> said:

> The system lost a remarkable amount of memory after each run of my
> programs.After several runs the performance of the machine slowes down
> due to swapping (in other words the system hangs) and I have to
> reboot.

Which kernel precisely?  What does "vmstat 1" look like?  If you
swapoff/swapon between application runs does the effect persist?  What
does the application do?  What does /proc/sys/fs/inode-nr contain?

This does not sound like a result of the swap caching behaviour.  Once
you start swapping that memory _is_ returned (or something is not
working as it should).

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
