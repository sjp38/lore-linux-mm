Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id D7C1B6B0032
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 13:22:41 -0500 (EST)
Received: by pdjp10 with SMTP id p10so1504523pdj.3
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 10:22:41 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id rz8si2264592pbc.28.2015.02.19.10.22.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Feb 2015 10:22:40 -0800 (PST)
Message-ID: <1424370153.18191.12.camel@stgolabs.net>
Subject: Re: [PATCH 3/3] tomoyo: robustify handling of mm->exe_file
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Thu, 19 Feb 2015 10:22:33 -0800
In-Reply-To: <201502192007.AFI30725.tHFFOOMVFOQSLJ@I-love.SAKURA.ne.jp>
References: <1424304641-28965-1-git-send-email-dbueso@suse.de>
	 <1424304641-28965-4-git-send-email-dbueso@suse.de>
	 <1424324307.18191.5.camel@stgolabs.net>
	 <201502192007.AFI30725.tHFFOOMVFOQSLJ@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, takedakn@nttdata.co.jp, linux-security-module@vger.kernel.org

On Thu, 2015-02-19 at 20:07 +0900, Tetsuo Handa wrote:
> Why do we need to let the caller call path_put() ?
> There is no need to do like proc_exe_link() does, for
> tomoyo_get_exe() returns pathname as "char *".

Having the pathname doesn't guarantee anything later, and thus doesn't
seem very robust in the manager call if it can be dropped during the
call... or can this never occur in this context?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
