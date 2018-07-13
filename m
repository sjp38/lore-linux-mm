Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E4D1E6B000A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 14:55:50 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u68-v6so23473881qku.5
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 11:55:50 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id f26-v6si7256133qte.45.2018.07.13.11.55.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 11:55:49 -0700 (PDT)
Date: Fri, 13 Jul 2018 11:55:45 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH 2/6] mm/swapfile.c: Replace some #ifdef with IS_ENABLED()
Message-ID: <20180713185545.q6bixqbhsdwn3ulr@ca-dmjordan1.us.oracle.com>
References: <20180712233636.20629-1-ying.huang@intel.com>
 <20180712233636.20629-3-ying.huang@intel.com>
 <20180713183819.rszd4ybjfjemlaib@ca-dmjordan1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180713183819.rszd4ybjfjemlaib@ca-dmjordan1.us.oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Fri, Jul 13, 2018 at 11:38:19AM -0700, Daniel Jordan wrote:
> On Fri, Jul 13, 2018 at 07:36:32AM +0800, Huang, Ying wrote:
> > @@ -1260,7 +1257,6 @@ static void swapcache_free(swp_entry_t entry)
> >  	}
> >  }
> >  
> > -#ifdef CONFIG_THP_SWAP
> >  static void swapcache_free_cluster(swp_entry_t entry)
> >  {
> >  	unsigned long offset = swp_offset(entry);
> > @@ -1271,6 +1267,9 @@ static void swapcache_free_cluster(swp_entry_t entry)
> >  	unsigned int i, free_entries = 0;
> >  	unsigned char val;
> >  
> > +	if (!IS_ENABLED(CONFIG_THP_SWAP))
> > +		return;
> > +
> 
> VM_WARN_ON_ONCE(1) here too?

Nevermind, this branch goes away later in the series.
