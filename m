Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 9A4146B006C
	for <linux-mm@kvack.org>; Fri, 30 Jan 2015 09:49:24 -0500 (EST)
Received: by mail-we0-f179.google.com with SMTP id q59so27554501wes.10
        for <linux-mm@kvack.org>; Fri, 30 Jan 2015 06:49:24 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0088.outbound.protection.outlook.com. [157.55.234.88])
        by mx.google.com with ESMTPS id dx1si7073921wib.72.2015.01.30.06.49.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 30 Jan 2015 06:49:22 -0800 (PST)
Message-ID: <54CB99E8.7000501@ezchip.com>
Date: Fri, 30 Jan 2015 09:49:12 -0500
From: Chris Metcalf <cmetcalf@ezchip.com>
MIME-Version: 1.0
Subject: Re: [PATCH 15/19] tile: expose number of page table levels
References: <1422629008-13689-1-git-send-email-kirill.shutemov@linux.intel.com> <1422629008-13689-16-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422629008-13689-16-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>

On 1/30/2015 9:43 AM, Kirill A. Shutemov wrote:
> We would want to use number of page table level to define mm_struct.
> Let's expose it as CONFIG_PGTABLE_LEVELS.
>
> Signed-off-by: Kirill A. Shutemov<kirill.shutemov@linux.intel.com>
> Cc: Chris Metcalf<cmetcalf@ezchip.com>
> ---
>   arch/tile/Kconfig | 5 +++++
>   1 file changed, 5 insertions(+)

Acked-by: Chris Metcalf <cmetcalf@ezchip.com>

-- 
Chris Metcalf, EZChip Semiconductor
http://www.ezchip.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
