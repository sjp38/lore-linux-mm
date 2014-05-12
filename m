Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 71E706B0037
	for <linux-mm@kvack.org>; Mon, 12 May 2014 03:51:58 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e53so4347522eek.11
        for <linux-mm@kvack.org>; Mon, 12 May 2014 00:51:57 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.24])
        by mx.google.com with ESMTPS id z48si9832157eey.293.2014.05.12.00.51.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 May 2014 00:51:57 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC][PATCH 2/2] ARM: ioremap: Add IO mapping space reused support.
Date: Mon, 12 May 2014 09:51:41 +0200
Message-ID: <5146762.jba3IJe7xt@wuerfel>
In-Reply-To: <1399861195-21087-3-git-send-email-superlibj8301@gmail.com>
References: <1399861195-21087-1-git-send-email-superlibj8301@gmail.com> <1399861195-21087-3-git-send-email-superlibj8301@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Richard Lee <superlibj8301@gmail.com>, linux@arm.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Richard Lee <superlibj@gmail.com>

On Monday 12 May 2014 10:19:55 Richard Lee wrote:
> For the IO mapping, for the same physical address space maybe
> mapped more than one time, for example, in some SoCs:
> 0x20000000 ~ 0x20001000: are global control IO physical map,
> and this range space will be used by many drivers.
> And then if each driver will do the same ioremap operation, we
> will waste to much malloc virtual spaces.
> 
> This patch add IO mapping space reused support.
> 
> Signed-off-by: Richard Lee <superlibj@gmail.com>

What happens if the first driver then unmaps the area?

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
