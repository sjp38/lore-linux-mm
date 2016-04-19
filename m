Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 416346B0253
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 07:33:03 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hb4so17430562pac.3
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 04:33:03 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id w11si11652761pag.49.2016.04.19.04.33.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 04:33:02 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id fs9so6016076pac.2
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 04:33:02 -0700 (PDT)
Subject: Re: [PATCH] arch/defconfig: remove CONFIG_RESOURCE_COUNTERS
References: <146105442758.18940.2792564159961963110.stgit@zurg>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <5716175F.9030001@gmail.com>
Date: Tue, 19 Apr 2016 21:32:47 +1000
MIME-Version: 1.0
In-Reply-To: <146105442758.18940.2792564159961963110.stgit@zurg>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org



On 19/04/16 18:27, Konstantin Khlebnikov wrote:
> This option replaced by PAGE_COUNTER which is selected by MEMCG.
> 
> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
