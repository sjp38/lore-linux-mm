Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7D488440441
	for <linux-mm@kvack.org>; Sat,  6 Feb 2016 08:22:32 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id xk3so111261546obc.2
        for <linux-mm@kvack.org>; Sat, 06 Feb 2016 05:22:32 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d8si11921523oif.136.2016.02.06.05.22.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 06 Feb 2016 05:22:31 -0800 (PST)
Subject: Re: [PATCH 1/5] mm, oom: introduce oom reaper
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org>
	<1454505240-23446-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1454505240-23446-2-git-send-email-mhocko@kernel.org>
Message-Id: <201602062222.HJH86328.SMFVtFOJFHQOLO@I-love.SAKURA.ne.jp>
Date: Sat, 6 Feb 2016 22:22:20 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> There is one notable exception to this, though, if the OOM victim was
> in the process of coredumping the result would be incomplete. This is
> considered a reasonable constrain because the overall system health is
> more important than debugability of a particular application.

Is it possible to clarify what "the result would be incomplete" mean?

  (1) The size of coredump file becomes smaller than it should be, and
      data in reaped pages is not included into the file.

  (2) The size of coredump file does not change, and data in reaped pages
      is included into the file as NUL byte.

  (3) The size of coredump file does not change, and data in reaped pages
      is included into the file as-is (i.e. information leak security risk).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
