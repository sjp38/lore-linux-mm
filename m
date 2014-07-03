Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f170.google.com (mail-ve0-f170.google.com [209.85.128.170])
	by kanga.kvack.org (Postfix) with ESMTP id 80A5F6B0036
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 11:42:00 -0400 (EDT)
Received: by mail-ve0-f170.google.com with SMTP id i13so428831veh.1
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 08:42:00 -0700 (PDT)
Received: from mail-vc0-x232.google.com (mail-vc0-x232.google.com [2607:f8b0:400c:c03::232])
        by mx.google.com with ESMTPS id c2si14355234vcn.74.2014.07.03.08.41.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 08:41:59 -0700 (PDT)
Received: by mail-vc0-f178.google.com with SMTP id ij19so411999vcb.9
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 08:41:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1404392547-11648-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
References: <1404392547-11648-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Date: Thu, 3 Jul 2014 08:41:58 -0700
Message-ID: <CA+55aFxOTqUAqEF7+83s890Q18qCHSQqDOxWqWHNjG_25hVhXg@mail.gmail.com>
Subject: Re: [PATCH] mm readahead: Fix sys_readahead breakage by reverting 2MB
 limit (bug 79111)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, David Rientjes <rientjes@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jul 3, 2014 at 6:02 AM, Raghavendra K T
<raghavendra.kt@linux.vnet.ibm.com> wrote:
>
> However it broke sys_readahead semantics: 'readahead() blocks until the specified
> data has been read'

What? Where did you find that insane sentence? And where did you find
an application that depends on that totally insane semantics that sure
as hell was never intentional.

If this comes from some man-page, then the man-page is just full of
sh*t, and is being crazy. The whole and *only* point of readahead() is
that it does *not* block, and you can do it across multiple files.

So NAK NAK NAK. This is insane and completely wrong. And the bugzilla
is crazy too. Why would anybody think that readahead() is the same as
read()?

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
