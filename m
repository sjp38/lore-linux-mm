Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 82A5B6B0003
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 06:41:24 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v14so3768577wmd.3
        for <linux-mm@kvack.org>; Fri, 02 Feb 2018 03:41:24 -0800 (PST)
Received: from mail.us.es (mail.us.es. [193.147.175.20])
        by mx.google.com with ESMTPS id y101si1070083wmh.38.2018.02.02.03.41.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Feb 2018 03:41:23 -0800 (PST)
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id A8D702519B8
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 12:41:22 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 864C5C8832
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 12:41:22 +0100 (CET)
Date: Fri, 2 Feb 2018 12:41:18 +0100
From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [netfilter-core] kernel panic: Out of memory and no killable
 processes... (2)
Message-ID: <20180202114118.6iktfm26wadxflfe@salvia>
References: <20180129182811.fze4vrb5zd5cojmr@node.shutemov.name>
 <20180129223522.GG5906@breakpoint.cc>
 <20180130075226.GL21609@dhcp22.suse.cz>
 <20180130081127.GH5906@breakpoint.cc>
 <20180130082817.cbax5qj4mxancx4b@node.shutemov.name>
 <CACT4Y+bFKwoxopr1dwnc7OHUoHy28ksVguqtMY6tD=aRh-7LyQ@mail.gmail.com>
 <20180130095739.GV21609@dhcp22.suse.cz>
 <20180130140104.GE21609@dhcp22.suse.cz>
 <20180130140111.GM5906@breakpoint.cc>
 <20180130143958.GG21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180130143958.GG21609@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Florian Westphal <fw@strlen.de>, Dmitry Vyukov <dvyukov@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Miller <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev <netdev@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Yang Shi <yang.s@alibaba-inc.com>, syzkaller-bugs@googlegroups.com, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, guro@fb.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Jan 30, 2018 at 03:39:58PM +0100, Michal Hocko wrote:
> On Tue 30-01-18 15:01:11, Florian Westphal wrote:
> > > From d48e950f1b04f234b57b9e34c363bdcfec10aeee Mon Sep 17 00:00:00 2001
> > > From: Michal Hocko <mhocko@suse.com>
> > > Date: Tue, 30 Jan 2018 14:51:07 +0100
> > > Subject: [PATCH] net/netfilter/x_tables.c: make allocation less aggressive
> > 
> > Acked-by: Florian Westphal <fw@strlen.de>
> 
> Thanks! How should we route this change? Andrew, David?

I'll place this in the nf.git tree if everyone is happy with it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
