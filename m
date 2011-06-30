Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D25A36B0012
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 12:10:02 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <f5f6fc78-5d54-4ea7-abbb-9c0cb14391dc@default>
Date: Thu, 30 Jun 2011 09:09:37 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: frontswap/zcache: xvmalloc discussion
References: <4E023F61.8080904@linux.vnet.ibm.com>
 <0a3a5959-5d8f-4f62-a879-34266922c59f@default
 4E03B75A.9040203@linux.vnet.ibm.com
 89b9d94d-27d1-4f51-ab7e-b2210b6b0eb5@default
 f6415652-5925-4aad-b8be-900ce3afd902@default>
In-Reply-To: <f6415652-5925-4aad-b8be-900ce3afd902@default>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@suse.de>, Dave Hansen <dave@sr71.net>

> FWIW, I've measured the distribution of zsize (pages compressed
> with frontswap) on my favorite workload (kernel "make -j2" on
> mem=3D512M to force lots of swapping) and the mean is small, close
> to 1K (PAGE_SIZE/4).  I've added some sysfs shows for both
> the current and cumulative distribution (0-63 bytes, 64-127
> bytes, ..., 4032-4095 bytes) for the next update.
>=20
> I tried your program on the text of Moby Dick and the mean
> was still under 1500 bytes ((3*PAGE_SIZE)/8) with a good
> broad distribution for zsize.

Oops, on retry this morning, I am now clearly seeing the poor
compression.  Not sure what is different from last night,
but I suspect I was "watch"ing the new sysfs output during
massive swapping during the run of the test program and
it wasn't updated until program completion (at which point
I was no longer perusing the sysfs output).

Sorry for the noise.  However, now that I have a test case
I am implementing another sysfs tunable to reject poorly-
compressible pages that would drive the mean zsize
above the tunable.  Zcache will reject these pages until
the mean falls below the threshold.  (Setting it to
PAGE_SIZE will continue current behavior, but I've set
the default to (5*PAGE_SIZE)/8 for now.)

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
