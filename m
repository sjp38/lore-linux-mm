Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BDE986B0282
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 11:00:35 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 80so242569622pfy.2
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 08:00:35 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id c195si19655658pga.289.2017.01.24.08.00.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 08:00:34 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id 204so16989319pge.2
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 08:00:34 -0800 (PST)
Message-ID: <1485273626.16328.301.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH 0/6 v3] kvmalloc
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Jan 2017 08:00:26 -0800
In-Reply-To: <20170124151752.GO6867@dhcp22.suse.cz>
References: <20170112153717.28943-1-mhocko@kernel.org>
	 <20170124151752.GO6867@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Alexei Starovoitov <ast@kernel.org>, Anatoly Stepanov <astepanov@cloudlinux.com>, Andreas Dilger <adilger@dilger.ca>, Andreas Dilger <andreas.dilger@intel.com>, Anton Vorontsov <anton@enomsg.org>, Ben Skeggs <bskeggs@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Colin Cross <ccross@android.com>, Dan Williams <dan.j.williams@intel.com>, David Sterba <dsterba@suse.com>, Eric Dumazet <edumazet@google.com>, Hariprasad S <hariprasad@chelsio.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Ilya Dryomov <idryomov@gmail.com>, Kees Cook <keescook@chromium.org>, Kent Overstreet <kent.overstreet@gmail.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Oleg Drokin <oleg.drokin@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, "Rafael J.
 Wysocki" <rjw@rjwysocki.net>, Santosh Raspatur <santosh@chelsio.com>, Tariq Toukan <tariqt@mellanox.com>, Theodore Ts'o <tytso@mit.edu>, Tom Herbert <tom@herbertland.com>, Tony Luck <tony.luck@intel.com>, "Yan, Zheng" <zyan@redhat.com>, Yishai Hadas <yishaih@mellanox.com>

On Tue, 2017-01-24 at 16:17 +0100, Michal Hocko wrote:
> On Thu 12-01-17 16:37:11, Michal Hocko wrote:

> Are there any more comments? I would really appreciate to hear from
> networking folks before I resubmit the series.

I do not see any issues right now.

I am happy to see this thing finally coming, after years of
resistance ;)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
