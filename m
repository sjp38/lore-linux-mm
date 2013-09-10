Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 41F596B0031
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 02:34:14 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so7181869pdj.18
        for <linux-mm@kvack.org>; Mon, 09 Sep 2013 23:34:12 -0700 (PDT)
Date: Mon, 9 Sep 2013 23:34:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm, memcg: add a helper function to check may oom
 condition
In-Reply-To: <522E74DD.5030706@huawei.com>
Message-ID: <alpine.DEB.2.02.1309092333590.20625@chino.kir.corp.google.com>
References: <522E74DD.5030706@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Huang <h.huangqiang@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, hannes@cmpxchg.org, Li Zefan <lizefan@huawei.com>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 10 Sep 2013, Qiang Huang wrote:

> Use helper function to check if we need to deal with oom condition.
> 
> v2:
> Change the function name to oom_gfp_allowed() as suggested by
> David Rientjes.
> 
> Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
