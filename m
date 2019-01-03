Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 150C78E00AE
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 17:54:27 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e17so34235398edr.7
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 14:54:27 -0800 (PST)
Received: from outbound-smtp25.blacknight.com (outbound-smtp25.blacknight.com. [81.17.249.193])
        by mx.google.com with ESMTPS id z3si672090edm.238.2019.01.03.14.54.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 14:54:25 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp25.blacknight.com (Postfix) with ESMTPS id 5163AB88CE
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 22:54:25 +0000 (GMT)
Date: Thu, 3 Jan 2019 22:54:23 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: possible deadlock in __wake_up_common_lock
Message-ID: <20190103225423.GI31517@techsingularity.net>
References: <000000000000f67ca2057e75bec3@google.com>
 <1194004c-f176-6253-a5fd-682472dccacc@suse.cz>
 <20190102180611.GE31517@techsingularity.net>
 <CACT4Y+YMc0hiU-taTmwvm_6u4hAruBWV0qAz_Bp4f2a6JC-UiA@mail.gmail.com>
 <20190103163750.GH31517@techsingularity.net>
 <c6c65844-604c-91ab-1b55-64a02accad18@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <c6c65844-604c-91ab-1b55-64a02accad18@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: Dmitry Vyukov <dvyukov@google.com>, Vlastimil Babka <vbabka@suse.cz>, syzbot <syzbot+93d94a001cfbce9e60e1@syzkaller.appspotmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux@dominikbrodowski.net, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, xieyisheng1@huawei.com, zhong jiang <zhongjiang@huawei.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On Thu, Jan 03, 2019 at 02:40:35PM -0500, Qian Cai wrote:
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Tested-by: Qian Cai <cai@lca.pw>

Thanks!

-- 
Mel Gorman
SUSE Labs
