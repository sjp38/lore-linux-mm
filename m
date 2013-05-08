Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 630506B00AA
	for <linux-mm@kvack.org>; Wed,  8 May 2013 15:02:11 -0400 (EDT)
Date: Wed, 8 May 2013 21:02:08 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH v5, part4 35/41] mm/SPARC: prepare for removing
	num_physpages and simplify mem_init()
Message-ID: <20130508190208.GA13601@merkur.ravnborg.org>
References: <1368028298-7401-1-git-send-email-jiang.liu@huawei.com> <1368028298-7401-36-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368028298-7401-36-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, sparclinux@vger.kernel.org

On Wed, May 08, 2013 at 11:51:32PM +0800, Jiang Liu wrote:
> Prepare for removing num_physpages and simplify mem_init().
> 
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Sam Ravnborg <sam@ravnborg.org>
> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Cc: Tang Chen <tangchen@cn.fujitsu.com>
> Cc: sparclinux@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: Sam Ravnborg <sam@ravnborg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
