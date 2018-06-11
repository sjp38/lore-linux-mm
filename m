Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8AA276B0005
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 03:07:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f65-v6so3966553wmd.2
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 00:07:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g10-v6si834960edi.309.2018.06.11.00.07.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Jun 2018 00:07:23 -0700 (PDT)
Date: Mon, 11 Jun 2018 09:07:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 2/2] Refactor part of the oom report in dump_header
Message-ID: <20180611070720.GA13364@dhcp22.suse.cz>
References: <1527940734-35161-1-git-send-email-ufo19890607@gmail.com>
 <1527940734-35161-2-git-send-email-ufo19890607@gmail.com>
 <20180603124941.GA29497@rapoport-lnx>
 <CAHCio2ifo3SNH9E3GX2=q1a=MNiNnoCu+2a++yX5_xMBheya5g@mail.gmail.com>
 <CAHCio2in8NXZRanE9MS0VsSZxKaSvTy96TF59hODoNCxuQTz5A@mail.gmail.com>
 <20180604045812.GA15196@rapoport-lnx>
 <CAHCio2gj-DoOek0RN718TCLZsOpNPd6Ua88HPijdqezuySDjaw@mail.gmail.com>
 <20180610051215.GA20681@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180610051215.GA20681@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: =?utf-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>, akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Sun 10-06-18 08:12:16, Mike Rapoport wrote:
> On Fri, Jun 08, 2018 at 05:53:14PM +0800, c|1e??e?(R) wrote:
> > Hi Mike
> > > My question was why do you call to alloc_constrained in the dump_header()
> > > function rather than pass the constraint that was detected a bit earlier to
> > > that function?
> > 
> > dump_header will be called by three functions: oom_kill_process,
> > check_panic_on_oom, out_of_memory.
> > We can get the constraint from the last two
> > functions(check_panic_on_oom, out_of_memory), but I need to
> > pass a new parameter(constraint) for oom_kill_process.
> 
> Another option is to add the constraint to the oom_control structure.

Which would make more sense because oom_control should contain the full
OOM context.
-- 
Michal Hocko
SUSE Labs
