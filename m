Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BCDC96B0011
	for <linux-mm@kvack.org>; Thu, 12 May 2011 06:49:27 -0400 (EDT)
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1QKTSN-0004Nm-Oe
	for linux-mm@kvack.org; Thu, 12 May 2011 12:49:24 +0200
Received: from 123.124.21.93 ([123.124.21.93])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 12 May 2011 12:49:23 +0200
Received: from xiyou.wangcong by 123.124.21.93 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 12 May 2011 12:49:23 +0200
From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2 1/3] coredump: use get_task_comm for %e filename
 format
Date: Thu, 12 May 2011 10:49:10 +0000 (UTC)
Message-ID: <iqgdv5$ruq$2@dough.gmane.org>
References: <1305181093-20871-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 12 May 2011 08:18:11 +0200, Jiri Slaby wrote:

> We currently access current->comm directly. As we have
> prctl(PR_SET_NAME), we need the access be protected by task_lock. This
> is exactly what get_task_comm does, so use it.
> 
> I'm not 100% convinced prctl(PR_SET_NAME) may be called at the time of
> core dump, but the locking won't hurt. Note that siglock is not held in
> format_corename.

John Stultz is working on some patches to convert get_task_common()
to printk %ptc, you will not need to worry about the locking issue.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
