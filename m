Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3A41F900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 08:29:28 -0400 (EDT)
Subject: Re: [PATCH 1/1] Add check for dirty_writeback_interval in
 bdi_wakeup_thread_delayed
From: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
Reply-To: Artem.Bityutskiy@nokia.com
In-Reply-To: <20110418091609.GC5143@Xye>
References: <20110417162308.GA1208@Xye> <1303111152.2815.29.camel@localhost>
	 <20110418091609.GC5143@Xye>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 18 Apr 2011 15:26:29 +0300
Message-ID: <1303129589.8589.5.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra D Prabhu <rprabhu@wnohang.net>
Cc: linux-mm@kvack.org, Jens Axboe <jaxboe@fusionio.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Mon, 2011-04-18 at 14:46 +0530, Raghavendra D Prabhu wrote:
> I have set it to 500 centisecs as that is the default value of
> dirty_writeback_interval. I used this logic for following reason: the
> purpose for which dirty_writeback_interval is set to 0 is to disable
> periodic writeback
> (http://tomoyo.sourceforge.jp/cgi-bin/lxr/source/fs/fs-writeback.c#L818)
> , whereas here (in bdi_wakeup_thread_delayed) it is being used for a
> different purpose -- to delay the bdi wakeup in order to reduce context
> switches for  dirty inode writeback.

But why it wakes up the bdi thread? Exactly to make sure the periodic
write-back happen.

-- 
Best Regards,
Artem Bityutskiy (D?N?N?N?D 1/4  D?D,N?N?N?DoD,D1)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
