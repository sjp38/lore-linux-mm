Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB7C36B02EE
	for <linux-mm@kvack.org>; Fri, 12 May 2017 07:04:04 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y65so40524232pff.13
        for <linux-mm@kvack.org>; Fri, 12 May 2017 04:04:04 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id o82si3132400pfi.82.2017.05.12.04.04.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 May 2017 04:04:04 -0700 (PDT)
Date: Fri, 12 May 2017 14:04:01 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: mm/kasan: zero_p4d_populate() problem?
Message-ID: <20170512110401.xbmkfp4alatikyuq@black.fi.intel.com>
References: <20170512055320.GA16929@js1304-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170512055320.GA16929@js1304-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org

On Fri, May 12, 2017 at 02:53:22PM +0900, Joonsoo Kim wrote:
> Hello, Kirill.
> 
> I found that zero_p4d_populate() in mm/kasan/kasan_init.c of
> next-20170511 doesn't get the benefit of the kasan_zero_pud.
> Do we need to fix it by adding
> "pud_populate(&init_mm, pud, lm_alias(kasan_zero_pud));" when
> alignment requirement is met?

It's not a fix, but optimization. But it makes sense to implement this.

Feel free to send a patch.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
