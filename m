Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 400D06B009A
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 16:31:07 -0400 (EDT)
Received: by dakp5 with SMTP id p5so4183622dak.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 13:31:07 -0700 (PDT)
Message-ID: <4FC92685.9070604@gmail.com>
Date: Fri, 01 Jun 2012 16:31:01 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] proc: add /proc/kpageorder interface
References: <201206011854.25795.b.zolnierkie@samsung.com>
In-Reply-To: <201206011854.25795.b.zolnierkie@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Matt Mackall <mpm@selenic.com>, kosaki.motohiro@gmail.com

(6/1/12 12:54 PM), Bartlomiej Zolnierkiewicz wrote:
> From: Bartlomiej Zolnierkiewicz<b.zolnierkie@samsung.com>
> Subject: [PATCH] proc: add /proc/kpageorder interface
>
> This makes page order information available to the user-space.

No usecase new feature always should be NAKed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
