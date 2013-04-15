Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id E147C6B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 09:14:45 -0400 (EDT)
Date: Mon, 15 Apr 2013 15:14:36 +0200
From: Jesper Nilsson <jesper.nilsson@axis.com>
Subject: Re: [RFC PATCH v1 13/19] mm/CRIS: clean up unused VALID_PAGE()
Message-ID: <20130415131436.GC11974@axis.com>
References: <1365867399-21323-1-git-send-email-jiang.liu@huawei.com>
 <1365867399-21323-14-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365867399-21323-14-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jespern@axis.com>, linux-cris-kernel <linux-cris-kernel@axis.com>

On Sat, Apr 13, 2013 at 05:36:33PM +0200, Jiang Liu wrote:
> VALID_PAGE() has been removed from kernel long time ago, so clean up it.
> 
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Cc: Mikael Starvik <starvik@axis.com>
> Cc: Jiang Liu <jiang.liu@huawei.com>
> Cc: linux-cris-kernel@axis.com
> Cc: linux-kernel@vger.kernel.org

Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>

/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
