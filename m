Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id CC92A6B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 05:53:30 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id z144-v6so4012723lff.2
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 02:53:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c189-v6sor2554029lfg.93.2018.06.08.02.53.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Jun 2018 02:53:28 -0700 (PDT)
MIME-Version: 1.0
References: <1527940734-35161-1-git-send-email-ufo19890607@gmail.com>
 <1527940734-35161-2-git-send-email-ufo19890607@gmail.com> <20180603124941.GA29497@rapoport-lnx>
 <CAHCio2ifo3SNH9E3GX2=q1a=MNiNnoCu+2a++yX5_xMBheya5g@mail.gmail.com>
 <CAHCio2in8NXZRanE9MS0VsSZxKaSvTy96TF59hODoNCxuQTz5A@mail.gmail.com> <20180604045812.GA15196@rapoport-lnx>
In-Reply-To: <20180604045812.GA15196@rapoport-lnx>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Fri, 8 Jun 2018 17:53:14 +0800
Message-ID: <CAHCio2gj-DoOek0RN718TCLZsOpNPd6Ua88HPijdqezuySDjaw@mail.gmail.com>
Subject: Re: [PATCH v7 2/2] Refactor part of the oom report in dump_header
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

Hi Mike
> My question was why do you call to alloc_constrained in the dump_header()
> function rather than pass the constraint that was detected a bit earlier to
> that function?

dump_header will be called by three functions: oom_kill_process,
check_panic_on_oom, out_of_memory.
We can get the constraint from the last two
functions(check_panic_on_oom, out_of_memory), but I need to
pass a new parameter(constraint) for oom_kill_process.

Thanks
