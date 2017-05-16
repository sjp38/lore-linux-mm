Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE126B02EE
	for <linux-mm@kvack.org>; Mon, 15 May 2017 21:24:03 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id p29so125306082pgn.3
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:24:03 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id l33si11882764pld.320.2017.05.15.18.24.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 18:24:02 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id s62so19231601pgc.0
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:24:02 -0700 (PDT)
Date: Tue, 16 May 2017 10:23:52 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH(RESEND) v1 01/11] mm/kasan: rename XXX_is_zero to
 XXX_is_nonzero
Message-ID: <20170516012350.GA16015@js1304-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com

Reply-To: 
In-Reply-To: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>

Look like there is a sending failure so resend this patch.

-------------------------->8-----------------------------
