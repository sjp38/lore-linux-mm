Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D4EFB6B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 12:05:16 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 101so1357108qtb.0
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 09:05:16 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o4si3701568qkf.61.2016.08.12.09.05.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 09:05:16 -0700 (PDT)
Date: Fri, 12 Aug 2016 18:05:12 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 09/10] vhost, mm: make sure that oom_reaper doesn't reap
 memory read by vhost
Message-ID: <20160812160512.GA30930@redhat.com>
References: <1469734954-31247-10-git-send-email-mhocko@kernel.org>
 <20160728233359-mutt-send-email-mst@kernel.org>
 <20160729060422.GA5504@dhcp22.suse.cz>
 <20160729161039-mutt-send-email-mst@kernel.org>
 <20160729133529.GE8031@dhcp22.suse.cz>
 <20160729205620-mutt-send-email-mst@kernel.org>
 <20160731094438.GA24353@dhcp22.suse.cz>
 <20160812094236.GF3639@dhcp22.suse.cz>
 <20160812132140.GA776@redhat.com>
 <20160812144157.GL3639@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160812144157.GL3639@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, "Michael S. Tsirkin" <mst@redhat.com>

On 08/12, Michal Hocko wrote:
>
> On Fri 12-08-16 15:21:41, Oleg Nesterov wrote:
>
> > Whats really interesting is that I still fail to understand do we really
> > need this hack, iiuc you are not sure too, and Michael didn't bother to
> > explain why a bogus zero from anon memory is worse than other problems
> > caused by SIGKKILL from oom-kill.c.
>
> Yes, I admit that I am not familiar with the vhost memory usage model so
> I can only speculate. But the mere fact that the mm is bound to a device
> fd

Yes, and I already tried to complain. This doesn't look right in any case.

> which can be passed over to a different process makes me worried.

> This means that the mm is basically isolated from the original process
> until the last fd is closed which is under control of the process which
> holds it. The mm can still be access during that time from the vhost
> worker. And I guess this is exactly where the problem lies.

Agreed.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
