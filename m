Subject: Re: MM patches against 2.5.31
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <3D644C70.6D100EA5@zip.com.au>
References: <3D644C70.6D100EA5@zip.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 22 Aug 2002 09:59:17 -0600
Message-Id: <1030031958.14756.479.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2002-08-21 at 20:29, Andrew Morton wrote:
> I've uploaded a rollup of pending fixes and feature work
> against 2.5.31 to
> 
> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.31/2.5.31-mm1/
> 
> The rolled up patch there is suitable for ongoing testing and
> development.  The individual patches are in the broken-out/
> directory and should all be documented.

The good news:  I ran my dbench 1..128 stress test and for the first
time since 2.5.31-vanilla there were _no_ BUG()s reported at all.

The other news:  from dmesg:
kjournald starting.  Commit interval 5 seconds
EXT3 FS 2.4-0.9.16, 02 Dec 2001 on sd(8,3), internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald: page allocation failure. order:0, mode:0x0

The kjournald failure message came out with dbench 48 running on an ext3
partition.  The test continued with only this one instance of this
message.

Steven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
