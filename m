Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0508D6B0032
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 21:58:01 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id l15so14725240wiw.2
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 18:58:00 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0093.outbound.protection.outlook.com. [157.55.234.93])
        by mx.google.com with ESMTPS id d1si35259081wie.4.2014.12.24.18.57.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 24 Dec 2014 18:58:00 -0800 (PST)
Message-ID: <549B7D2C.4000201@ezchip.com>
Date: Wed, 24 Dec 2014 21:57:48 -0500
From: Chris Metcalf <cmetcalf@ezchip.com>
MIME-Version: 1.0
Subject: Re: [PATCH 34/38] tile: drop pte_file()-related helpers
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com> <1419423766-114457-35-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-35-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On 12/24/2014 7:22 AM, Kirill A. Shutemov wrote:
> We've replaced remap_file_pages(2) implementation with emulation.
> Nobody creates non-linear mapping anymore.
>
> Signed-off-by: Kirill A. Shutemov<kirill.shutemov@linux.intel.com>
> Cc: Chris Metcalf<cmetcalf@ezchip.com>
> ---
>   arch/tile/include/asm/pgtable.h | 11 -----------
>   arch/tile/mm/homecache.c        |  4 ----
>   2 files changed, 15 deletions(-)

Acked-by: Chris Metcalf <cmetcalf@ezchip.com>

-- 
Chris Metcalf, EZChip Semiconductor
http://www.ezchip.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
