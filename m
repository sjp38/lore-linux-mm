Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3F5EF6B038A
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 15:58:06 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g8so76268wmg.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 12:58:06 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j193si61151wmg.68.2017.03.16.12.58.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 12:58:05 -0700 (PDT)
Date: Thu, 16 Mar 2017 15:57:31 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 RFC] mm/vmscan: more restrictive condition for retry
 in do_try_to_free_pages
Message-ID: <20170316195731.GA31479@cmpxchg.org>
References: <1489240264-3290-1-git-send-email-ysxie@foxmail.com>
 <CALvZod6dptidW33mpvSkQfMBM=xsfSPEEJzB+3u4ekr8m3bSOA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod6dptidW33mpvSkQfMBM=xsfSPEEJzB+3u4ekr8m3bSOA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Yisheng Xie <ysxie@foxmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, riel@redhat.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, xieyisheng1@huawei.com, guohanjun@huawei.com, Xishi Qiu <qiuxishi@huawei.com>

On Sat, Mar 11, 2017 at 09:52:15AM -0800, Shakeel Butt wrote:
> On Sat, Mar 11, 2017 at 5:51 AM, Yisheng Xie <ysxie@foxmail.com> wrote:
> > @@ -2808,7 +2826,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
> >                 return 1;
> >
> >         /* Untapped cgroup reserves?  Don't OOM, retry. */
> > -       if (!sc->may_thrash) {
> > +       if (!may_thrash(sc)) {
> 
> Thanks Yisheng. The name of the function may_thrash() is confusing in
> the sense that it is returning exactly the opposite of what its name
> implies. How about reversing the condition of may_thrash() function
> and change the scan_control's field may_thrash to thrashed?

How so?

The user sets memory.low to a minimum below which the application will
thrash. Hence, being allowed to break that minimum and causing the app
to thrash, means you "may thrash".

OTOH, I'm not sure what "thrashed" would mean.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
