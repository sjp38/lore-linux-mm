Date: Tue, 23 Jan 2001 20:56:34 +0100
From: Christoph Hellwig <hch@ns.caldera.de>
Subject: Re: Questions on mmap()
Message-ID: <20010123205634.A30856@caldera.de>
References: <000201c08575$01127ab0$10401c10@SCHLEPPDOWN>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <000201c08575$01127ab0$10401c10@SCHLEPPDOWN>; from frey@scs.ch on Tue, Jan 23, 2001 at 02:45:12PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: frey@cxau.zko.dec.com
Cc: linux-mm@kvack.org, baettig@scs.ch
List-ID: <linux-mm.kvack.org>

On Tue, Jan 23, 2001 at 02:45:12PM -0500, Martin Frey wrote:
> Dear all,
> 
> I'm trying to write an example on how to export kmalloc()
> and vmalloc() allocated areas from a device driver into
> user space. The example is running so far, but I want to
> make sure to have all the details right.
>
> [...]

How about:
ftp://ftp.de.kernel.org/pub/linux/kernel/people/sct/raw-io/kiobuf.2.3.99.pre9-2.tar.gz?

	Christoph

-- 
Whip me.  Beat me.  Make me maintain AIX.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
