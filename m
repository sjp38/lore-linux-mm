Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EAD776B02B4
	for <linux-mm@kvack.org>; Wed, 31 May 2017 11:51:57 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q27so17639922pfi.8
        for <linux-mm@kvack.org>; Wed, 31 May 2017 08:51:57 -0700 (PDT)
Received: from mail-pg0-f68.google.com (mail-pg0-f68.google.com. [74.125.83.68])
        by mx.google.com with ESMTPS id t78si17412482pfi.321.2017.05.31.08.51.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 08:51:57 -0700 (PDT)
Received: by mail-pg0-f68.google.com with SMTP id u13so77839pgb.1
        for <linux-mm@kvack.org>; Wed, 31 May 2017 08:51:57 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/3] replace few other kvmalloc open coded variants
Date: Wed, 31 May 2017 17:51:42 +0200
Message-Id: <20170531155145.17111-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Florian Westphal <fw@strlen.de>, Herbert Xu <herbert@gondor.apana.org.au>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Michal Hocko <mhocko@suse.com>, Pablo Neira Ayuso <pablo@netfilter.org>, Thomas Graf <tgraf@suug.ch>

Hi,
while doing something unrelated I've noticed these few open coded
kvmalloc variants so let's replace them with the library function. Each
patch can be merged separately so I hope I've CCed proper people. This
is based on the current linux-next.

Shortlog
Michal Hocko (3):
      fs/file: replace alloc_fdmem with kvmalloc alternative
      lib/rhashtable.c: use kvzalloc in bucket_table_alloc when possible
      netfilter: use kvmalloc xt_alloc_table_info

Diffstat
 fs/file.c                | 22 ++++------------------
 lib/rhashtable.c         |  7 +++----
 net/netfilter/x_tables.c | 12 ++++--------
 3 files changed, 11 insertions(+), 30 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
