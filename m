Message-Id: <99Sep24.094756bst.66313@gateway.ukaea.org.uk>
Date: Fri, 24 Sep 1999 09:48:36 +0100
From: Neil Conway <nconway.list@UKAEA.ORG.UK>
MIME-Version: 1.0
Subject: Re: syslinux-1.43 bug [and possible PATCH]
References: <199909232109.OAA13866@google.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: syslinux@linux.kernel.org, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Kanoj Sarcar wrote:
> While installing linux (RedHat6.0, SuSe, Mandrake etc) on a ia32
> Compaq box with 1.5Gb memory, I have observed kernel panics from
> mount_root. On further investigation, syslinux decides to put initrd
> at a high physical address, which the Linux kernel, compiled with
> PAGE_OFFSET=0xc0000000 can not access. The kernel can access at
> the most physical address 0x3c000000, whereas syslinux/ldlinux.asm
> can put initrd as high as HIGHMEM_MAX=0x3f000000. This leads
> setup_arch() to decide it can not use initrd, thus causing the
> kernel panic.

Yup...

> Have other people run into this problem and worked around it some
> other way? (One way would be to specify mem= at the boot: prompt
> from syslinux. Yet another way seems to be to specify mem= in
> the syslinux.cfg file. Changing HIGHMEM_MAX seems to be the cleanest,
> although I am not sure whether this will impact the capability of
> syslinux to install other os'es).

I don't think "mem=" would help at all but I could be wrong.

My "easy" fix was to pull out a DIMM from each of our machines, leaving
3x256 :-)  Not elegant, but fast!

Neil
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
