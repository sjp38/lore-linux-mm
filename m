Received: by wa-out-1112.google.com with SMTP id m33so3336268wag.8
        for <linux-mm@kvack.org>; Mon, 18 Feb 2008 13:39:55 -0800 (PST)
Message-ID: <4cefeab80802181339ia9609d3oeb238a9f549fc6e5@mail.gmail.com>
Date: Tue, 19 Feb 2008 03:09:54 +0530
From: "Nitin Gupta" <nitingupta910@gmail.com>
Subject: Announce: ccache release 0.1
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm-cc@laptop.org
Cc: linuxcompressed-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi All,

I am excited to announce first release of ccache - Compressed RAM
based swap device for Linux (2.6.x kernel).
  - Project home: http://code.google.com/p/ccache/
  - ccache-0.1: http://ccache.googlecode.com/files/ccache-0.1.tar.bz2

This is RAM based block device which acts as swap disk. Pages swapped
to this device are compressed and stored in memory itself. This is
especially useful for swapless embedded devices. Also, flash storage
typically used in embedded devices suffer from wear-leveling issues -
so, its very useful if we can avoid using them as swap device.
And yes, its useful for desktops too :)

It does not require any kernel patching. All components are separate
kernel modules:
- Memory allocator (tlsf.ko)
- Compressor (lzo1x_compress.ko)
- Decompressor (lzo1x_decompress.ko)
- Main ccache module (ccache.ko)
(LZO de/compressor is already in mainline but I have included it here
since distros don't ship it by default).
README (or project home) explains compilation and usage in detail.

Some performance numbers for allocator and de/compressor can be found
on project home. Currently it is tested on Linux kernel 2.6.23.x and
2.6.25-rc2 (x86 only). Please mail me/mailing-list any
issues/suggestions you have.

Code reviews will be really helpful! :)

Thanks,
- Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
