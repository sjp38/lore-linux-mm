Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id B20126B0035
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 07:10:17 -0500 (EST)
Received: by mail-ee0-f47.google.com with SMTP id e51so5665809eek.6
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 04:10:17 -0800 (PST)
Received: from moutng.kundenserver.de (moutng.kundenserver.de. [212.227.126.186])
        by mx.google.com with ESMTPS id w6si70554715eeg.111.2014.01.03.04.10.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 03 Jan 2014 04:10:16 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: ARM: mm: Could I change module space size or place modules in vmalloc area?
Date: Fri, 3 Jan 2014 13:10:09 +0100
References: <002001cf07a1$fd4bdc10$f7e39430$@lge.com>
In-Reply-To: <002001cf07a1$fd4bdc10$f7e39430$@lge.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201401031310.09930.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Gioh Kim <gioh.kim@lge.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, HyoJun Im <hyojun.im@lge.com>

On Thursday 02 January 2014, Gioh Kim wrote:

> I run out of module space because I have several big driver modules.
> I know I can strip the modules to decrease size but I need debug info now.
> 
> The default size of module is 16MB and the size is statically defined in the
> header file. 
> But a description for the module space size tells that it can be
> configurable at most 32MB.
> 
> I have changed the module space size to 18MB and tested my platform.
> It has been looking good.
> 
> I am not sure my patch is proper solution.
> Anyway, could I configure the module space size?
> 
> Or could I place the modules into vmalloc area?
> 

Aside from the good comments that Russell made, I would remark that the
fact that you need multiple megabytes worth of modules indicates that you
are doing something wrong. Can you point to a git tree containing those
modules?

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
