Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3FED66B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 04:18:48 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a1-v6so5049231lfh.4
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 01:18:48 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j127-v6sor9367517lfe.2.2018.06.04.01.18.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Jun 2018 01:18:46 -0700 (PDT)
MIME-Version: 1.0
References: <1527940734-35161-1-git-send-email-ufo19890607@gmail.com>
 <1527940734-35161-2-git-send-email-ufo19890607@gmail.com> <20180604065238.GE19202@dhcp22.suse.cz>
In-Reply-To: <20180604065238.GE19202@dhcp22.suse.cz>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Mon, 4 Jun 2018 16:18:34 +0800
Message-ID: <CAHCio2iCdBU=xqEGqUrmc-ere-BhiS1AU052L4GfphbDPvOPqQ@mail.gmail.com>
Subject: Re: [PATCH v7 2/2] Refactor part of the oom report in dump_header
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

Hi Tetsuo
I know what you mean. Actully I refer to the code for kernel version:
3.10.0-514.  I think I can just use an array of type char, rather than
static char. Is it right?

Thanks
