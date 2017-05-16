Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1B06B02EE
	for <linux-mm@kvack.org>; Mon, 15 May 2017 21:28:36 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id o25so125434384pgc.1
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:28:36 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id t76si12221192pgc.115.2017.05.15.18.28.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 18:28:35 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id f27so7540817pfe.0
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:28:35 -0700 (PDT)
Date: Tue, 16 May 2017 10:28:29 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH(RE-RESEND) v1 01/11] mm/kasan: rename _is_zero to _is_nonzero
Message-ID: <20170516012827.GB16015@js1304-desktop>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

Sorry for a noise.
Failure is due to suspicious subject.
Change it and resend.

---------------------->8-------------------
