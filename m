Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f71.google.com (mail-qg0-f71.google.com [209.85.192.71])
	by kanga.kvack.org (Postfix) with ESMTP id BFBAA6B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 20:22:40 -0400 (EDT)
Received: by mail-qg0-f71.google.com with SMTP id z67so212284926qgz.0
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 17:22:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 43si6471609qto.81.2016.06.06.17.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 17:22:40 -0700 (PDT)
Date: Tue, 7 Jun 2016 01:20:08 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 06/10] mm, oom: kill all tasks sharing the mm
Message-ID: <20160606232007.GA624@redhat.com>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org> <1464945404-30157-7-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1606061526440.18843@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1606061526440.18843@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/06, David Rientjes wrote:
>
> > There is a potential race where we kill the oom disabled task which is
> > highly unlikely but possible. It would happen if __set_oom_adj raced
> > with select_bad_process and then it is OK to consider the old value or
> > with fork when it should be acceptable as well.
> > Let's add a little note to the log so that people would tell us that
> > this really happens in the real life and it matters.
> >
>
> We cannot kill oom disabled processes at all, little race or otherwise.

But this change doesn't really make it worse?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
