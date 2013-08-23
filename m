Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id CA8426B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 12:11:52 -0400 (EDT)
Received: by mail-bk0-f48.google.com with SMTP id my13so304155bkb.7
        for <linux-mm@kvack.org>; Fri, 23 Aug 2013 09:11:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130822154002.ce4310d865ede3a0d30f0ce8@linux-foundation.org>
References: <CAFj3OHXy5XkwhxKk=WNywp2pq__FD7BrSQwFkp+NZj15_k6BEQ@mail.gmail.com>
	<1377165190-24143-1-git-send-email-handai.szj@taobao.com>
	<20130822154002.ce4310d865ede3a0d30f0ce8@linux-foundation.org>
Date: Sat, 24 Aug 2013 00:11:50 +0800
Message-ID: <CAFj3OHUqv9d_0x6hMkboox=B3rPeSe5QJq_ztV+zisuymsjLdw@mail.gmail.com>
Subject: Re: [PATCH 3/4] memcg: add per cgroup writeback pages accounting
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Sha Zhengju <handai.szj@taobao.com>

On Fri, Aug 23, 2013 at 6:40 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 22 Aug 2013 17:53:10 +0800 Sha Zhengju <handai.szj@gmail.com> wrote:
>
>> This patch is to add memcg routines to count writeback pages
>
> Well OK, but why?  What use is the feature?  In what ways are people
> suffering due to its absence?

My apologies for not explaining it clearly.

It's subset of memcg dirty page accounting(including dirty, writeback,
nfs_unstable pages from a broad sense), which can provide a more sound
knowledge of memcg behavior. That would be straightforward to add new
features like memcg dirty page throttling and even memcg aware
flushing.
However, the dirty one is more complicated and performance senstive,
so I need more efforts to improve it and let the writeback patch go
first.  Afterwards I'll only focus on dirty page itself.

-- 
Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
