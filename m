Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8536B006C
	for <linux-mm@kvack.org>; Tue, 12 May 2015 10:40:37 -0400 (EDT)
Received: by qgdy78 with SMTP id y78so5156393qgd.0
        for <linux-mm@kvack.org>; Tue, 12 May 2015 07:40:37 -0700 (PDT)
Received: from mail-qk0-x22d.google.com (mail-qk0-x22d.google.com. [2607:f8b0:400d:c09::22d])
        by mx.google.com with ESMTPS id b123si16330216qka.20.2015.05.12.07.40.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 07:40:36 -0700 (PDT)
Received: by qku63 with SMTP id 63so6856098qku.3
        for <linux-mm@kvack.org>; Tue, 12 May 2015 07:40:35 -0700 (PDT)
Date: Tue, 12 May 2015 10:40:32 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH] PM, freezer: Don't thaw when it's intended frozen
 processes
Message-ID: <20150512144032.GN11388@htj.duckdns.org>
References: <20150507064557.GA26928@july>
 <20150507154212.GA12245@htj.duckdns.org>
 <CAH9JG2UAVRgX0Mg0d7WgG0URpkgu4q_bbNMXyOOEh9WFPztppQ@mail.gmail.com>
 <20150508152513.GB28439@htj.duckdns.org>
 <CAJKOXPfmzvE_P15jTrkrXMDuWdqewj2uhM6N1vt=QBD2_ZFhrg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJKOXPfmzvE_P15jTrkrXMDuWdqewj2uhM6N1vt=QBD2_ZFhrg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: Kyungmin Park <kmpark@infradead.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "\\Rafael J. Wysocki\\" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux PM list <linux-pm@vger.kernel.org>

On Mon, May 11, 2015 at 03:33:10PM +0900, Krzysztof Kozlowski wrote:
> > Yes, they should and I'm not sure why what you're saying is happening
> > because freezing() test done from the frozen tasks themselves should
> > keep them in the freezer.  Which kernel version did you test?  Can you
> > please verify it against a recent kernel?
> 
> I tested it on v4.1-rc3 and next-20150508.
> 
> Task was moved to frozen cgroup:
> -----
> root@localhost:/sys/fs/cgroup/freezer/frozen# grep . *
> cgroup.clone_children:0
> cgroup.procs:2750
> freezer.parent_freezing:0
> freezer.self_freezing:1
> freezer.state:FROZEN
> notify_on_release:0
> tasks:2750
> tasks:2773
> -----
> 
> Unfortunately during system resume the process was woken up. The "if
> (frozen(p))" check was true. Is it expected behaviour?

It isn't optimal but doesn't break anything either.  Whether a task
stays in the freezer or not is solely decided by freezing() test by
the task itself.  Being woken up spuriously doesn't break anything.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
