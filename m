Subject: Re: [OOPS] 2.5.69-mm6
References: <20030516015407.2768b570.akpm@digeo.com>
	<87fznfku8z.fsf@lapper.ihatent.com>
	<20030516180848.GW8978@holomorphy.com>
	<20030516185638.GA19669@suse.de>
	<20030516191711.GX8978@holomorphy.com>
	<Pine.LNX.4.50.0305162322360.2023-100000@montezuma.mastecende.com>
	<Pine.LNX.4.50.0305170937350.1910-100000@montezuma.mastecende.com>
From: Alexander Hoogerhuis <alexh@ihatent.com>
Date: 19 May 2003 10:23:58 +0200
In-Reply-To: <Pine.LNX.4.50.0305170937350.1910-100000@montezuma.mastecende.com>
Message-ID: <87u1brbazl.fsf@lapper.ihatent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zwane Mwaikambo <zwane@linuxpower.ca>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave Jones <davej@codemonkey.org.uk>, Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Zwane Mwaikambo <zwane@linuxpower.ca> writes:

> On Fri, 16 May 2003, Zwane Mwaikambo wrote:
> 
> > Could you alco specify your GCC version? Your disassembly looks rather 
> > odd.
> 
> I am unable to reproduce this with DRI/AGP built into the kernel or 
> as a module. X11 Setup is Radeon 9100 w/ XFree86 4.3
> 

Once I compile DRM/AGP as non-modular all errors are gone:

agpgart: Detected an Intel i845 Chipset.
agpgart: Maximum main memory to use for agp memory: 690M
agpgart: AGP aperture is 256M @ 0xa0000000
[drm] Initialized radeon 1.8.0 20020828 on minor 0
.
.
.
agpgart: Found an AGP 2.0 compliant device at 00:00.0.
agpgart: Putting AGP V2 device at 00:00.0 into 4x mode
agpgart: Putting AGP V2 device at 01:00.0 into 4x mode

> 	Zwane

mvh,
A
- -- 
Alexander Hoogerhuis                               | alexh@ihatent.com
CCNP - CCDP - MCNE - CCSE                          | +47 908 21 485
"You have zero privacy anyway. Get over it."  --Scott McNealy
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Processed by Mailcrypt 3.5.8 <http://mailcrypt.sourceforge.net/>

iD8DBQE+yJSbCQ1pa+gRoggRAtXLAJ477jbu6VI41OdQHCBGacK4wSb2uQCeNvFi
DMYymuyGsHhEUUrjH4PQtuA=
=EekR
-----END PGP SIGNATURE-----
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
