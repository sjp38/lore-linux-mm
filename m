Subject: Re: [PATCH 00/03] Unmapped: Separate unmapped and mapped pages
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20060310034412.8340.90939.sendpatchset@cherry.local>
References: <20060310034412.8340.90939.sendpatchset@cherry.local>
Content-Type: text/plain
Date: Fri, 10 Mar 2006 08:52:18 +0100
Message-Id: <1141977139.2876.15.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus@valinux.co.jp>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Apply on top of 2.6.16-rc5.
> 
> Comments?


my big worry with a split LRU is: how do you keep fairness and balance
between those LRUs? This is one of the things that made the 2.4 VM suck
really badly, so I really wouldn't want this bad...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
