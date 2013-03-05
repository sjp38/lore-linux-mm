Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 283CF6B0006
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 14:49:36 -0500 (EST)
Date: Tue, 05 Mar 2013 14:49:31 -0500 (EST)
Message-Id: <20130305.144931.750128870084732663.davem@davemloft.net>
Subject: Re: [RFC PATCH v1 22/33] mm/SPARC: use common help functions to
 free reserved pages
From: David Miller <davem@davemloft.net>
In-Reply-To: <1362495317-32682-23-git-send-email-jiang.liu@huawei.com>
References: <1362495317-32682-1-git-send-email-jiang.liu@huawei.com>
	<1362495317-32682-23-git-send-email-jiang.liu@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: liuj97@gmail.com
Cc: akpm@linux-foundation.org, rientjes@google.com, jiang.liu@huawei.com, wency@cn.fujitsu.com, maciej.rutecki@gmail.com, chris2553@googlemail.com, rjw@sisk.pl, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, wujianguo@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sam@ravnborg.org

From: Jiang Liu <liuj97@gmail.com>
Date: Tue,  5 Mar 2013 22:55:05 +0800

> Use common help functions to free reserved pages.
> 
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
