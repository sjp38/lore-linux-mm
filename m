Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id D0A306B0038
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 16:19:37 -0500 (EST)
Received: by mail-oi0-f48.google.com with SMTP id v63so20270419oia.7
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 13:19:37 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id a20si2789470oig.130.2015.01.28.13.19.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 13:19:36 -0800 (PST)
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YGa1R-003Cmy-02
	for linux-mm@kvack.org; Wed, 28 Jan 2015 21:19:37 +0000
Date: Wed, 28 Jan 2015 13:19:29 -0800
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 0/4] Introduce <linux/mm_struct.h>
Message-ID: <20150128211929.GA22571@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 28, 2015 at 11:16:47PM +0200, Kirill A. Shutemov wrote:
> 
> Fixlet for AVR32:
> 
> diff --git a/arch/avr32/include/asm/pgtable.h b/arch/avr32/include/asm/pgtable.h
> index 35800664076e..3af39532b25b 100644

Also applied.

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
