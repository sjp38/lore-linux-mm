Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C445A6B0012
	for <linux-mm@kvack.org>; Fri,  6 May 2011 11:04:54 -0400 (EDT)
Received: by wyf19 with SMTP id 19so3323851wyf.14
        for <linux-mm@kvack.org>; Fri, 06 May 2011 08:04:53 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 6 May 2011 23:04:52 +0800
Message-ID: <BANLkTi=S_gSvnQimgqrMmq9eWJYDCDRVmA@mail.gmail.com>
Subject: [Question] how to detect mm leaker and kill?
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Yong Zhang <yong.zhang0@gmail.com>

Hi

In the scenario that 2GB  physical RAM is available, and there is a
database application that eats 1.4GB RAM without leakage already
running, another leaker who leaks 4KB an hour is also running, could
the leaker be detected and killed in mm/oom_kill.c with default
configure when oom happens?

thanks
          Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
