Received: by rv-out-0910.google.com with SMTP id l15so2828828rvb.26
        for <linux-mm@kvack.org>; Sat, 29 Dec 2007 23:32:42 -0800 (PST)
Message-ID: <44c63dc40712292332s4a2e7e4aief37a2dbdd03fc21@mail.gmail.com>
Date: Sun, 30 Dec 2007 16:32:42 +0900
From: "minchan Kim" <barrioskmc@gmail.com>
Subject: why do we call clear_active_flags in shrink_inactive_list ?
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

In 2.6.23's shrink_inactive_list function, why do we have to call
clear_active_flags after isolate_lru_pages call ?
IMHO, If it call isolate_lru_pages with "zone->inactive_list", It can
be sure that it is not PG_active. So I think It is unnecessary calling
clear_active_flags. Nonetheless, Why do we have to recheck PG_active
flags wich clear_active_flags.

If it is right, which case it happens that page is set to be PG_active ?

-- 
Thanks,
barrios

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
