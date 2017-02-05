Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 32CD56B0033
	for <linux-mm@kvack.org>; Sun,  5 Feb 2017 05:23:30 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id h7so12445197wjy.6
        for <linux-mm@kvack.org>; Sun, 05 Feb 2017 02:23:30 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 90si37919847wrc.20.2017.02.05.02.23.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 05 Feb 2017 02:23:29 -0800 (PST)
Date: Sun, 5 Feb 2017 11:23:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6 v3] kvmalloc
Message-ID: <20170205102319.GF22713@dhcp22.suse.cz>
References: <20170130094940.13546-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170130094940.13546-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>, Andreas Dilger <adilger@dilger.ca>, Andreas Dilger <andreas.dilger@intel.com>, Andrey Konovalov <andreyknvl@google.com>, Anton Vorontsov <anton@enomsg.org>, Ben Skeggs <bskeggs@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Colin Cross <ccross@android.com>, Daniel Borkmann <daniel@iogearbox.net>, Dan Williams <dan.j.williams@intel.com>, David Sterba <dsterba@suse.com>, Eric Dumazet <edumazet@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, Hariprasad S <hariprasad@chelsio.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Ilya Dryomov <idryomov@gmail.com>, John Hubbard <jhubbard@nvidia.com>, Kees Cook <keescook@chromium.org>, Kent Overstreet <kent.overstreet@gmail.com>, Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Oleg Drokin <oleg.drokin@intel.com>, Pablo Neira Ayuso <pablo@netfilter.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Santosh Raspatur <santosh@chelsio.com>, Tariq Toukan <tariqt@mellanox.com>, Tom Herbert <tom@herbertland.com>, Tony Luck <tony.luck@intel.com>, "Yan, Zheng" <zyan@redhat.com>, Yishai Hadas <yishaih@mellanox.com>

Is there anything more to be done before this can get merged? I would
relly like to target this to the next merge window. I already have some
more changes which depend on this.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
