Sender: Giu
Message-ID: <3BDAB344.CE25D5D@denise.shiny.it>
Date: Sat, 27 Oct 2001 15:14:44 +0200
From: Giuliano Pochini <pochini@denise.shiny.it>
MIME-Version: 1.0
Subject: Re: xmm2 - monitor Linux MM active/inactive lists graphically
References: <Pine.LNX.4.31.0110250920270.2184-100000@cesium.transmeta.com> <dnr8rqu30x.fsf@magla.zg.iskon.hr>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-Path: <pochini@denise.shiny.it>
To: zlatko.calusic@iskon.hr
Cc: Linus Torvalds <torvalds@transmeta.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


> block: 1024 slots per queue, batch=341
> 
> Wrote 600.00 MB in 71 seconds -> 8.39 MB/s (7.5 %CPU)
> 
> Still very spiky, and during the write disk is uncapable of doing any
> reads. IOW, no serious application can be started before writing has
> finished. Shouldn't we favour reads over writes? Or is it just that
> the elevator is not doing its job right, so reads suffer?
>
>    procs                      memory    swap          io     system         cpu
>  r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
>  0  1  1      0   3596    424 453416   0   0     0 40468  189   508   2   2  96

341*127K = ~40M.

Batch is too high. It doesn't explain why reads get delayed so much, anyway.

Bye.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
