Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 534ED6B0083
	for <linux-mm@kvack.org>; Tue, 14 May 2013 05:13:09 -0400 (EDT)
Received: by mail-bk0-f52.google.com with SMTP id mz1so154904bkb.39
        for <linux-mm@kvack.org>; Tue, 14 May 2013 02:13:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130513133809.GC5246@dhcp22.suse.cz>
References: <1368421410-4795-1-git-send-email-handai.szj@taobao.com>
	<1368421545-4974-1-git-send-email-handai.szj@taobao.com>
	<20130513131251.GB5246@dhcp22.suse.cz>
	<20130513133809.GC5246@dhcp22.suse.cz>
Date: Tue, 14 May 2013 17:13:07 +0800
Message-ID: <CAFj3OHW=FCGu6rhChLV2HgUFSRxDur4e8bmugXnq++c-P8mNRg@mail.gmail.com>
Subject: Re: [PATCH V2 3/3] memcg: simplify lock of memcg page stat account
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, Sha Zhengju <handai.szj@taobao.com>

On Mon, May 13, 2013 at 9:38 PM, Michal Hocko <mhocko@suse.cz> wrote:
>
> On Mon 13-05-13 15:12:51, Michal Hocko wrote:
> [...]
> > I am sorry but I do not think this is the right approach. IMO we should
> > focus on mem_cgroup_begin_update_page_stat and make it really recursive
> > safe - ideally without any additional overhead (which sounds like a real
> > challenge)
>
> Or maybe we should just not over complicate this and simply consider
> recursivness when it starts being an issue. It is not a problem for
> rmap accounting anymore and dirty pages accounting seems to be safe as
> well and pages under writeback accounting was OK even previously.
> It doesn't make much sense to block dirty pages accounting by a
> non-existing problem.
>

Yes, the dirty/writeback accounting seems okay now. I sent this patch
out to see if I can do something to simplify the locks but this
approach seems to have its own drawbacks. Since you and Kame are NAK
to this, in the order of importance I'll put the patch aside and
continue the work of dirty page accounting. :)

Thanks for the teaching!


--
Thanks,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
