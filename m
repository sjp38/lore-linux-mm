Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 21E826B0036
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 19:39:36 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id g10so14738293pdj.15
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 16:39:35 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ph10si43952397pbb.289.2014.01.02.16.39.33
        for <linux-mm@kvack.org>;
        Thu, 02 Jan 2014 16:39:34 -0800 (PST)
From: "Gioh Kim" <gioh.kim@lge.com>
References: <002001cf07a1$fd4bdc10$f7e39430$@lge.com> <20140102101359.GU6589@tarshish>
In-Reply-To: <20140102101359.GU6589@tarshish>
Subject: RE: ARM: mm: Could I change module space size or place modules in vmalloc area?
Date: Fri, 3 Jan 2014 09:39:31 +0900
Message-ID: <002e01cf081c$44a11e70$cde35b50$@lge.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Content-Language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Baruch Siach' <baruch@tkos.co.il>
Cc: 'Russell King' <linux@arm.linux.org.uk>, linux-mm@kvack.org, 'linux-arm-kernel' <linux-arm-kernel@lists.infradead.org>, 'HyoJun Im' <hyojun.im@lge.com>

Thank you for reply.

> -----Original Message-----
> From: Baruch Siach [mailto:baruch@tkos.co.il]
> Sent: Thursday, January 02, 2014 7:14 PM
> To: Gioh Kim
> Cc: Russell King; linux-mm@kvack.org; linux-arm-kernel; HyoJun Im
> Subject: Re: ARM: mm: Could I change module space size or place modules in
> vmalloc area?
> 
> Hi Gioh,
> 
> On Thu, Jan 02, 2014 at 07:04:13PM +0900, Gioh Kim wrote:
> > I run out of module space because I have several big driver modules.
> > I know I can strip the modules to decrease size but I need debug info
> now.
> 
> Are you sure you need the debug info in kernel memory? I don't think the
> kernel is actually able to parse DWARF. You can load stripped binaries
> into the kernel, and still use the debug info with whatever tool you have.

I agree you but driver developers of another team don't agree.
I don't know why but they say they will strip drivers later :-(
So I need to increase modules space size.


> 
> baruch
> 
> --
>      http://baruch.siach.name/blog/                  ~. .~   Tk Open
Systems
> =}------------------------------------------------ooO--U--Ooo------------
> {=
>    - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
