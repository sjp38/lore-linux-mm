Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 71B8A6B00C1
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 02:07:11 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6ADB73EE0C8
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 15:07:09 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5493945DE4F
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 15:07:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A01645DE4D
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 15:07:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C5611DB8037
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 15:07:09 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DC4881DB803E
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 15:07:08 +0900 (JST)
Message-ID: <50483D6D.6070005@jp.fujitsu.com>
Date: Thu, 06 Sep 2012 15:06:37 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/3] use get_page_migratetype instead of page_private
References: <1346908619-16056-1-git-send-email-minchan@kernel.org> <1346908619-16056-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1346908619-16056-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>

(2012/09/06 14:16), Minchan Kim wrote:
> page allocator uses set_page_private and page_private for handling
> migratetype when it frees page. Let's replace them with [set|get]
> _freepage_migratetype to make it more clear.
> 
> * from v1
>    * Change set_page_migratetype with set_freepage_migratetype
>    * Add comment on set_freepage_migratetype
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>

seems good to me.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
