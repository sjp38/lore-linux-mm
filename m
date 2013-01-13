Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id B4EBD6B0071
	for <linux-mm@kvack.org>; Sun, 13 Jan 2013 11:12:46 -0500 (EST)
Received: by mail-qa0-f43.google.com with SMTP id cr7so919784qab.2
        for <linux-mm@kvack.org>; Sun, 13 Jan 2013 08:12:45 -0800 (PST)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
Date: Sun, 13 Jan 2013 17:12:45 +0100
Message-ID: <CA+icZUW5kryOCpX96CkaS=5uX61FmiYE0mh7y6F0eT9Bh8eUGw@mail.gmail.com>
Subject: Unique commit-id for "mm: compaction: [P,p]artially revert capture of
 suitable high-order page"
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

Hi Linus,

I see two different commit-id for an identical patch (only subject
line differs).
[1] seems to be applied directly and [2] came with a merge of akpm-fixes.
What is in case of backports for -stable kernels?

Regards,
- Sedat -

[1] http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commitdiff;h=47ecfcb7d01418fcbfbc75183ba5e28e98b667b2
[2] http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commitdiff;h=8fb74b9fb2b182d54beee592350d9ea1f325917a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
