From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <32852601.1209631141232.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 1 May 2008 17:39:01 +0900 (JST)
Subject: Re: Re: [PATCH] more ZERO_PAGE handling ( was 2.6.24 regression: deadlock on coredump of big process)
In-Reply-To: <48187AE5.4090807@cybernetics.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <48187AE5.4090807@cybernetics.com>
 <4815E932.1040903@cybernetics.com>	<20080429100048.3e78b1ba.kamezawa.hiroyu@jp.fujitsu.com>	<48172C72.1000501@cybernetics.com>	<20080430132516.28f1ee0c.kamezawa.hiroyu@jp.fujitsu.com>	<4817FDA5.1040702@kolumbus.fi>	<20080430141738.e6b80d4b.kamezawa.hiroyu@jp.fujitsu.com>	<20080430051932.GD27652@wotan.suse.de> <20080430143542.2dcf745a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tony Battersby <tonyb@cybernetics.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Mika Penttil? <mika.penttila@kolumbus.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

>This patch fixes the deadlock.  Tested on 2.6.24.5.  Thanks!
>
>Tested-by: Tony Battersby <tonyb@cybernetics.com>
>
thank you for test. I'll post this again when I'm back.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
