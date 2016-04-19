Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id E19046B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 06:57:02 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l15so10360940lfg.2
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 03:57:02 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.130])
        by mx.google.com with ESMTPS id qr6si25815917wjc.243.2016.04.19.03.57.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 03:57:01 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] arch/defconfig: remove CONFIG_RESOURCE_COUNTERS
Date: Tue, 19 Apr 2016 12:56:55 +0200
Message-ID: <4214150.v1WFzl5UmK@wuerfel>
In-Reply-To: <146105442758.18940.2792564159961963110.stgit@zurg>
References: <146105442758.18940.2792564159961963110.stgit@zurg>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, x86@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

On Tuesday 19 April 2016 11:27:07 Konstantin Khlebnikov wrote:
> This option replaced by PAGE_COUNTER which is selected by MEMCG.
> 
> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
> 
Acked-by: Arnd Bergmann <arnd@arndb.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
