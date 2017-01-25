Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DEDFF6B0033
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 08:10:59 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id d140so37994213wmd.4
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 05:10:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d62si22350070wmf.8.2017.01.25.05.10.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 05:10:58 -0800 (PST)
Date: Wed, 25 Jan 2017 14:10:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6 v3] kvmalloc
Message-ID: <20170125131054.GR32377@dhcp22.suse.cz>
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170124151752.GO6867@dhcp22.suse.cz>
 <1485273626.16328.301.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1485273626.16328.301.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, Andreas Dilger <adilger@dilger.ca>, Andreas Dilger <andreas.dilger@intel.com>, Anton Vorontsov <anton@enomsg.org>, Ben Skeggs <bskeggs@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Colin Cross <ccross@android.com>, Dan Williams <dan.j.williams@intel.com>, David Sterba <dsterba@suse.com>, Eric Dumazet <edumazet@google.com>, Hariprasad S <hariprasad@chelsio.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Ilya Dryomov <idryomov@gmail.com>, Kees Cook <keescook@chromium.org>, Kent Overstreet <kent.overstreet@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Oleg Drokin <oleg.drokin@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Santosh Raspatur <santosh@chelsio.com>, Tariq Toukan <tariqt@mellanox.com>, Theodore Ts'o <tytso@mit.edu>, Tom Herbert <tom@herbertland.com>, Tony Luck <tony.luck@intel.com>, "Yan, Zheng" <zyan@redhat.com>, Yishai Hadas <yishaih@mellanox.com>

On Tue 24-01-17 08:00:26, Eric Dumazet wrote:
> On Tue, 2017-01-24 at 16:17 +0100, Michal Hocko wrote:
> > On Thu 12-01-17 16:37:11, Michal Hocko wrote:
> 
> > Are there any more comments? I would really appreciate to hear from
> > networking folks before I resubmit the series.
> 
> I do not see any issues right now.
> 
> I am happy to see this thing finally coming, after years of
> resistance ;)

OK, so I will repost the series and ask Andrew for inclusion
after it passes my compile test battery after the rebase.
 
Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
