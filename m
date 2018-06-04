Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 91FEC6B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 05:52:16 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k18-v6so7632740wrn.8
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 02:52:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d7-v6si11164083ede.253.2018.06.04.02.52.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Jun 2018 02:52:15 -0700 (PDT)
Date: Mon, 4 Jun 2018 11:52:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 2/2] Refactor part of the oom report in dump_header
Message-ID: <20180604095212.GH19202@dhcp22.suse.cz>
References: <1527940734-35161-1-git-send-email-ufo19890607@gmail.com>
 <1527940734-35161-2-git-send-email-ufo19890607@gmail.com>
 <20180604065238.GE19202@dhcp22.suse.cz>
 <CAHCio2iCdBU=xqEGqUrmc-ere-BhiS1AU052L4GfphbDPvOPqQ@mail.gmail.com>
 <CAHCio2jufEO7D4AT89URi+QWYJRMXyUo0-PwobcJzm0iLUnEzQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHCio2jufEO7D4AT89URi+QWYJRMXyUo0-PwobcJzm0iLUnEzQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?56a56Iif6ZSu?= <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wind Yu <yuzhoujian@didichuxing.com>

On Mon 04-06-18 16:57:17, c|1e??e?(R) wrote:
> Hi Michal
> 
> > I have earlier suggested that you split this into two parts. One to add
> > the missing information and the later to convert it to a single printk
> > output.
> 
> I'm sorry I do not get your point.  What do you mean the missing information?

memcg of the killed process

> 
> > but it still really begs an example why we really insist on a single
> > printk and that should be in its own changelog.
> 
> Actually , I just know that we should avoid the interleaving messages
> in the dmesg.

Yeah, that would be great. But you are increasing the static kernel size
and that is something to weigh in when considering the benefit. How
often those messages get interleaved? Is it worth another 512B of size?
Maybe yes, I am not sure. But this should be its own patch so that we
can revert it easily if the cost turns out to be bigger than the
benefit. You should realize that the OOM is a rare case and spending
resources on it is not really appreciated.

That being said, I am ready to ack a patch which adds the memcg of the
oom victim. I will not ack (nor nack) the patch which turns it into a
single print because I am not sure the benefit is really worth it. Maybe
others will though.
-- 
Michal Hocko
SUSE Labs
