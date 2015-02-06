Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id B4FD66B006C
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 11:26:27 -0500 (EST)
Received: by mail-qa0-f43.google.com with SMTP id v10so11590044qac.2
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 08:26:27 -0800 (PST)
Received: from mail-qa0-x235.google.com (mail-qa0-x235.google.com. [2607:f8b0:400d:c00::235])
        by mx.google.com with ESMTPS id u18si3322613qag.111.2015.02.06.08.26.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Feb 2015 08:26:26 -0800 (PST)
Received: by mail-qa0-f53.google.com with SMTP id n4so11579782qaq.12
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 08:26:26 -0800 (PST)
Message-ID: <54D4EB2E.4050106@twiddle.net>
Date: Fri, 06 Feb 2015 08:26:22 -0800
From: Richard Henderson <rth@twiddle.net>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RESEND 01/19] alpha: expose number of page table levels
 on Kconfig level
References: <1423234264-197684-1-git-send-email-kirill.shutemov@linux.intel.com> <1423234264-197684-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423234264-197684-2-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>

On 02/06/2015 06:50 AM, Kirill A. Shutemov wrote:
> We would want to use number of page table level to define mm_struct.
> Let's expose it as CONFIG_PGTABLE_LEVELS.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Richard Henderson <rth@twiddle.net>
> Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
> Cc: Matt Turner <mattst88@gmail.com>
> Tested-by: Guenter Roeck <linux@roeck-us.net>

Acked-by: Richard Henderson <rth@twiddle.net>


r~

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
