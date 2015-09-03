Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9CF0C6B0255
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 04:47:07 -0400 (EDT)
Received: by lbbmp1 with SMTP id mp1so20288725lbb.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 01:47:06 -0700 (PDT)
Received: from mail-la0-x230.google.com (mail-la0-x230.google.com. [2a00:1450:4010:c03::230])
        by mx.google.com with ESMTPS id d1si22454743laa.119.2015.09.03.01.47.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 01:47:06 -0700 (PDT)
Received: by laeb10 with SMTP id b10so24115050lae.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 01:47:05 -0700 (PDT)
Subject: Re: [PATCH 3/4] kasan: Don't use kasan shadow pointer in generic
 functions
References: <1441266863-5435-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1441266863-5435-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <55E80910.20406@gmail.com>
Date: Thu, 3 Sep 2015 11:47:12 +0300
MIME-Version: 1.0
In-Reply-To: <1441266863-5435-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/03/2015 10:54 AM, Aneesh Kumar K.V wrote:
> We can't use generic functions like print_hex_dump to access kasan
> shadow region. This require us to setup another kasan shadow region
> for the address passed (kasan shadow address). Most architecture won't
> be able to do that.

s/Most architecture/Some architectures

At least ARM/ARM64/x86 are able to do that.


> Hence make a copy of the shadow region row and
> pass that to generic functions.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  mm/kasan/report.c | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)

Anyway, for this patch:
	Reviewed-by: Andrey Ryabinin <ryabinin.a.a@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
