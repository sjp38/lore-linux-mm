Received: from lynx.msc.cornell.edu (LYNX.MSC.CORNELL.EDU [128.84.231.190])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA32071
	for <linux-mm@kvack.org>; Sat, 30 Jan 1999 08:36:42 -0500
Received: from malcolm.msc.cornell.edu (1330@MALCOLM.MSC.CORNELL.EDU [128.84.231.138])
	by lynx.msc.cornell.edu (8.9.1a/8.9.1) with ESMTP id IAA13034
	for <linux-mm@kvack.org>; Sat, 30 Jan 1999 08:36:31 -0500 (EST)
From: Daniel Blakeley <daniel@msc.cornell.edu>
Received: (from daniel@localhost)
	by malcolm.msc.cornell.edu (8.9.1a/8.9.0) id IAA09498
	for linux-mm@kvack.org; Sat, 30 Jan 1999 08:36:31 -0500
Message-ID: <19990130083631.B9427@msc.cornell.edu>
Date: Sat, 30 Jan 1999 08:36:31 -0500
Subject: Large memory system
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I've jumped the gun a little bit and recommended a Professor buy 4GB
of RAM on a Xeon machine to run Linux on and he did.  After he got it
I read the large memory howto which states that the max memory size
for Linux 2.2.x is 2GB physical/2GB virtual.  The memory size seems to
limited by the 32bit nature of the x86 architecture.  The Xeon seems
to have a 36bit memory addressing mode.  Can Linux be easily expanded
to use the 36bit addressing?

Thanks for any info on the subject.

- Daniel (Who needs to read more before recommending computers.)

--
Daniel Blakeley (N2YEN)     Cornell Center for Materials Research
daniel@msc.cornell.edu      E20 Clark Hall
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
