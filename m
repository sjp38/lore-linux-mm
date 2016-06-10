Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id BC3076B0005
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 18:33:08 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id u74so35751139lff.0
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 15:33:08 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id j198si1363006wmj.110.2016.06.10.15.33.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jun 2016 15:33:07 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id m124so1591431wme.3
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 15:33:07 -0700 (PDT)
Date: Sat, 11 Jun 2016 01:33:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: add missing kernel-doc in mm/memory.c::do_set_pte()
Message-ID: <20160610223304.GA25148@node.shutemov.name>
References: <575B01BD.9020809@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <575B01BD.9020809@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 10, 2016 at 11:06:53AM -0700, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix kernel-doc warning in mm/memory.c:
> 
> ..//mm/memory.c:2881: warning: No description found for parameter 'old'
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
