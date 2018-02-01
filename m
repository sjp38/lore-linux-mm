Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 76C066B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 04:48:06 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id w19so1165161pgv.4
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 01:48:06 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q90si1478097pfa.91.2018.02.01.01.48.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 01 Feb 2018 01:48:05 -0800 (PST)
Date: Thu, 1 Feb 2018 01:48:01 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [Bug 198497] New: handle_mm_fault / xen_pmd_val /
 radix_tree_lookup_slot Null pointer
Message-ID: <20180201094801.GB20742@bombadil.infradead.org>
References: <7ba7635e-249a-9071-75bb-7874506bd2b2@redhat.com>
 <20180119030447.GA26245@bombadil.infradead.org>
 <d38ff996-8294-81a6-075f-d7b2a60aa2f4@rimuhosting.com>
 <20180119132145.GB2897@bombadil.infradead.org>
 <9d2ddba4-3fb3-0fb4-a058-f2cfd1b05538@redhat.com>
 <32ab6fd6-e3c6-9489-8163-aa73861aa71a@rimuhosting.com>
 <20180126194058.GA31600@bombadil.infradead.org>
 <9ff38687-edde-6b4e-4532-9c150f8ea647@rimuhosting.com>
 <20180131105456.GC28275@bombadil.infradead.org>
 <164f37f1-7365-7650-24d7-70da74b3313f@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <164f37f1-7365-7650-24d7-70da74b3313f@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: xen@randonwebstuff.com, Laura Abbott <labbott@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org

On Thu, Feb 01, 2018 at 08:02:43AM +0900, Tetsuo Handa wrote:
> https://bugzilla.redhat.com/show_bug.cgi?id=1531779
> 
> It might be something related that
> "x86/mm: Found insecure W+X mapping at address" message is printed at boot.
> 
> Are you seeing "x86/mm: Found insecure W+X mapping at address" before
> hitting "BUG: unable to handle kernel NULL pointer dereference" ?

There are about eight different bugs in that thread; the only commonality
I see between them is that there's a null pointer dereference somewhere
in the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
