Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id C07716B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 05:15:53 -0400 (EDT)
Received: by lamp12 with SMTP id p12so22949983lam.0
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 02:15:53 -0700 (PDT)
Received: from mail-la0-x231.google.com (mail-la0-x231.google.com. [2a00:1450:4010:c03::231])
        by mx.google.com with ESMTPS id ay7si22537775lbc.60.2015.09.03.02.15.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 02:15:52 -0700 (PDT)
Received: by lamp12 with SMTP id p12so22949603lam.0
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 02:15:51 -0700 (PDT)
Subject: Re: [PATCH 4/4] kasan: Prevent deadlock in kasan reporting
References: <1441266863-5435-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1441266863-5435-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <55E80FCE.6010000@gmail.com>
Date: Thu, 3 Sep 2015 12:15:58 +0300
MIME-Version: 1.0
In-Reply-To: <1441266863-5435-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/03/2015 10:54 AM, Aneesh Kumar K.V wrote:
> We we end up calling kasan_report in real mode, our shadow mapping

s/We we/We

> for even spinlock variable will show poisoned. This will result
> in us calling kasan_report_error with lock_report spin lock held.
> To prevent this disable kasan reporting when we are priting

s/priting/printing 

> error w.r.t kasan.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  mm/kasan/report.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 

Reviewed-by: Andrey Ryabinin <ryabinin.a.a@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
