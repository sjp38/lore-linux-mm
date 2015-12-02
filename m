Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 63F826B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 04:17:52 -0500 (EST)
Received: by oige206 with SMTP id e206so20906635oig.2
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 01:17:52 -0800 (PST)
Received: from cmccmta1.chinamobile.com (cmccmta1.chinamobile.com. [221.176.66.79])
        by mx.google.com with ESMTP id c2si1981158oif.16.2015.12.02.01.17.50
        for <linux-mm@kvack.org>;
        Wed, 02 Dec 2015 01:17:51 -0800 (PST)
Date: Wed, 2 Dec 2015 17:16:27 +0800
From: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Subject: Re: [PATCH v2] mm: fix warning in comparing enumerator
Message-ID: <20151202091626.GA2811@yaowei-K42JY>
References: <1448959032-754-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.10.1512011425230.19510@chino.kir.corp.google.com>
 <20151201230742.GA13514@www9186uo.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151201230742.GA13514@www9186uo.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <nao.horiguchi@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Dec 02, 2015 at 08:07:42AM +0900, Naoya Horiguchi wrote:
> On Tue, Dec 01, 2015 at 02:25:50PM -0800, David Rientjes wrote:
> > On Tue, 1 Dec 2015, Naoya Horiguchi wrote:
> 
> I saw the following warning when building mmotm-2015-11-25-17-08.
> 
> mm/page_alloc.c:4185:16: warning: comparison between 'enum zone_type' and 'enum <anonymous>' [-Wenum-compare]
>   for (i = 0; i < MAX_ZONELISTS; i++) {
>                 ^
> 
> enum zone_type is named like ZONE_* which is different from ZONELIST_*, so
> we are somehow doing incorrect comparison. Just fixes it.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Yaowei Bai <baiyaowei@cmss.chinamobile.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
