Date: Sat, 3 May 2003 00:22:06 +0100 (BST)
From: Matt Bernstein <mb--lkml@dcs.qmul.ac.uk>
Subject: Re: 2.5.68-mm4
In-Reply-To: <1051910420.2166.55.camel@spc9.esa.lanl.gov>
Message-ID: <Pine.LNX.4.55.0305030014130.1304@jester.mews>
References: <20030502020149.1ec3e54f.akpm@digeo.com>
 <1051905879.2166.34.camel@spc9.esa.lanl.gov>  <20030502133405.57207c48.akpm@digeo.com>
  <1051908541.2166.40.camel@spc9.esa.lanl.gov>  <20030502140508.02d13449.akpm@digeo.com>
 <1051910420.2166.55.camel@spc9.esa.lanl.gov>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On May 2 Steven Cole wrote:

>Here is a snippet from dmesg output for a successful kexec e100 boot:

Bizarrely I have a nasty crash on modprobing e100 *without* kexec (having
previously modprobed unix, af_packet and mii) and then trying to modprobe
serio (which then deadlocks the machine).

	http://www.dcs.qmul.ac.uk/~mb/oops/

More information available on request

Matt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
