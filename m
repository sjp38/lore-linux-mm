Message-ID: <403D674E.3010705@cyberone.com.au>
Date: Thu, 26 Feb 2004 14:26:06 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: SMP vm benchmarking
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is the same configuration as last time, but with SMP kernels
and 2 CPUs. SMP doesn't change much.

kernel | run | -j5 | -j10 | -j15 |
2.6.3    1     139   1077    2500
2.6.3    2     164   1146    2414

-mm2     1     135    684    1302
-mm2     2     167    737    1531

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
