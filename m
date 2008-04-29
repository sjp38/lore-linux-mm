Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id m3TE8Kfr014384
	for <linux-mm@kvack.org>; Tue, 29 Apr 2008 15:08:20 +0100
Received: from fg-out-1718.google.com (fgad23.prod.google.com [10.86.55.23])
	by zps19.corp.google.com with ESMTP id m3TE8Ijm030559
	for <linux-mm@kvack.org>; Tue, 29 Apr 2008 07:08:19 -0700
Received: by fg-out-1718.google.com with SMTP id d23so10369fga.32
        for <linux-mm@kvack.org>; Tue, 29 Apr 2008 07:08:18 -0700 (PDT)
Message-ID: <d43160c70804290708t51bdc100j9cc42a8da512aee7@mail.gmail.com>
Date: Tue, 29 Apr 2008 10:08:18 -0400
From: "Ross Biro" <rossb@google.com>
Subject: Re: Page Faults slower in 2.6.25-rc9 than 2.6.23
In-Reply-To: <Pine.LNX.4.64.0804291447040.5058@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <d43160c70804290610t2135a271hd9b907529e89e74e@mail.gmail.com>
	 <Pine.LNX.4.64.0804291447040.5058@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 29, 2008 at 9:57 AM, Hugh Dickins <hugh@veritas.com> wrote:
>  Do you have CONFIG_CGROUP_MEM_RES_CTLR=y in 2.6.25?
>  That added about 20% to my lmbench "Page Fault" tests (with
>  adverse effect on several others e.g. the fork, exec, sh group).

I don't have config cgroups set.  I do have fake numa on, but I'm
pretty sure it was on for 2.6.23 as well.

# CONFIG_CGROUPS is not set
CONFIG_GROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_USER_SCHED=y
# CONFIG_CGROUP_SCHED is not set
C

    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
