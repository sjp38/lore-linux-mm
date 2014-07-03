Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f173.google.com (mail-vc0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id A4B916B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 14:29:40 -0400 (EDT)
Received: by mail-vc0-f173.google.com with SMTP id lf12so618952vcb.4
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 11:29:40 -0700 (PDT)
Received: from mail-vc0-x22a.google.com (mail-vc0-x22a.google.com [2607:f8b0:400c:c03::22a])
        by mx.google.com with ESMTPS id ym12si14509369vdc.19.2014.07.03.11.29.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 11:29:39 -0700 (PDT)
Received: by mail-vc0-f170.google.com with SMTP id hy10so619329vcb.15
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 11:29:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFyRgYW6Y8paYKGfqE205enhiPsZ1C8wrKpFavVXq7ZAtA@mail.gmail.com>
References: <1404392547-11648-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	<CA+55aFxOTqUAqEF7+83s890Q18qCHSQqDOxWqWHNjG_25hVhXg@mail.gmail.com>
	<53B59CB5.9060004@linux.vnet.ibm.com>
	<CA+55aFyRgYW6Y8paYKGfqE205enhiPsZ1C8wrKpFavVXq7ZAtA@mail.gmail.com>
Date: Thu, 3 Jul 2014 11:29:38 -0700
Message-ID: <CA+55aFwwSCrH5QDvrzzyHhRU5R849Mo8A3NdRMwm9OTeWH9diQ@mail.gmail.com>
Subject: Re: [PATCH] mm readahead: Fix sys_readahead breakage by reverting 2MB
 limit (bug 79111)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, David Rientjes <rientjes@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jul 3, 2014 at 11:22 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So the bugzilla entry worries me a bit - we definitely do not want to
> regress in case somebody really relied on timing - but without more
> specific information I still think the real bug is just in the
> man-page.

Side note: the 2MB limit may be too small. 2M is peanuts on modern
machines, even for fairly slow IO, and there are lots of files (like
glibc etc) that people might want to read-ahead during boot. We
already do bigger read-ahead if people just do "read()" system calls.
So I could certainly imagine that we should increase it.

I do *not* think we should bow down to insane man-pages that have
always been wrong, though, and I don't think we should increase it to
"let's just read-ahead a whole ISO image" kind of sizes..

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
