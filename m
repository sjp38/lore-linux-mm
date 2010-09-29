Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 798E16B004A
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 10:06:57 -0400 (EDT)
Date: Wed, 29 Sep 2010 23:06:54 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [BUGFIX][PATCH] memcg: fix thresholds with use_hierarchy == 1
Message-Id: <20100929230654.d7f20d2c.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20100929230252.f593abb1.d-nishimura@mtf.biglobe.ne.jp>
References: <1285763245-19408-1-git-send-email-kirill@shutemov.name>
	<20100929230252.f593abb1.d-nishimura@mtf.biglobe.ne.jp>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutsemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> I think you can simplify this part by using parent_mem_cgroup() like:
> 
> 	parent = parent_mem_cgroup(memcg);
> 	if (!memcg)
           ^^^^^^^^ must be !parent of course :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
