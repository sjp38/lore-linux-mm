Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3BA246B0038
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 13:26:32 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id z8so93284124ybh.1
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 10:26:32 -0700 (PDT)
Received: from mail-it0-x231.google.com (mail-it0-x231.google.com. [2607:f8b0:4001:c0b::231])
        by mx.google.com with ESMTPS id v123si4967187itg.41.2016.09.15.10.26.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 10:26:31 -0700 (PDT)
Received: by mail-it0-x231.google.com with SMTP id 186so86171879itf.0
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 10:26:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1473759914-17003-16-git-send-email-byungchul.park@lge.com>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com> <1473759914-17003-16-git-send-email-byungchul.park@lge.com>
From: Nilay Vaish <nilayvaish@gmail.com>
Date: Thu, 15 Sep 2016 12:25:51 -0500
Message-ID: <CACbG30_tz=tkkibzH1od+2jLPq3k1W-6qsf6vDB=rwQ-Fm3ygg@mail.gmail.com>
Subject: Re: [PATCH v3 15/15] lockdep: Crossrelease feature documentation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On 13 September 2016 at 04:45, Byungchul Park <byungchul.park@lge.com> wrote:
> This document describes the concept of crossrelease feature, which
> generalizes what causes a deadlock and how can detect a deadlock.
>
> Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> ---
>  Documentation/locking/crossrelease.txt | 785 +++++++++++++++++++++++++++++++++
>  1 file changed, 785 insertions(+)
>  create mode 100644 Documentation/locking/crossrelease.txt

Byungchul, I mostly skimmed through the document.  I suggest that we
split this document.  The initial 1/4 of the document talks about
lockdep's current implementation which I believe should be combined
with the file: Documentation/locking/lockdep-design.txt. Tomorrow I
would try to understand the document in detail and hopefully provide
some useful comments.

--
Nilay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
