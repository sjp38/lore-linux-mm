Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 87ABF6B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 02:25:46 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l72-v6so2603031lfl.20
        for <linux-mm@kvack.org>; Sun, 03 Jun 2018 23:25:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u15-v6sor4043973lfi.27.2018.06.03.23.25.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Jun 2018 23:25:44 -0700 (PDT)
MIME-Version: 1.0
References: <1527940734-35161-1-git-send-email-ufo19890607@gmail.com>
 <1527940734-35161-2-git-send-email-ufo19890607@gmail.com> <20180603124941.GA29497@rapoport-lnx>
 <CAHCio2ifo3SNH9E3GX2=q1a=MNiNnoCu+2a++yX5_xMBheya5g@mail.gmail.com>
 <CAHCio2in8NXZRanE9MS0VsSZxKaSvTy96TF59hODoNCxuQTz5A@mail.gmail.com> <20180604045812.GA15196@rapoport-lnx>
In-Reply-To: <20180604045812.GA15196@rapoport-lnx>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Mon, 4 Jun 2018 14:25:31 +0800
Message-ID: <CAHCio2i+HeB+LjqzjmQaqu7EnKOmSd4i4k73Kz2mt7bLqzw46A@mail.gmail.com>
Subject: Re: [PATCH v7 2/2] Refactor part of the oom report in dump_header
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

Hi Mike
> My question was why do you call to alloc_constrained in the dump_header()
>function rather than pass the constraint that was detected a bit earlier to
>that function?

Ok, I will add a  new parameter in the dump_header.

Thank you.
