Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E59036B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 19:42:01 -0400 (EDT)
Received: by wyf19 with SMTP id 19so6036991wyf.14
        for <linux-mm@kvack.org>; Mon, 23 May 2011 16:41:59 -0700 (PDT)
From: Hussam Al-Tayeb <ht990332@gmail.com>
Subject: Re: [Bugme-new] [Bug 35662] New: softlockup with kernel 2.6.39
Date: Tue, 24 May 2011 02:41:51 +0300
References: <bug-35662-10286@https.bugzilla.kernel.org/> <20110523162225.6017b2df.akpm@linux-foundation.org>
In-Reply-To: <20110523162225.6017b2df.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <201105240241.52307.hussam@visp.net.lb>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org

YEs, 
lsmod | grep dm_crypt
dm_crypt               12887  2 
dm_mod                 55464  5 dm_crypt

Still no lockups since downgrading to 2.6.38.6 which was a few hours before I 
filed the bug report.
I could reinstall 2.6.39 if there is anything you would like me to test.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
