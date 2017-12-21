Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 66FD46B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 08:03:18 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id i66so11376521itf.0
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 05:03:18 -0800 (PST)
Received: from wolff.to (wolff.to. [98.103.208.27])
        by mx.google.com with SMTP id i135si14008374ioi.85.2017.12.21.05.03.16
        for <linux-mm@kvack.org>;
        Thu, 21 Dec 2017 05:03:16 -0800 (PST)
Date: Thu, 21 Dec 2017 07:00:57 -0600
From: Bruno Wolff III <bruno@wolff.to>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for
 bdi_debug_register")
Message-ID: <20171221130057.GA26743@wolff.to>
References: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, regressions@leemhuis.info, weiping zhang <zhangweiping@didichuxing.com>, linux-block@vger.kernel.org

After today, I won't have physical access to the problem machine until 
January 2nd. So if you guys have any testing suggestions I need them soon 
if they are to get done before my vacation.
I do plan to try booting to level 1 to see if I can get a login prompt 
that might facilitate testing. The lockups do happen fairly late in the 
boot process. I never get to X, but maybe it will get far enough for 
a console login.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
