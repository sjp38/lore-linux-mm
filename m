Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1366B00DE
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 03:38:00 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id p10so13114086pdj.5
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 00:38:00 -0800 (PST)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id zy8si17462814pbc.39.2014.11.04.00.37.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 00:37:59 -0800 (PST)
Received: from kw-mxoi1.gw.nic.fujitsu.com (unknown [10.0.237.133])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6F2AC3EE1C3
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 17:37:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 6F6A4AC042F
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 17:37:57 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FA8E1DB8032
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 17:37:57 +0900 (JST)
Message-ID: <54589052.7000609@jp.fujitsu.com>
Date: Tue, 4 Nov 2014 17:37:38 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 2/3] mm: page_cgroup: rename file to mm/swap_cgroup.c
References: <1414898156-4741-1-git-send-email-hannes@cmpxchg.org> <1414898156-4741-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1414898156-4741-2-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

(2014/11/02 12:15), Johannes Weiner wrote:
> Now that the external page_cgroup data structure and its lookup is
> gone, the only code remaining in there is swap slot accounting.
> 
> Rename it and move the conditional compilation into mm/Makefile.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
