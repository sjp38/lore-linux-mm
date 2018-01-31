Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id B86906B0006
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:03:15 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id x75so1218041ita.5
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 15:03:15 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j9si4664702ioo.247.2018.01.31.15.03.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Jan 2018 15:03:14 -0800 (PST)
Subject: Re: [Bug 198497] New: handle_mm_fault / xen_pmd_val /
 radix_tree_lookup_slot Null pointer
References: <bug-198497-27@https.bugzilla.kernel.org/>
 <20180118135518.639141f0b0ea8bb047ab6306@linux-foundation.org>
 <7ba7635e-249a-9071-75bb-7874506bd2b2@redhat.com>
 <20180119030447.GA26245@bombadil.infradead.org>
 <d38ff996-8294-81a6-075f-d7b2a60aa2f4@rimuhosting.com>
 <20180119132145.GB2897@bombadil.infradead.org>
 <9d2ddba4-3fb3-0fb4-a058-f2cfd1b05538@redhat.com>
 <32ab6fd6-e3c6-9489-8163-aa73861aa71a@rimuhosting.com>
 <20180126194058.GA31600@bombadil.infradead.org>
 <9ff38687-edde-6b4e-4532-9c150f8ea647@rimuhosting.com>
 <20180131105456.GC28275@bombadil.infradead.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <164f37f1-7365-7650-24d7-70da74b3313f@I-love.SAKURA.ne.jp>
Date: Thu, 1 Feb 2018 08:02:43 +0900
MIME-Version: 1.0
In-Reply-To: <20180131105456.GC28275@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, xen@randonwebstuff.com
Cc: Laura Abbott <labbott@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org

https://bugzilla.redhat.com/show_bug.cgi?id=1531779

It might be something related that
"x86/mm: Found insecure W+X mapping at address" message is printed at boot.

Are you seeing "x86/mm: Found insecure W+X mapping at address" before
hitting "BUG: unable to handle kernel NULL pointer dereference" ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
