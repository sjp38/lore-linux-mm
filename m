Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BCB196B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 06:37:53 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 25so2758456wfa.11
        for <linux-mm@kvack.org>; Tue, 31 Mar 2009 03:38:28 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 31 Mar 2009 19:38:28 +0900
Message-ID: <28c262360903310338k20b8eebbncb86baac9b09e54@mail.gmail.com>
Subject: add_to_swap_cache with GFP_ATOMIC ?
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickens <hugh@veritas.com>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi, all.

Let me have a question.

I don't know why we should call add_to_swap_cache with GFP_ATOMIC ?
Is there a special something for avoiding blocking?

-- 
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
