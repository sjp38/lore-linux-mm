Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 49A656B00EE
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 04:21:54 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id z10so5837088pdj.6
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 01:21:54 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id wc10si2091692pab.9.2014.06.10.01.21.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Jun 2014 01:21:53 -0700 (PDT)
Message-ID: <5396C03D.6000806@nvidia.com>
Date: Tue, 10 Jun 2014 13:52:21 +0530
From: vsalve <vsalve@nvidia.com>
MIME-Version: 1.0
Subject: Patches for Contiguous Memory Allocator and	get_user_pages()
References: <5396BFDF.3020703@nvidia.com>
In-Reply-To: <5396BFDF.3020703@nvidia.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linaro-mm-sig@lists.linaro.org, m.szyprowski@samsung.com
Cc: linux-mm@kvack.org

Hi Marek,

The patches for "CMA and get_user_pages" seems to be year old as per the 
mailing list link

http://lists.linaro.org/pipermail/linaro-mm-sig/2013-March/003090.html

Is there any latest patch-set for this feature and any updates whether 
these patches are to be pushed into main stream kernel sooner.

Thanks!!!

-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
