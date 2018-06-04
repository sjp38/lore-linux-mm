Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 324526B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 08:13:59 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id g16-v6so2586334lfk.21
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 05:13:59 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v7-v6sor527534lje.52.2018.06.04.05.13.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Jun 2018 05:13:56 -0700 (PDT)
MIME-Version: 1.0
References: <1527940734-35161-1-git-send-email-ufo19890607@gmail.com>
 <1527940734-35161-2-git-send-email-ufo19890607@gmail.com> <20180604065238.GE19202@dhcp22.suse.cz>
 <CAHCio2iCdBU=xqEGqUrmc-ere-BhiS1AU052L4GfphbDPvOPqQ@mail.gmail.com>
 <CAHCio2jufEO7D4AT89URi+QWYJRMXyUo0-PwobcJzm0iLUnEzQ@mail.gmail.com> <20180604095212.GH19202@dhcp22.suse.cz>
In-Reply-To: <20180604095212.GH19202@dhcp22.suse.cz>
From: =?UTF-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Date: Mon, 4 Jun 2018 20:13:44 +0800
Message-ID: <CAHCio2gQBZDi1oOh8QYbKFbB5E3eSain0soeqE3wAn=zQZeZ5A@mail.gmail.com>
Subject: Re: [PATCH v7 2/2] Refactor part of the oom report in dump_header
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

Hi Michal
I will add the missing information in the cover-letter.

> That being said, I am ready to ack a patch which adds the memcg of the
> oom victim. I will not ack (nor nack) the patch which turns it into a
> single print because I am not sure the benefit is really worth it. Maybe
> others will though.

OK, I will use the pr_cont_cgroup_name() to print origin and kill
memcg's name. I hope David will not have other opinions :)

Thanks
