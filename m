Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2195E6B0038
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 11:32:28 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id 65so40174133uay.1
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 08:32:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a135si2520966ybg.200.2016.08.24.08.32.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Aug 2016 08:32:27 -0700 (PDT)
Date: Wed, 24 Aug 2016 17:32:00 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2] kernel/fork: fix CLONE_CHILD_CLEARTID regression in
	nscd
Message-ID: <20160824153159.GA25033@redhat.com>
References: <1471968749-26173-1-git-send-email-mhocko@kernel.org> <20160823163233.GA7123@redhat.com> <20160824081023.GE31179@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160824081023.GE31179@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Roland McGrath <roland@hack.frob.com>, Andreas Schwab <schwab@suse.com>, William Preston <wpreston@suse.com>

On 08/24, Michal Hocko wrote:
>
> Sounds better?
> diff --git a/kernel/fork.c b/kernel/fork.c
> index b89f0eb99f0a..ddde5849df81 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -914,7 +914,8 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
>  
>  	/*
>  	 * Signal userspace if we're not exiting with a core dump
> -	 * or a killed vfork parent which shouldn't touch this mm.
> +	 * because we want to leave the value intact for debugging
> +	 * purposes.
>  	 */
>  	if (tsk->clear_child_tid) {
>  		if (!(tsk->signal->flags & SIGNAL_GROUP_COREDUMP) &&

Yes, thanks Michal!

Acked-by: Oleg Nesterov <oleg@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
