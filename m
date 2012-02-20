Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 4B07D6B004D
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 05:10:39 -0500 (EST)
Received: by eaag11 with SMTP id g11so2489303eaa.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 02:10:37 -0800 (PST)
Message-ID: <4F421A29.6060303@suse.cz>
Date: Mon, 20 Feb 2012 11:02:17 +0100
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Regression: Bad page map in process xyz
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org

Hi,

I'm getting a ton of
BUG: Bad page map in process zypper  pte:676b700029736c6f pmd:44967067
when trying to upgrade the system by:
zypper dup

I bisected that to:
commit afb1c03746aa940374b73a7d5750ee05a2376077
Author: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date:   Fri Feb 17 10:57:58 2012 +1100

    thp: optimize away unnecessary page table locking

thanks,
-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
