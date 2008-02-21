Received: by py-out-1112.google.com with SMTP id f47so2832016pye.20
        for <linux-mm@kvack.org>; Thu, 21 Feb 2008 03:01:21 -0800 (PST)
Message-ID: <2f11576a0802210301sb162ac9u6cf4ba4d5cb179b4@mail.gmail.com>
Date: Thu, 21 Feb 2008 20:01:20 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] the proposal of improve page reclaim by throttle
In-Reply-To: <47BD48F3.3040903@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080219134715.7E90.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <47BD48F3.3040903@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi balbir-san

>  It's good to keep the main reclaim code and the memory controller reclaim in
>  sync, so this is a nice effort.

thank you.
I will repost next version (fixed nick's opinion) while a few days.

>  > @@ -1456,7 +1501,7 @@ unsigned long try_to_free_mem_cgroup_pag
>  >       int target_zone = gfp_zone(GFP_HIGHUSER_MOVABLE);
>  >
>  >       zones = NODE_DATA(numa_node_id())->node_zonelists[target_zone].zones;
>  > -     if (do_try_to_free_pages(zones, sc.gfp_mask, &sc))
>  > +     if (try_to_free_pages_throttled(zones, 0, sc.gfp_mask, &sc))
>  >               return 1;
>  >       return 0;
>  >  }
>
>  try_to_free_pages_throttled checks for zone_watermark_ok(), that will not work
>  in the case that we are reclaiming from a cgroup which over it's limit. We need
>  a different check, to see if the mem_cgroup is still over it's limit or not.

That makes sense.

unfortunately, I don't know mem-cgroup so much.
What do i use function, instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
