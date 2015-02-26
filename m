Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1BAEB6B0032
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 10:23:38 -0500 (EST)
Received: by wghb13 with SMTP id b13so11878123wgh.0
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 07:23:37 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0060.outbound.protection.outlook.com. [157.55.234.60])
        by mx.google.com with ESMTPS id eq4si2024119wjd.112.2015.02.26.07.23.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 26 Feb 2015 07:23:35 -0800 (PST)
Message-ID: <54EF3A6D.1090808@ezchip.com>
Date: Thu, 26 Feb 2015 10:23:25 -0500
From: Chris Metcalf <cmetcalf@ezchip.com>
MIME-Version: 1.0
Subject: Re: [PATCHv3 13/17] tile: expose number of page table levels
References: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com> <1424950520-90188-14-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1424950520-90188-14-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2/26/2015 6:35 AM, Kirill A. Shutemov wrote:
> We would want to use number of page table level to define mm_struct.
> Let's expose it as CONFIG_PGTABLE_LEVELS.
>
> Signed-off-by: Kirill A. Shutemov<kirill.shutemov@linux.intel.com>
> Cc: Chris Metcalf<cmetcalf@ezchip.com>
> Tested-by: Guenter Roeck<linux@roeck-us.net>
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
