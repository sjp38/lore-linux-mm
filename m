Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 203066B025F
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 04:12:29 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 30so11443108wrk.7
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 01:12:29 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id j19si2745015edh.128.2017.08.17.01.12.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 01:12:27 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id y67so7012398wrb.3
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 01:12:27 -0700 (PDT)
Date: Thu, 17 Aug 2017 10:12:24 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v8 00/14] lockdep: Implement crossrelease feature
Message-ID: <20170817081224.yp3qhqt6vijzvvpz@gmail.com>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <20170815082020.fvfahxwx2zt4ps4i@gmail.com>
 <20170816001637.GN20323@X58A-UD3R>
 <20170816035842.p33z5st3rr2gwssh@tardis>
 <20170817074811.csim2edowld4xvky@gmail.com>
 <20170817080404.GC11771@tardis>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170817080404.GC11771@tardis>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boqun Feng <boqun.feng@gmail.com>
Cc: Byungchul Park <byungchul.park@lge.com>, Thomas Gleixner <tglx@linutronix.de>, peterz@infradead.org, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com


* Boqun Feng <boqun.feng@gmail.com> wrote:

> > BTW., I don't think the #ifdef is necessary: lockdep_init_map_crosslock should map 
> > to nothing when lockdep is disabled, right?
> 
> IIUC, lockdep_init_map_crosslock is only defined when
> CONFIG_LOCKDEP_CROSSRELEASE=y,

Then lockdep_init_map_crosslock() should be defined in the !LOCKDEP case as well.

> [...] moreover, completion::map, which used as
> the parameter of lockdep_init_map_crosslock(), is only defined when
> CONFIG_LOCKDEP_COMPLETE=y.

If the !LOCKDEP wrapper is a CPP macro then it can ignore that parameter just 
fine, and it won't be built.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
