Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D94CD6B0092
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 18:14:13 -0500 (EST)
Received: by iwn40 with SMTP id 40so1015862iwn.14
        for <linux-mm@kvack.org>; Wed, 12 Jan 2011 15:14:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1294845571-11529-1-git-send-email-emunson@mgebm.net>
References: <1294845571-11529-1-git-send-email-emunson@mgebm.net>
Date: Thu, 13 Jan 2011 08:14:12 +0900
Message-ID: <AANLkTimFGNxJzNMAJg-mWN-VOxonQ+odE9WBEEEsaw5O@mail.gmail.com>
Subject: Re: [PATCH] Rename struct task variables from p to tsk
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 13, 2011 at 12:19 AM, Eric B Munson <emunson@mgebm.net> wrote:
> p is not a meaningful identifier, this patch replaces all instances
> in page_alloc.c of p when used as a struct task with the more useful
> tsk.
>

Yesterday, Andrew raise an eyebrow about that.
His simple lookup found below.

--

On Tue, 11 Jan 2011 13:03:22 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:
> On Tue, 11 Jan 2011, Andrew Morton wrote:
< snip >
> > Oh, and since when did we use `p' to identify task_structs?
>
> Tsk, tsk: we've been using `p' for task_structs for years and years!

Only bad people do that.  "p".  Really?

z:/usr/src/linux-2.6.37> grep -r " \*p;" . | wc -l
2329
z:/usr/src/linux-2.6.37> grep -r "task_struct \*p" . | wc -l
824

bah.

-- 

How about cleaning up everything in this chance?




-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
