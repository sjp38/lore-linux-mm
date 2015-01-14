Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 42CF06B0071
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 10:42:13 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so11763808wiv.1
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 07:42:12 -0800 (PST)
Received: from mail-we0-x22a.google.com (mail-we0-x22a.google.com. [2a00:1450:400c:c03::22a])
        by mx.google.com with ESMTPS id q6si3665816wiz.104.2015.01.14.07.42.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 Jan 2015 07:42:12 -0800 (PST)
Received: by mail-we0-f170.google.com with SMTP id w61so9539702wes.1
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 07:42:12 -0800 (PST)
Date: Wed, 14 Jan 2015 16:42:10 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm: memcontrol: fold move_anon() and move_file()
Message-ID: <20150114154210.GG4706@dhcp22.suse.cz>
References: <1421175592-14179-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421175592-14179-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 13-01-15 13:59:52, Johannes Weiner wrote:
> Turn the move type enum into flags and give the flags field a shorter
> name.  Once that is done, move_anon() and move_file() are simple
> enough to just fold them into the callsites.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

one nit below

> ---
>  mm/memcontrol.c | 49 ++++++++++++++++++-------------------------------
>  1 file changed, 18 insertions(+), 31 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5a5769e8b12c..692e96407627 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -360,21 +360,18 @@ static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
>  
>  /* Stuffs for move charges at task migration. */
>  /*
> - * Types of charges to be moved. "move_charge_at_immitgrate" and
> - * "immigrate_flags" are treated as a left-shifted bitmap of these types.
> + * Types of charges to be moved.
>   */
> -enum move_type {
> -	MOVE_CHARGE_TYPE_ANON,	/* private anonymous page and swap of it */
> -	MOVE_CHARGE_TYPE_FILE,	/* file page(including tmpfs) and swap of it */
> -	NR_MOVE_TYPE,
> -};
> +#define MOVE_ANON	0x1U
> +#define MOVE_FILE	0x2U
> +#define MOVE_MASK	0x3U

#define MOVE_MASK	(MOVE_ANON | MOVE_FILE)

would be probably better
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
