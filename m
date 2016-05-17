Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9A6996B0005
	for <linux-mm@kvack.org>; Tue, 17 May 2016 08:04:01 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m64so8131712lfd.1
        for <linux-mm@kvack.org>; Tue, 17 May 2016 05:04:01 -0700 (PDT)
Received: from mail-lb0-x242.google.com (mail-lb0-x242.google.com. [2a00:1450:4010:c04::242])
        by mx.google.com with ESMTPS id kv18si2223041lbb.191.2016.05.17.05.04.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 05:04:00 -0700 (PDT)
Received: by mail-lb0-x242.google.com with SMTP id mx9so809564lbb.2
        for <linux-mm@kvack.org>; Tue, 17 May 2016 05:04:00 -0700 (PDT)
Date: Tue, 17 May 2016 15:03:57 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [Bug 117731] New: Doing mprotect for PROT_NONE and then for
 PROT_READ|PROT_WRITE reduces CPU write B/W on buffer
Message-ID: <20160517120357.GE9540@node.shutemov.name>
References: <bug-117731-27@https.bugzilla.kernel.org/>
 <20160506150112.9b27324b4b2b141146b0ff25@linux-foundation.org>
 <20160516133543.GA9540@node.shutemov.name>
 <CAGoWJG8mEwscwkUW31ejFyHR63Jm4eQKtUDpeADB2nUinrL59w@mail.gmail.com>
 <20160517113634.GD9540@node.shutemov.name>
 <CAGoWJG-3-SSkr8CTrjOEBfMtiNEbyeo6ynbnC5FiOiMiy5n8fA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGoWJG-3-SSkr8CTrjOEBfMtiNEbyeo6ynbnC5FiOiMiy5n8fA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ashish Srivastava <ashish0srivastava0@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, Peter Feiner <pfeiner@google.com>, linux-mm@kvack.org

On Tue, May 17, 2016 at 05:17:23PM +0530, Ashish Srivastava wrote:
> > Test-case for that would be helpful, as normal malloc()'ed anon memory
> > cannot be subject for the bug. Unless I miss something obvious.
> 
> I've modified the test-case attached to the bug and now it doesn't use
> malloc()'ed memory but file backed mmap shared memory.

Yes, that's consistent with your analysis.

You can post the patch with my Acked-by.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
