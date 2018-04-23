Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1E86B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 19:20:14 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l8-v6so10808959qtb.11
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 16:20:14 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c15si1300389qvj.63.2018.04.23.16.20.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 16:20:13 -0700 (PDT)
Date: Mon, 23 Apr 2018 19:20:11 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
In-Reply-To: <20180423151015.GT17484@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1804231911280.25912@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180418.134651.2225112489265654270.davem@davemloft.net> <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com> <20180420130852.GC16083@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com> <20180420210200.GH10788@bombadil.infradead.org> <alpine.LRH.2.02.1804201704580.25408@file01.intranet.prod.int.rdu2.redhat.com> <20180421144757.GC14610@bombadil.infradead.org>
 <20180422130356.GG17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804231006440.22488@file01.intranet.prod.int.rdu2.redhat.com> <20180423151015.GT17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, bhutchings@solarflare.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>



On Mon, 23 Apr 2018, Michal Hocko wrote:

> On Mon 23-04-18 10:24:02, Mikulas Patocka wrote:
> 
> > > Really, we have a fault injection framework and this sounds like
> > > something to hook in there.
> > 
> > The testing people won't set it up. They install the "kernel-debug" 
> > package and run the tests in it.
> > 
> > If you introduce a hidden option that no one knows about, no one will use 
> > it.
> 
> then make sure people know about it. Fuzzers already do test fault
> injections.

I think that in the long term we can introduce a kernel parameter like 
"debug_level=1", "debug_level=2", "debug_level=3" that will turn on 
debugging features across all kernel subsystems and we can teach users to 
use it to diagnose problems.

But it won't work if every subsystem has different debug parameters. There 
are 192 distinct filenames in debugfs, if we add 193rd one, harly anyone 
notices it.

Mikulas
