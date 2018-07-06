Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 90ADE6B0003
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 10:44:06 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id t10-v6so7241171pfh.0
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 07:44:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d64-v6sor2164199pgc.202.2018.07.06.07.44.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 06 Jul 2018 07:44:04 -0700 (PDT)
Date: Fri, 6 Jul 2018 23:44:00 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] zmalloc: hide unused lock_zspage
Message-ID: <20180706144400.GB411@tigerII.localdomain>
References: <20180706130924.3891230-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180706130924.3891230-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Colin Ian King <colin.king@canonical.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Desaulniers <nick.desaulniers@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (07/06/18 15:09), Arnd Bergmann wrote:
> 
> 
> Fixes: 0de664ada6b6 ("mm/zsmalloc.c: make several functions and a struct static")

This one is still in mmotm/linux-next. Do you mind if we just squash
them?

	-ss
