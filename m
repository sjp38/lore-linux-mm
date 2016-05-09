Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f71.google.com (mail-qg0-f71.google.com [209.85.192.71])
	by kanga.kvack.org (Postfix) with ESMTP id 48E106B0005
	for <linux-mm@kvack.org>; Mon,  9 May 2016 14:07:49 -0400 (EDT)
Received: by mail-qg0-f71.google.com with SMTP id c103so298570564qge.1
        for <linux-mm@kvack.org>; Mon, 09 May 2016 11:07:49 -0700 (PDT)
Received: from mail-vk0-x230.google.com (mail-vk0-x230.google.com. [2607:f8b0:400c:c05::230])
        by mx.google.com with ESMTPS id b196si5132557vka.38.2016.05.09.11.07.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 May 2016 11:07:48 -0700 (PDT)
Received: by mail-vk0-x230.google.com with SMTP id o133so76114029vka.0
        for <linux-mm@kvack.org>; Mon, 09 May 2016 11:07:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160506150112.9b27324b4b2b141146b0ff25@linux-foundation.org>
References: <bug-117731-27@https.bugzilla.kernel.org/>
	<20160506150112.9b27324b4b2b141146b0ff25@linux-foundation.org>
Date: Mon, 9 May 2016 11:07:48 -0700
Message-ID: <CAM3pwhFHUzwKEShuOFos8nGqrjdNH=rwq55=ULWwOA5KEHVfWg@mail.gmail.com>
Subject: Re: [Bug 117731] New: Doing mprotect for PROT_NONE and then for
 PROT_READ|PROT_WRITE reduces CPU write B/W on buffer
From: Peter Feiner <pfeiner@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ashish0srivastava0@gmail.com, bugzilla-daemon@bugzilla.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org

On Fri, May 6, 2016 at 3:01 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> Great bug report, thanks.
>
> I assume the breakage was caused by
>
> commit 64e455079e1bd7787cc47be30b7f601ce682a5f6
> Author:     Peter Feiner <pfeiner@google.com>
> AuthorDate: Mon Oct 13 15:55:46 2014 -0700
> Commit:     Linus Torvalds <torvalds@linux-foundation.org>
> CommitDate: Tue Oct 14 02:18:28 2014 +0200
>
>     mm: softdirty: enable write notifications on VMAs after VM_SOFTDIRTY cleared
>
>
> Could someone (Peter, Kirill?) please take a look?

Thanks for the report! I'm taking a look.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
