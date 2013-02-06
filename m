Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 895746B005A
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 21:26:52 -0500 (EST)
Received: by mail-vc0-f180.google.com with SMTP id fo13so527240vcb.25
        for <linux-mm@kvack.org>; Tue, 05 Feb 2013 18:26:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130205115722.GF21389@suse.de>
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com>
	<1359972248-8722-2-git-send-email-linfeng@cn.fujitsu.com>
	<20130204160624.5c20a8a0.akpm@linux-foundation.org>
	<20130205115722.GF21389@suse.de>
Date: Tue, 5 Feb 2013 18:26:51 -0800
Message-ID: <CANN689GVFYTqs0wxX3bKZtyBcWf6=gLvS8hFG-65htsnPDknSA@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: hotplug: implement non-movable version of
 get_user_pages() called get_user_pages_non_movable()
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lin Feng <linfeng@cn.fujitsu.com>, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Just nitpicking, but:

On Tue, Feb 5, 2013 at 3:57 AM, Mel Gorman <mgorman@suse.de> wrote:
> +static inline bool zone_is_idx(struct zone *zone, enum zone_type idx)
> +{
> +       /* This mess avoids a potentially expensive pointer subtraction. */
> +       int zone_off = (char *)zone - (char *)zone->zone_pgdat->node_zones;
> +       return zone_off == idx * sizeof(*zone);
> +}

Maybe:
return zone == zone->zone_pgdat->node_zones + idx;
?

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
