Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id KAA15603
	for <linux-mm@kvack.org>; Sun, 13 Oct 2002 10:47:19 -0700 (PDT)
Message-ID: <3DA9B1A7.A747ADD6@digeo.com>
Date: Sun, 13 Oct 2002 10:47:19 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.42-mm2
References: <3DA7C3A5.98FCC13E@digeo.com> <20021013101949.GB2032@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> @@ -1104,6 +1126,7 @@ static void __init free_area_init_core(s
>                         pcp->low = 0;
>                         pcp->high = 32;
>                         pcp->batch = 16;
> +                       pcp->reserved = 0;
>                         INIT_LIST_HEAD(&pcp->list);
>                 }
>                 INIT_LIST_HEAD(&zone->active_list);

OK.  But that's been there since 2.5.40-mm2.  Why did it suddenly
bite?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
