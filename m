Date: Thu, 28 Dec 2006 19:36:08 +0100 (MET)
From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: [PATCH] introduce config option to disable DMA zone on i386
In-Reply-To: <20061228170302.GA4335@dmt>
Message-ID: <Pine.LNX.4.61.0612281933570.23545@yvahk01.tjqt.qr>
References: <20061228170302.GA4335@dmt>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, olpc-devel@laptop.org
List-ID: <linux-mm.kvack.org>

On Dec 28 2006 15:03, Marcelo Tosatti wrote:
>
>Comments?
>
>+config NO_DMA_ZONE
         ^^^^^^
>+	bool "DMA zone support"
              ^^^
>+	default n
                ^
>+	help
>+	 This disables support for the 16MiB DMA zone. Only enable this 
>+	 option if you are certain that your devices contain no DMA
>+	 addressing limitations.

The naming could be a bit better. If I have
  [*] DMA zone support
it should actually enable the DMA zone, not disable it. Wind it like you
prefer, either
(1) config NO_DMA_ZONE, bool "Disable DMA zone" default n or
(2) config DMA_ZONE, bool "[Enable] DMA zone" default y


	-`J'
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
