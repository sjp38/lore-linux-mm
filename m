Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0426B0036
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 20:05:59 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so197153pad.11
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 17:05:59 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id kg4si12950051pad.239.2014.07.15.17.05.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jul 2014 17:05:58 -0700 (PDT)
Message-ID: <53C5C1C9.6070100@zytor.com>
Date: Tue, 15 Jul 2014 17:05:29 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 3/11] x86, mm, pat: Change reserve_memtype() to handle
 WT type
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>	 <1405452884-25688-4-git-send-email-toshi.kani@hp.com>	 <CALCETrUPpP1Lo1gB_eTm6V3pJ3Fam-1gPZGKfksOXXGgtNGsEQ@mail.gmail.com>	 <1405465801.28702.34.camel@misato.fc.hp.com>	 <CALCETrUx+HkzBmTZo-BtOcOz7rs=oNcavJ9Go536Fcn2ugdobg@mail.gmail.com> <1405468387.28702.53.camel@misato.fc.hp.com>
In-Reply-To: <1405468387.28702.53.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>, Andy Lutomirski <luto@amacapital.net>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Dave Airlie <airlied@gmail.com>, Borislav Petkov <bp@alien8.de>

On 07/15/2014 04:53 PM, Toshi Kani wrote:
> 
> Right.
> 
> I think using struct page table for the RAM ranges is a good way for
> saving memory, but I wonder how often the RAM ranges are mapped other
> than WB...  If not often, reserve_memtype() could simply call
> rbt_memtype_check_insert() for all ranges, including RAM.
> 
> In this patch, I left using reserve_ram_pages_type() since I do not see
> much reason to use WT for RAM, either.
> 

They get flipped to WC or WT or even UC for some I/O devices, but
ultimately the number of ranges is pretty small.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
