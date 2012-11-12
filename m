Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 35DDD6B005D
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 13:36:36 -0500 (EST)
Date: Mon, 12 Nov 2012 19:36:31 +0100
From: Hans-Christian Egtvedt <egtvedt@samfundet.no>
Subject: Re: [PATCH 2/4] avr32, kconfig: remove HAVE_ARCH_BOOTMEM
Message-ID: <20121112183631.GA18118@samfundet.no>
References: <1352737915-30906-1-git-send-email-js1304@gmail.com>
 <1352737915-30906-2-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1352737915-30906-2-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Haavard Skinnemoen <hskinnemoen@gmail.com>

Around Tue 13 Nov 2012 01:31:53 +0900 or thereabout, Joonsoo Kim wrote:
> Now, there is no code for CONFIG_HAVE_ARCH_BOOTMEM.
> So remove it.

Indeed, thanks for cleaning. In a not too distant future I'll re-establish
the AVR32 tree on kernel.org, I'm just waiting for my account to be
made/enabled again.

> Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
> Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>

Acked-by: Hans-Christian Egtvedt <egtvedt@samfundet.no>

<snipp diff>

-- 
mvh
Hans-Christian Egtvedt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
