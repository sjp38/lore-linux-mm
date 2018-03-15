Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE8626B0006
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 08:54:15 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id k17so3204310pfj.10
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 05:54:15 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id r29si3287969pgn.386.2018.03.15.05.54.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 05:54:15 -0700 (PDT)
From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 11/16] treewide: simplify Kconfig dependencies for removed archs
References: <20180314143529.1456168-1-arnd@arndb.de>
	<20180314144614.1632190-1-arnd@arndb.de>
Date: Thu, 15 Mar 2018 14:54:07 +0200
In-Reply-To: <20180314144614.1632190-1-arnd@arndb.de> (Arnd Bergmann's message
	of "Wed, 14 Mar 2018 15:43:46 +0100")
Message-ID: <873711zehc.fsf@purkki.adurom.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-ide@vger.kernel.org, linux-input@vger.kernel.org, netdev@vger.kernel.org, linux-wireless@vger.kernel.org, linux-pwm@vger.kernel.org, linux-rtc@vger.kernel.org, linux-spi@vger.kernel.org, linux-usb@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-fbdev@vger.kernel.org, linux-watchdog@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Arnd Bergmann <arnd@arndb.de> writes:

> A lot of Kconfig symbols have architecture specific dependencies.
> In those cases that depend on architectures we have already removed,
> they can be omitted.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

[...]

>  drivers/net/wireless/cisco/Kconfig   |  2 +-

Acked-by: Kalle Valo <kvalo@codeaurora.org>

-- 
Kalle Valo
