Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C24CE6B0007
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 08:17:34 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id r2-v6so24378562wrm.15
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 05:17:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q3-v6si9859414edg.240.2018.06.04.05.17.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Jun 2018 05:17:33 -0700 (PDT)
Date: Mon, 4 Jun 2018 14:17:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 2/2] Refactor part of the oom report in dump_header
Message-ID: <20180604121729.GL19202@dhcp22.suse.cz>
References: <1527940734-35161-1-git-send-email-ufo19890607@gmail.com>
 <1527940734-35161-2-git-send-email-ufo19890607@gmail.com>
 <20180604065238.GE19202@dhcp22.suse.cz>
 <CAHCio2iCdBU=xqEGqUrmc-ere-BhiS1AU052L4GfphbDPvOPqQ@mail.gmail.com>
 <CAHCio2jufEO7D4AT89URi+QWYJRMXyUo0-PwobcJzm0iLUnEzQ@mail.gmail.com>
 <20180604095212.GH19202@dhcp22.suse.cz>
 <CAHCio2gQBZDi1oOh8QYbKFbB5E3eSain0soeqE3wAn=zQZeZ5A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHCio2gQBZDi1oOh8QYbKFbB5E3eSain0soeqE3wAn=zQZeZ5A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Mon 04-06-18 20:13:44, c|1e??e?(R) wrote:
> Hi Michal
> I will add the missing information in the cover-letter.

I do not really think the cover letter needs much improvements. It is
the patch description that should be as specific as possible. Cover
letter should contain a highlevel description usually.
 
> > That being said, I am ready to ack a patch which adds the memcg of the
> > oom victim. I will not ack (nor nack) the patch which turns it into a
> > single print because I am not sure the benefit is really worth it. Maybe
> > others will though.
> 
> OK, I will use the pr_cont_cgroup_name() to print origin and kill
> memcg's name. I hope David will not have other opinions :)

As I've said this can be always added on top pressuming there is a good
justification.
-- 
Michal Hocko
SUSE Labs
