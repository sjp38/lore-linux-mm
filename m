Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2E3B6B0006
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 08:19:41 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f16-v6so445533edq.18
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 05:19:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r4-v6si3485840edo.320.2018.06.22.05.19.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jun 2018 05:19:39 -0700 (PDT)
Date: Fri, 22 Jun 2018 14:19:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v9] Refactor part of the oom report in dump_header
Message-ID: <20180622121936.GX10465@dhcp22.suse.cz>
References: <1529056341-16182-1-git-send-email-ufo19890607@gmail.com>
 <20180622083949.GR10465@dhcp22.suse.cz>
 <CAHCio2jkE2FGc2g48jm+ddvEbN3hEOoohBM+-871v32N2i2gew@mail.gmail.com>
 <20180622104217.GV10465@dhcp22.suse.cz>
 <CAHCio2j-z5y8sQrZ9ENLH2sOzuoH=vsC+q9Nj5DbSXUnQK-uPw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHCio2j-z5y8sQrZ9ENLH2sOzuoH=vsC+q9Nj5DbSXUnQK-uPw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Fri 22-06-18 19:40:54, c|1e??e?(R) wrote:
> Hi Michal
> > You misunderstood my suggestion. Let me be more specific. Please
> > separate the whole new oom_constraint including its _usage_.
> 
> Sorry for misunderstanding your words. I think you want me to separate
> enum oom_constraint and static const char * const
> oom_constraint_text[] to two parts, am I right ?

Just split the patch into two parts. The first to add oom_constraint*
and use it. And the second which adds the missing memcg information to
the oom report.
-- 
Michal Hocko
SUSE Labs
