Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id D03D36B009E
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 05:15:42 -0400 (EDT)
Date: Mon, 16 Sep 2013 11:15:36 +0200
From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] let CMA depend on MMU
Message-ID: <20130916091536.GK24802@pengutronix.de>
References: <1378840236-3463-1-git-send-email-u.kleine-koenig@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1378840236-3463-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kernel@pengutronix.de, linux-mm@kvack.org

Hello,

On Tue, Sep 10, 2013 at 09:10:36PM +0200, Uwe Kleine-Konig wrote:
> This fixes compilation on my no-MMU platform when enabling CMA because
> several functions/macros like pte_offset_map, mk_pte, pte_unmap or
> put_anon_vma are missing.
I see the issue is fixed by commit
de32a8177f64bc62e1b19c685dd391af664ab13f for 3.12-rc1.

Thanks
Uwe

-- 
Pengutronix e.K.                           | Uwe Kleine-Konig            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
