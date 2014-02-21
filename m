Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 526D36B00D2
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 14:57:45 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id r10so1182105pdi.18
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 11:57:44 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id gk3si8428181pac.205.2014.02.21.11.57.43
        for <linux-mm@kvack.org>;
        Fri, 21 Feb 2014 11:57:44 -0800 (PST)
Date: Fri, 21 Feb 2014 11:57:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Revert
 "writeback: do not sync data dirtied after sync start"
Message-Id: <20140221115742.04f893323ce6f9d693212787@linux-foundation.org>
In-Reply-To: <1392978601-18002-1-git-send-email-jack@suse.cz>
References: <1392978601-18002-1-git-send-email-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>

On Fri, 21 Feb 2014 11:30:01 +0100 Jan Kara <jack@suse.cz> wrote:

> This reverts commit c4a391b53a72d2df4ee97f96f78c1d5971b47489. Dave
> Chinner <david@fromorbit.com> has reported the commit may cause some
> inodes to be left out from sync(2). This is because we can call
> redirty_tail() for some inode (which sets i_dirtied_when to current time)
> after sync(2) has started or similarly requeue_inode() can set
> i_dirtied_when to current time if writeback had to skip some pages. The
> real problem is in the functions clobbering i_dirtied_when but fixing
> that isn't trivial so revert is a safer choice for now.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

No cc:stable?  The patch is applicable to 3.13.x.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
