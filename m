Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 849486B0007
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 04:57:31 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l72-v6so2731811lfl.20
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 01:57:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o81-v6sor630734lja.59.2018.06.04.01.57.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Jun 2018 01:57:29 -0700 (PDT)
MIME-Version: 1.0
References: <1527940734-35161-1-git-send-email-ufo19890607@gmail.com>
 <1527940734-35161-2-git-send-email-ufo19890607@gmail.com> <20180604065238.GE19202@dhcp22.suse.cz>
 <CAHCio2iCdBU=xqEGqUrmc-ere-BhiS1AU052L4GfphbDPvOPqQ@mail.gmail.com>
In-Reply-To: <CAHCio2iCdBU=xqEGqUrmc-ere-BhiS1AU052L4GfphbDPvOPqQ@mail.gmail.com>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Mon, 4 Jun 2018 16:57:17 +0800
Message-ID: <CAHCio2jufEO7D4AT89URi+QWYJRMXyUo0-PwobcJzm0iLUnEzQ@mail.gmail.com>
Subject: Re: [PATCH v7 2/2] Refactor part of the oom report in dump_header
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

Hi Michal

> I have earlier suggested that you split this into two parts. One to add
> the missing information and the later to convert it to a single printk
> output.

I'm sorry I do not get your point.  What do you mean the missing information?

> but it still really begs an example why we really insist on a single
> printk and that should be in its own changelog.

Actually , I just know that we should avoid the interleaving messages
in the dmesg.
But I don't know how to reproduce this issue.  I think I can just
recount this issue in
the changelog.

Thanks
