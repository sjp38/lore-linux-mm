Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id C082D6B0035
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 07:24:48 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id z12so13224143wgg.15
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 04:24:48 -0800 (PST)
Received: from pandora.arm.linux.org.uk (gw-1.arm.linux.org.uk. [78.32.30.217])
        by mx.google.com with ESMTPS id wg1si22980473wjb.115.2014.01.03.04.24.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 03 Jan 2014 04:24:47 -0800 (PST)
Date: Fri, 3 Jan 2014 12:22:06 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: ARM: mm: Could I change module space size or place modules in
	vmalloc area?
Message-ID: <20140103122206.GK7383@n2100.arm.linux.org.uk>
References: <002001cf07a1$fd4bdc10$f7e39430$@lge.com> <201401031310.09930.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201401031310.09930.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, HyoJun Im <hyojun.im@lge.com>

On Fri, Jan 03, 2014 at 01:10:09PM +0100, Arnd Bergmann wrote:
> Aside from the good comments that Russell made, I would remark that the
> fact that you need multiple megabytes worth of modules indicates that you
> are doing something wrong. Can you point to a git tree containing those
> modules?

>From the comments which have been made, one point that seems to have
been identified is that if this module is first stripped and then
loaded, it can load, but if it's unstripped, it's too big.  This sounds
suboptimal to me - the debug info shouldn't be loaded into the kernel.

However, I guess there's bad interactions with module signing if you
don't do this and the module was signed with the debug info present,
so I don't think there's a good solution for this.

-- 
FTTC broadband for 0.8mile line: 5.8Mbps down 500kbps up.  Estimation
in database were 13.1 to 19Mbit for a good line, about 7.5+ for a bad.
Estimate before purchase was "up to 13.2Mbit".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
