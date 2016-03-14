Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id BFC596B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 12:39:45 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id p65so110568478wmp.0
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 09:39:45 -0700 (PDT)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id y75si19450684wmd.54.2016.03.14.09.39.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 09:39:44 -0700 (PDT)
Received: by mail-wm0-f49.google.com with SMTP id n186so116489529wmn.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 09:39:44 -0700 (PDT)
Date: Mon, 14 Mar 2016 17:39:43 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] exit: clear TIF_MEMDIE after exit_task_work
Message-ID: <20160314163943.GE11400@dhcp22.suse.cz>
References: <1456765329-14890-1-git-send-email-vdavydov@virtuozzo.com>
 <20160301155212.GJ9461@dhcp22.suse.cz>
 <20160301175431-mutt-send-email-mst@redhat.com>
 <20160301160813.GM9461@dhcp22.suse.cz>
 <20160301182027-mutt-send-email-mst@redhat.com>
 <20160301163537.GO9461@dhcp22.suse.cz>
 <20160301184046-mutt-send-email-mst@redhat.com>
 <20160301171758.GP9461@dhcp22.suse.cz>
 <20160301191906-mutt-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160301191906-mutt-send-email-mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 01-03-16 19:20:24, Michael S. Tsirkin wrote:
> On Tue, Mar 01, 2016 at 06:17:58PM +0100, Michal Hocko wrote:
[...]
> > Sorry, I could have been more verbose... The code would have to make sure
> > that the mm is still alive before calling g-u-p by
> > atomic_inc_not_zero(&mm->mm_users) and fail if the user count dropped to
> > 0 in the mean time. See how fs/proc/task_mmu.c does that (proc_mem_open
> > + m_start + m_stop.
> > 
> > The biggest advanatage would be that the mm address space pin would be
> > only for the particular operation. Not sure whether that is possible in
> > the driver though. Anyway pinning the mm for a potentially unbounded
> > amount of time doesn't sound too nice.
> 
> Hmm that would be another atomic on data path ...
> I'd have to explore that.

Did you have any chance to look into this?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
