Received: from lappi.waldorf-gmbh.de (ip39.cb.resolution.de [195.30.142.39])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA10012
	for <linux-mm@kvack.org>; Thu, 4 Feb 1999 21:52:06 -0500
Message-ID: <19990204082001.A528@uni-koblenz.de>
Date: Thu, 4 Feb 1999 08:20:01 +0100
From: ralf@uni-koblenz.de
Subject: Re: Ramdisk for > 1GB / >2 GB
References: <004401be4e29$fb998300$c80c17ac@clmsdev>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <004401be4e29$fb998300$c80c17ac@clmsdev>; from Manfred Spraul on Mon, Feb 01, 1999 at 10:25:54PM +0100
Sender: owner-linux-mm@kvack.org
To: Manfred Spraul <masp0008@stud.uni-sb.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 01, 1999 at 10:25:54PM +0100, Manfred Spraul wrote:

> 3) Is more than 2 GB memory a problem that only applies to the i386
> architecture, or is there demand for that on PowerPC, Sparc32?

The limit is even lower, 512mb for the MIPS32 kernel.  This was so far not
a problem since the so far supported machines had a lower maximum but the
problem now showed up big time on the radar, so there will be a MIPS64
kernel with a 1TB maximum soon to solve the problem in the not far future.

  Ralf
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
