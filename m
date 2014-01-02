Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 636436B0035
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 05:14:04 -0500 (EST)
Received: by mail-ee0-f52.google.com with SMTP id d17so6187636eek.11
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 02:14:03 -0800 (PST)
Received: from mx.tkos.co.il (guitar.tcltek.co.il. [192.115.133.116])
        by mx.google.com with ESMTP id l44si64998963eem.61.2014.01.02.02.14.02
        for <linux-mm@kvack.org>;
        Thu, 02 Jan 2014 02:14:02 -0800 (PST)
Date: Thu, 2 Jan 2014 12:13:59 +0200
From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: ARM: mm: Could I change module space size or place modules in
 vmalloc area?
Message-ID: <20140102101359.GU6589@tarshish>
References: <002001cf07a1$fd4bdc10$f7e39430$@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <002001cf07a1$fd4bdc10$f7e39430$@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, HyoJun Im <hyojun.im@lge.com>

Hi Gioh,

On Thu, Jan 02, 2014 at 07:04:13PM +0900, Gioh Kim wrote:
> I run out of module space because I have several big driver modules.
> I know I can strip the modules to decrease size but I need debug info now.

Are you sure you need the debug info in kernel memory? I don't think the 
kernel is actually able to parse DWARF. You can load stripped binaries into 
the kernel, and still use the debug info with whatever tool you have.

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
