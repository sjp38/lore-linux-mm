Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4AE9F8D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 02:55:07 -0500 (EST)
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1PiMh5-0004aw-Sh
	for linux-mm@kvack.org; Thu, 27 Jan 2011 08:55:03 +0100
Received: from 60.247.97.98 ([60.247.97.98])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 27 Jan 2011 08:55:03 +0100
Received: from xiyou.wangcong by 60.247.97.98 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 27 Jan 2011 08:55:03 +0100
From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v1 0/6] Set printk priority level
Date: Thu, 27 Jan 2011 07:22:41 +0000 (UTC)
Message-ID: <ihr6g0$qmm$3@dough.gmane.org>
References: <20110125235700.GR8008@google.com>
	<1296084570-31453-1-git-send-email-msb@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.orglinux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Jan 2011 15:29:24 -0800, Mandeep Singh Baines wrote:

> We've been burned by regressions/bugs which we later realized could have
> been triaged quicker if only we'd paid closer attention to dmesg.
> 
> This patch series fixes printk()s which appear in the logs of the device
> I'm currently working on. I'd love to fix all such printks but there are
> hundreds of files and thousands of LOC affected:
> 
> $ find . -name \*.c | xargs fgrep -c "printk(\"" | wc -l 16237
> $ find . -name \*.c | xargs fgrep "printk(\"" | wc -l 20745
> 

Yes, this is the right approach, every printk should have a
specified level.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
