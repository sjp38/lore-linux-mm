Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 098D66B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 14:01:46 -0500 (EST)
Received: by mail-qa0-f45.google.com with SMTP id m5so1195769qaj.4
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 11:01:45 -0800 (PST)
Received: from mail-qa0-x234.google.com (mail-qa0-x234.google.com [2607:f8b0:400d:c00::234])
        by mx.google.com with ESMTPS id a3si705294qam.170.2014.02.19.11.01.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 11:01:44 -0800 (PST)
Received: by mail-qa0-f52.google.com with SMTP id j15so1188862qaq.39
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 11:01:43 -0800 (PST)
Date: Wed, 19 Feb 2014 14:01:39 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] backing_dev: Fix hung task on sync
Message-ID: <20140219190139.GQ10134@htj.dyndns.org>
References: <1392437537-27392-1-git-send-email-dbasehore@chromium.org>
 <20140218225548.GI31892@mtj.dyndns.org>
 <20140219092731.GA4849@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140219092731.GA4849@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Derek Basehore <dbasehore@chromium.org>, Alexander Viro <viro@zento.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bleung@chromium.org, sonnyrao@chromium.org, semenzato@chromium.org

Hello, Jan.

On Wed, Feb 19, 2014 at 10:27:31AM +0100, Jan Kara wrote:
>   You are the workqueue expert so you may know better ;) But the way I
> understand it is that queue_delayed_work() does nothing if the timer is
> already running. Since we queue flusher work to run either immediately or
> after dirty_writeback_interval we are safe to run queue_delayed_work()
> whenever we want it to run after dirty_writeback_interval and
> mod_delayed_work() whenever we want to run it immediately.

Ah, okay, so it's always mod on immediate and queue on delayed.  Yeah,
that should work.

> But it's subtle and some interface where we could say queue delayed work
> after no later than X would be easier to grasp.

Yeah, I think it'd be better if we had something like
mod_delayed_work_if_later().  Hmm...

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
