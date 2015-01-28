Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6E08A6B0038
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 16:18:19 -0500 (EST)
Received: by mail-oi0-f45.google.com with SMTP id g201so20239031oib.4
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 13:18:19 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id g10si2812308obt.79.2015.01.28.13.18.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 13:18:18 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YGa0A-003CTr-Lf
	for linux-mm@kvack.org; Wed, 28 Jan 2015 21:18:18 +0000
Date: Wed, 28 Jan 2015 13:18:09 -0800
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 0/4] Introduce <linux/mm_struct.h>
Message-ID: <20150128211809.GA31323@roeck-us.net>
References: <1422451064-109023-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20150128185052.GA6118@roeck-us.net>
 <20150128204544.GA15649@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150128204544.GA15649@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 28, 2015 at 10:45:44PM +0200, Kirill A. Shutemov wrote:
[ ... ]

> Could you try this for arm?
> 
> diff --git a/arch/arm/include/asm/pgtable.h b/arch/arm/include/asm/pgtable.h
> index f40354198bad..bb4ae035e5e3 100644

Applied. Test will take a couple of hours to complete since
the testbed is busy right now. You can check the status anytime
at http://server.roeck-us.net:8010/builders.

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
