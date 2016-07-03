Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7E74F6B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 12:47:39 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id i63so14492532vkb.1
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 09:47:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q25si2110573qtq.57.2016.07.03.09.47.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jul 2016 09:47:38 -0700 (PDT)
Date: Sun, 3 Jul 2016 18:47:23 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC PATCH 5/6] vhost, mm: make sure that oom_reaper doesn't
 reap memory read by vhost
Message-ID: <20160703164723.GA30151@redhat.com>
References: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
 <1467365190-24640-6-git-send-email-mhocko@kernel.org>
 <20160703134719.GA28492@redhat.com>
 <20160703140904.GA26908@redhat.com>
 <20160703151829.GA28667@redhat.com>
 <20160703182254-mutt-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160703182254-mutt-send-email-mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.com>

On 07/03, Michael S. Tsirkin wrote:
>
> On Sun, Jul 03, 2016 at 05:18:29PM +0200, Oleg Nesterov wrote:
> >
> > Well, we are going to kill all tasks which share this memory. I mean, ->mm.
> > If "sharing memory with another task" means, say, a file, then this memory
> > won't be unmapped (if shared).
> >
> > So let me ask again... Suppose, say, QEMU does VHOST_SET_OWNER and then we
> > unmap its (anonymous/non-shared) memory. Who else's memory can be corrupted?
>
> As you say, I mean anyone who shares memory with QEMU through a file.

And in this case vhost_worker() reads the anonymous memory of QEMU process,
not the memory which can be shared with another task, correct?

And if QEMU simply crashes, this can't affect anyone who shares memory with
QEMU through a file, yes?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
