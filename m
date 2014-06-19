Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 388086B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 12:36:20 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id r20so3158351wiv.4
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 09:36:19 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id by5si7857986wjc.114.2014.06.19.09.36.18
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 09:36:18 -0700 (PDT)
Date: Thu, 19 Jun 2014 19:36:14 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: kernel BUG - handle_mm_fault - Ubuntu 14.04 kernel
 3.13.0-29-generic
Message-ID: <20140619163614.GA24297@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53A30B63.107@brockmann-consult.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Maloney <peter.maloney@brockmann-consult.de>, Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kamal Mostafa <kamal@canonical.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Thu, Jun 19, 2014 at 06:10:11PM +0200, Peter Maloney wrote:
> Hi, can someone please take a look at this and tell me what is going on?
> 
> The event log reports no ECC errors.
> 
> This machine was working fine with an older Ubuntu version, and has
> failed this way twice since an upgrade 2 weeks ago.
> 
> Symptoms include:
>  - load goes up high, currently 1872.72
>  - "ps -ef" hangs
>  - this time I tested "echo w > /proc/sysrq-trigger" which made the
> local shell and ssh hang, and ctrl+alt+del doesn't work, but machine
> still responds to ping
> 
> Please CC me; I'm not on the list.
> 
> Thanks,
> Peter
> 
> 
> 
> Here's the log:
> 
> Jun 12 15:42:42 node73 kernel: [17196.908781] ------------[ cut here
> ]------------
> Jun 12 15:42:42 node73 kernel: [17196.909789] kernel BUG at
> /build/buildd/linux-3.13.0/mm/memory.c:3756!

Looks like this:

http://lkml.org/lkml/2014/5/8/275

It seems the commit 107437febd49 has added to 3.13.11.3 "extended stable",
but not in other -stable.

Rik, should it be there too?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
