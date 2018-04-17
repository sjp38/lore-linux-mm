Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D66856B0003
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 09:03:05 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id n10so1980484pgq.3
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 06:03:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 33-v6si7027972plg.34.2018.04.17.06.03.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Apr 2018 06:03:04 -0700 (PDT)
Date: Tue, 17 Apr 2018 15:03:00 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC PATCH] mm: correct status code which move_pages() returns
 for zero page
Message-ID: <20180417130300.GF17484@dhcp22.suse.cz>
References: <20180417110615.16043-1-liwang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180417110615.16043-1-liwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>
Cc: linux-mm@kvack.org, ltp@lists.linux.it, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Zi Yan <zi.yan@cs.rutgers.edu>

On Tue 17-04-18 19:06:15, Li Wang wrote:
[...]
> diff --git a/mm/migrate.c b/mm/migrate.c
> index f65dd69..2b315fc 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1608,7 +1608,7 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
>  			continue;
>  
>  		err = store_status(status, i, err, 1);
> -		if (err)
> +		if (!err)
>  			goto out_flush;

This change just doesn't make any sense to me. Why should we bail out if
the store_status is successul? I am trying to wrap my head around the
test case. 6b9d757ecafc ("mm, numa: rework do_pages_move") tried to
explain that move_pages has some semantic issues and the new
implementation might be not 100% replacement. Anyway I am studying the
test case to come up with a proper fix.

>  
>  		err = do_move_pages_to_node(mm, &pagelist, current_node);
> -- 
> 2.9.5
> 

-- 
Michal Hocko
SUSE Labs
