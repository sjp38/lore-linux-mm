Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 39CA86B006C
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 14:29:11 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id y19so28616801wgg.11
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 11:29:10 -0800 (PST)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id ng6si10974083wic.39.2015.01.30.11.29.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 30 Jan 2015 11:29:09 -0800 (PST)
Message-ID: <54CBDB81.5030709@nod.at>
Date: Fri, 30 Jan 2015 20:29:05 +0100
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [PATCH 16/19] um: expose number of page table levels
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com> <1422629008-13689-17-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422629008-13689-17-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, Jeff Dike <jdike@addtoit.com>

Am 30.01.2015 um 15:43 schrieb Kirill A. Shutemov:
> We would want to use number of page table level to define mm_struct.
> Let's expose it as CONFIG_PGTABLE_LEVELS.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Jeff Dike <jdike@addtoit.com>
> Cc: Richard Weinberger <richard@nod.at>

Acked-by: Richard Weinberger <richard@nod.at>

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
