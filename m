Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id DB44B6B0253
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 11:57:03 -0500 (EST)
Received: by mail-oi0-f53.google.com with SMTP id m82so18701383oif.2
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 08:57:03 -0800 (PST)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0089.outbound.protection.outlook.com. [157.56.112.89])
        by mx.google.com with ESMTPS id t6si4730480obx.32.2016.02.09.08.57.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 09 Feb 2016 08:57:02 -0800 (PST)
Subject: Re: [PATCH 5/5] tile: query dynamic DEBUG_PAGEALLOC setting
References: <1454565386-10489-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1454565386-10489-6-git-send-email-iamjoonsoo.kim@lge.com>
From: Chris Metcalf <cmetcalf@ezchip.com>
Message-ID: <56BA1A50.9060308@ezchip.com>
Date: Tue, 9 Feb 2016 11:56:48 -0500
MIME-Version: 1.0
In-Reply-To: <1454565386-10489-6-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Takashi Iwai <tiwai@suse.com>, Christoph Lameter <cl@linux.com>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 02/04/2016 12:56 AM, Joonsoo Kim wrote:
> We can disable debug_pagealloc processing even if the code is complied
> with CONFIG_DEBUG_PAGEALLOC. This patch changes the code to query
> whether it is enabled or not in runtime.
>
> Signed-off-by: Joonsoo Kim<iamjoonsoo.kim@lge.com>
> ---
>   arch/tile/mm/init.c | 11 +++++++----
>   1 file changed, 7 insertions(+), 4 deletions(-)

Acked-by: Chris Metcalf <cmetcalf@ezchip.com>

Although I note a typo ("complied") in the git commit message.

-- 
Chris Metcalf, EZChip Semiconductor
http://www.ezchip.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
