Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id E31156B002C
	for <linux-mm@kvack.org>; Sun,  4 Mar 2012 11:35:21 -0500 (EST)
Received: by lagz14 with SMTP id z14so5247478lag.14
        for <linux-mm@kvack.org>; Sun, 04 Mar 2012 08:35:19 -0800 (PST)
Date: Sun, 4 Mar 2012 18:35:13 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 1/3] vmevent: Fix build for SWAP=n case
In-Reply-To: <20120303000909.GA30207@oksana.dev.rtsoft.ru>
Message-ID: <alpine.LFD.2.02.1203041834180.1636@tux.localdomain>
References: <20120303000909.GA30207@oksana.dev.rtsoft.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org

On Sat, 3 Mar 2012, Anton Vorontsov wrote:
> Caught this build failure:
> 
>   CC      mm/vmevent.o
> mm/vmevent.c:17:6: error: expected identifier or '(' before numeric constant
> mm/vmevent.c:18:1: warning: no semicolon at end of struct or union [enabled by default]
> mm/vmevent.c: In function 'vmevent_sample':
> mm/vmevent.c:84:36: error: expected identifier before numeric constant
> make[1]: *** [mm/vmevent.o] Error 1
> make: *** [mm/] Error 2
> 
> This is because linux/swap.h defines nr_swap_pages to 0L, and so things
> break.
> 
> Fix this by undefinding it back, as we don't use it anyway.
> 
> Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
