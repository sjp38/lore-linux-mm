Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 0FFE06B13F0
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 04:17:59 -0500 (EST)
Received: by lbbgg6 with SMTP id gg6so571297lbb.14
        for <linux-mm@kvack.org>; Tue, 31 Jan 2012 01:17:57 -0800 (PST)
Message-ID: <1328001473.2297.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Subject: Re: [PATCH] fix readahead pipeline break caused by block plug
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 31 Jan 2012 10:17:53 +0100
In-Reply-To: <1328000036.21268.52.camel@sli10-conroe>
References: <1327996780.21268.42.camel@sli10-conroe>
	 <1327999722.2422.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328000036.21268.52.camel@sli10-conroe>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Herbert Poetzl <herbert@13thfloor.at>, Vivek Goyal <vgoyal@redhat.com>, Wu Fengguang <wfg@linux.intel.com>

Le mardi 31 janvier 2012 A  16:53 +0800, Shaohua Li a A(C)crit :

> That added lines should not matter. We still need plug for direct-io
> case.
> Really sorry for this, I should ask you test it before adding the
> Tested-by.

No problem, but I prefer to test it in its final form before adding a TB

I did the test right now and everything seems fine to me, thanks !

Tested-by: Eric Dumazet <eric.dumazet@gmail.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
