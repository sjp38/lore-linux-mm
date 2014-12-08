Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id CD7C96B0038
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 11:02:54 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so5457532pab.14
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 08:02:54 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cu3si60519489pbc.108.2014.12.08.08.02.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Dec 2014 08:02:53 -0800 (PST)
Date: Mon, 8 Dec 2014 11:02:40 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol.c:  Cleaning up function that are not
 used anywhere
Message-ID: <20141208160240.GA21664@phnom.home.cmpxchg.org>
References: <1417884356-3086-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417884356-3086-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Cc: Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Dec 06, 2014 at 05:45:56PM +0100, Rickard Strandqvist wrote:
> Remove function mem_cgroup_lru_names_not_uptodate() that is not used anywhere.
> And move BUILD_BUG_ON() to the beginning of memcg_stat_show() instead.
> 
> This was partially found by using a static code analysis program called cppcheck.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

Looks good, thanks for following up.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
