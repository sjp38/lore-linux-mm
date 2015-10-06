Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4C8A66B0254
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 15:22:28 -0400 (EDT)
Received: by qgt47 with SMTP id 47so183802070qgt.2
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 12:22:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l9si29997229qhl.13.2015.10.06.12.22.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Oct 2015 12:22:27 -0700 (PDT)
Date: Tue, 6 Oct 2015 12:22:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: convert threshold to bytes
Message-Id: <20151006122225.8a499b42f49d8484b61632a8@linux-foundation.org>
In-Reply-To: <20151006170122.GB2752@dhcp22.suse.cz>
References: <fc100a5a381d1961c3b917489eb82b098d9e0840.1444081366.git.shli@fb.com>
	<20151006170122.GB2752@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Shaohua Li <shli@fb.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>

On Tue, 6 Oct 2015 19:01:23 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Mon 05-10-15 14:44:22, Shaohua Li wrote:
> > The page_counter_memparse() returns pages for the threshold, while
> > mem_cgroup_usage() returns bytes for memory usage. Convert the threshold
> > to bytes.
> > 
> > Looks a regression introduced by 3e32cb2e0a12b69150
> 
> Yes. This suggests
> Cc: stable # 3.19+

But it's been this way for 2 years and nobody noticed it.  How come?

Or at least, nobody reported it.  Maybe people *have* noticed it, and
adjusted their userspace appropriately.  In which case this patch will
cause breakage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
