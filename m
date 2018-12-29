Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8217B8E005B
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 04:52:21 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id v16so10074823wru.8
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 01:52:21 -0800 (PST)
Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc. [2a01:7a0:2:106d:670::1])
        by mx.google.com with ESMTPS id 6si22449263wrr.52.2018.12.29.01.52.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 29 Dec 2018 01:52:19 -0800 (PST)
Date: Sat, 29 Dec 2018 10:52:15 +0100
From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] netfilter: account ebt_table_info to kmemcg
Message-ID: <20181229095215.nbcijqacw5b6aho7@breakpoint.cc>
References: <20181229015524.222741-1-shakeelb@google.com>
 <20181229073325.GZ16738@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181229073325.GZ16738@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>, Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Roopa Prabhu <roopa@cumulusnetworks.com>, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org, syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com

Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 28-12-18 17:55:24, Shakeel Butt wrote:
> > The [ip,ip6,arp]_tables use x_tables_info internally and the underlying
> > memory is already accounted to kmemcg. Do the same for ebtables. The
> > syzbot, by using setsockopt(EBT_SO_SET_ENTRIES), was able to OOM the
> > whole system from a restricted memcg, a potential DoS.
> 
> What is the lifetime of these objects? Are they bound to any process?

No, they are not.
They are free'd only when userspace requests it or the netns is
destroyed.
