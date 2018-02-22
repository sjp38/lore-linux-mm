Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1DCA16B0003
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 17:31:06 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id h14so4291747wre.19
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 14:31:06 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 21si301227wmi.26.2018.02.22.14.31.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Feb 2018 14:31:04 -0800 (PST)
Date: Thu, 22 Feb 2018 14:31:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] Bug fixes for smaps_rollup
Message-Id: <20180222143102.e0ca18d0f64ee752947ad3fe@linux-foundation.org>
In-Reply-To: <20180222052659.106016-2-dancol@google.com>
References: <20180222052659.106016-1-dancol@google.com>
	<20180222052659.106016-2-dancol@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>
Cc: linux-mm@kvack.org

On Wed, 21 Feb 2018 21:26:58 -0800 Daniel Colascione <dancol@google.com> wrote:

> Properly account and display pss_locked; behave properly when seq_file
> starts and stops multiple times on a single open file description,
> when when it issues multiple show calls, and when seq_file seeks to a
> non-zero position.

For each of these bugs can we please see a detailed description of the
misbehavior?  A good way of presenting that info is to show the
example commands, the resulting output and an explanation of why it was
wrong.  "behave properly" doesn't cut it ;)

There might be requests for one-fix-per-patch, too.  And it is the best
way, although I overlook that at times.

Please also attempt to cc the relevant developers.  `git blame' is a
good way of finding them.  Kirill, Oleg, adobriyan...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
