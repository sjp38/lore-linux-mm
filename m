Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id EDE0F6B0038
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 08:45:05 -0400 (EDT)
Received: by laeb10 with SMTP id b10so68928896lae.1
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 05:45:05 -0700 (PDT)
Received: from mail-la0-x230.google.com (mail-la0-x230.google.com. [2a00:1450:4010:c03::230])
        by mx.google.com with ESMTPS id qc10si3132081lbb.17.2015.09.08.05.45.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 05:45:04 -0700 (PDT)
Received: by lanb10 with SMTP id b10so67712521lan.3
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 05:45:03 -0700 (PDT)
Subject: Re: [PATCH V2 2/4] mm/kasan: MODULE_VADDR is not available on all
 archs
References: <1441614519-20298-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1441614519-20298-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <55EED858.9080005@gmail.com>
Date: Tue, 8 Sep 2015 15:45:12 +0300
MIME-Version: 1.0
In-Reply-To: <1441614519-20298-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/07/2015 11:28 AM, Aneesh Kumar K.V wrote:
> Use is_module_address instead
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: Andrey Ryabinin <ryabinin.a.a@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
