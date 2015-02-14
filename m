Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6E16F900015
	for <linux-mm@kvack.org>; Sat, 14 Feb 2015 02:32:23 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so24057552pdb.4
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 23:32:23 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id td4si3111257pbc.77.2015.02.13.23.32.21
        for <linux-mm@kvack.org>;
        Fri, 13 Feb 2015 23:32:22 -0800 (PST)
Message-ID: <54DEFA03.6010308@lge.com>
Date: Sat, 14 Feb 2015 16:32:19 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm: cma: add functions to get region pages counters
References: <cover.1423777850.git.s.strogin@partner.samsung.com> <c6a3312c9eb667f0f5330c313f328bc49f7addd9.1423777850.git.s.strogin@partner.samsung.com>
In-Reply-To: <c6a3312c9eb667f0f5330c313f328bc49f7addd9.1423777850.git.s.strogin@partner.samsung.com>
Content-Type: text/plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Strogin <s.strogin@partner.samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Dmitry Safonov <d.safonov@partner.samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, pavel@ucw.cz, stefan.strogin@gmail.com



2015-02-13 ?AAu 7:15?! Stefan Strogin AI(?!)  3/4 ' +-U:
> From: Dmitry Safonov <d.safonov@partner.samsung.com>
> 
> Here are two functions that provide interface to compute/get used size
> and size of biggest free chunk in cma region.

I usually just try to allocate memory, not check free size before try,
becuase free size can be changed after I check it.

Could you tell me why biggest free chunk size is necessary?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
