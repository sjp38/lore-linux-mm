Message-ID: <19990923173012.B11766@devserv.devel.redhat.com>
Date: Thu, 23 Sep 1999 17:30:12 -0400
From: Matt Wilson <msw@redhat.com>
Subject: Re: syslinux-1.43 bug [and possible PATCH]
References: <199909232109.OAA13866@google.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199909232109.OAA13866@google.engr.sgi.com>; from Kanoj Sarcar on Thu, Sep 23, 1999 at 02:09:58PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>, syslinux@linux.kernel.org, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

This was fixed in 1.44, AFAIK.  HIGHMEM_MAX is now 38000000h.
We're using 1.45 for our next release.

Matt
msw@redhat.com

On Thu, Sep 23, 1999 at 02:09:58PM -0700, Kanoj Sarcar wrote:
> I have a possible problem to report with syslinux, and a suggested
> fix. Please send me comments and feedback at kanoj@engr.sgi.com, 
> since I am not subscribed to the syslinux or kernel lists.
> 
> While installing linux (RedHat6.0, SuSe, Mandrake etc) on a ia32
> Compaq box with 1.5Gb memory, I have observed kernel panics from 
> mount_root. On further investigation, syslinux decides to put initrd 
> at a high physical address, which the Linux kernel, compiled with 
> PAGE_OFFSET=0xc0000000 can not access. The kernel can access at
> the most physical address 0x3c000000, whereas syslinux/ldlinux.asm
> can put initrd as high as HIGHMEM_MAX=0x3f000000. This leads
> setup_arch() to decide it can not use initrd, thus causing the
> kernel panic. 
> 
> The easy fix to me seems to be to change HIGHMEM_MAX in
> syslinux/ldlinux.asm to 0x3c000000. In fact, I have verified on
> a couple of machines that this will let the installation proceed.
> 
> Have other people run into this problem and worked around it some
> other way? (One way would be to specify mem= at the boot: prompt
> from syslinux. Yet another way seems to be to specify mem= in
> the syslinux.cfg file. Changing HIGHMEM_MAX seems to be the cleanest,
> although I am not sure whether this will impact the capability of
> syslinux to install other os'es).
> 
> Thanks.
> 
> Kanoj
> kanoj@engr.sgi.com
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.rutgers.edu
> Please read the FAQ at http://www.tux.org/lkml/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
