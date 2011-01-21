Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DF1288D0069
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 02:50:03 -0500 (EST)
Received: by fxm12 with SMTP id 12so1537010fxm.14
        for <linux-mm@kvack.org>; Thu, 20 Jan 2011 23:50:00 -0800 (PST)
From: Michal Simek <monstr@monstr.eu>
Subject: mm.h: Fix noMMU breakage
Date: Fri, 21 Jan 2011 08:49:55 +0100
Message-Id: <1295596196-8233-1-git-send-email-monstr@monstr.eu>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

all noMMU systems are broken that's why I would like to add
this patch (or any similar/better) to mainline ASAP. 
For more information please look at patch description.

Can you give me some ACKs?

Who is responsible for this mm patch? Andrew?

Thanks,
Michal


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
