Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 5ED286B00E1
	for <linux-mm@kvack.org>; Wed,  8 May 2013 11:53:55 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rl6so1441137pac.14
        for <linux-mm@kvack.org>; Wed, 08 May 2013 08:53:54 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v5, part4 05/41] score: normalize global variables exported by vmlinux.lds
Date: Wed,  8 May 2013 23:51:02 +0800
Message-Id: <1368028298-7401-6-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1368028298-7401-1-git-send-email-jiang.liu@huawei.com>
References: <1368028298-7401-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Chen Liqin <liqin.chen@sunplusct.com>, Lennox Wu <lennox.wu@gmail.com>

Generate mandatory global variables _sdata in file vmlinux.lds.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Chen Liqin <liqin.chen@sunplusct.com>
Cc: Lennox Wu <lennox.wu@gmail.com>
Cc: linux-kernel@vger.kernel.org
---
 arch/score/kernel/vmlinux.lds.S |    1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/score/kernel/vmlinux.lds.S b/arch/score/kernel/vmlinux.lds.S
index eebcbaa..7274b5c 100644
--- a/arch/score/kernel/vmlinux.lds.S
+++ b/arch/score/kernel/vmlinux.lds.S
@@ -49,6 +49,7 @@ SECTIONS
 	}
 
 	. = ALIGN(16);
+	_sdata =  .;			/* Start of data section */
 	RODATA
 
 	EXCEPTION_TABLE(16)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
