Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 67B6090008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 15:30:10 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id v10so5703016pde.22
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 12:30:10 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id tt5si7339932pab.180.2014.10.30.12.30.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Oct 2014 12:30:08 -0700 (PDT)
Date: Thu, 30 Oct 2014 20:30:05 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: initialize variable for mem_cgroup_end_page_stat
Message-ID: <20141030193005.GX12706@worktop.programming.kicks-ass.net>
References: <1414633464-19419-1-git-send-email-sasha.levin@oracle.com>
 <20141030082712.GB4664@dhcp22.suse.cz>
 <54523DDE.9000904@oracle.com>
 <20141030141401.GA24520@phnom.home.cmpxchg.org>
 <54524A2F.5050907@oracle.com>
 <20141030153159.GA3639@dhcp22.suse.cz>
 <20141030172632.GA25217@phnom.home.cmpxchg.org>
 <20141030174241.GD3639@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141030174241.GD3639@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Sasha Levin <sasha.levin@oracle.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, riel@redhat.com, linux-mm@kvack.org

On Thu, Oct 30, 2014 at 06:42:41PM +0100, Michal Hocko wrote:
> Well, I would use a typedef to obfuscate those values because nobody
> except for mem_cgroup_{begin,end}_page_stat should touch them. But we
> are not doing typedefs in kernel...

$ git grep typedef | wc -l
11379

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
