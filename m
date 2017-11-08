Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B8D8A4403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 04:34:42 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v88so1038029wrb.22
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 01:34:42 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s193sor869081wme.84.2017.11.08.01.34.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Nov 2017 01:34:41 -0800 (PST)
Date: Wed, 8 Nov 2017 10:34:38 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] locking/lockdep: Revise
 Documentation/locking/crossrelease.txt
Message-ID: <20171108093438.t5zjpsgealkiamlh@gmail.com>
References: <1509344324-22399-1-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1509344324-22399-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com


* Byungchul Park <byungchul.park@lge.com> wrote:

> I'm afraid the revision is not perfect yet. Of course, the document can
> have got much better english by others than me.
> 
> But,
> 
> I think I should enhance it as much as I can, before they can help it
> starting with a better one.
> 
> In addition, I removed verboseness as much as possible.
> 
> ----->8-----
> From c7795104ca6ac6dd9f7fd944aee23a2011a6d3a2 Mon Sep 17 00:00:00 2001
> From: Byungchul Park <byungchul.park@lge.com>
> Date: Mon, 30 Oct 2017 14:51:26 +0900
> Subject: [PATCH] locking/lockdep: Revise
>  Documentation/locking/crossrelease.txt
> 
> The document should've been written with a better readability. Revise it
> to enhance its readability.
> 
> Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> ---
>  Documentation/locking/crossrelease.txt | 388 +++++++++++++++------------------

Could you please run a spellchecker over this text? It's still full of typos and 
various grammar mistakes...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
