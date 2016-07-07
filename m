Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id B9FD66B025E
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 06:18:02 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id u81so23228856oia.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 03:18:02 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 89si2728676iot.168.2016.07.07.03.18.01
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 03:18:02 -0700 (PDT)
Date: Thu, 7 Jul 2016 19:16:13 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [RFC v2 00/13] lockdep: Implement crossrelease feature
Message-ID: <20160707101613.GE2279@X58A-UD3R>
References: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467883803-29132-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel@kyup.com

+cc Nikolay Borisov <kernel@kyup.com>

who might be interested in this patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
