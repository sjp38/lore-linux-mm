Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3D90C6B0360
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 14:15:26 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id g16so1171008wmg.6
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 11:15:26 -0800 (PST)
Received: from mail.us.es (mail.us.es. [193.147.175.20])
        by mx.google.com with ESMTPS id x66si1563863wmb.268.2018.02.07.11.15.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 11:15:24 -0800 (PST)
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id D267D3066B0
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 20:15:22 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id C205CDA3AC
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 20:15:22 +0100 (CET)
Date: Wed, 7 Feb 2018 20:15:18 +0100
From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [netfilter-core] kernel panic: Out of memory and no killable
 processes... (2)
Message-ID: <20180207191518.jehn3pyssyvupt7n@salvia>
References: <20180130075226.GL21609@dhcp22.suse.cz>
 <20180130081127.GH5906@breakpoint.cc>
 <20180130082817.cbax5qj4mxancx4b@node.shutemov.name>
 <CACT4Y+bFKwoxopr1dwnc7OHUoHy28ksVguqtMY6tD=aRh-7LyQ@mail.gmail.com>
 <20180130095739.GV21609@dhcp22.suse.cz>
 <20180130140104.GE21609@dhcp22.suse.cz>
 <20180130112745.934883e37e696ab7f875a385@linux-foundation.org>
 <20180131081916.GO21609@dhcp22.suse.cz>
 <20180207174439.esm4djxb4trbotne@salvia>
 <20180207110642.dbb3fe499a134d1369f05a2f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180207110642.dbb3fe499a134d1369f05a2f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Yang Shi <yang.s@alibaba-inc.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, netdev <netdev@vger.kernel.org>, guro@fb.com, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com, Linux-MM <linux-mm@kvack.org>, coreteam@netfilter.org, netfilter-devel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, David Miller <davem@davemloft.net>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Feb 07, 2018 at 11:06:42AM -0800, Andrew Morton wrote:
> From: Michal Hocko <mhocko@suse.com>
> Subject: net/netfilter/x_tables.c: remove size check
> 
> Back in 2002 vmalloc used to BUG on too large sizes.  We are much better
> behaved these days and vmalloc simply returns NULL for those.  Remove the
> check as it simply not needed and the comment is even misleading.

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
