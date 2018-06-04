Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 558076B0003
	for <linux-mm@kvack.org>; Sun,  3 Jun 2018 21:59:09 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id l72-v6so2439167lfl.20
        for <linux-mm@kvack.org>; Sun, 03 Jun 2018 18:59:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u15-v6sor3971216lfi.27.2018.06.03.18.59.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Jun 2018 18:59:07 -0700 (PDT)
MIME-Version: 1.0
References: <1527940734-35161-1-git-send-email-ufo19890607@gmail.com>
 <1527940734-35161-2-git-send-email-ufo19890607@gmail.com> <20180603124941.GA29497@rapoport-lnx>
In-Reply-To: <20180603124941.GA29497@rapoport-lnx>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Mon, 4 Jun 2018 09:58:55 +0800
Message-ID: <CAHCio2ifo3SNH9E3GX2=q1a=MNiNnoCu+2a++yX5_xMBheya5g@mail.gmail.com>
Subject: Re: [PATCH v7 2/2] Refactor part of the oom report in dump_header
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

Hi Mike
> Please keep the brief description of the function actually brief and move the detailed explanation after the parameters description.
Thanks for your advice.

> The allocation constraint is detected by the dump_header() callers, why not just use it here?
David suggest that constraint need to be printed in the oom report, so
I add the enum variable in this function.

Thanks
Wind
