Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f175.google.com (mail-ve0-f175.google.com [209.85.128.175])
	by kanga.kvack.org (Postfix) with ESMTP id 893846B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 14:53:59 -0400 (EDT)
Received: by mail-ve0-f175.google.com with SMTP id jx11so676804veb.6
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 11:53:59 -0700 (PDT)
Received: from mail-vc0-x22c.google.com (mail-vc0-x22c.google.com [2607:f8b0:400c:c03::22c])
        by mx.google.com with ESMTPS id sq3si6041110vdb.76.2014.07.03.11.53.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 11:53:58 -0700 (PDT)
Received: by mail-vc0-f172.google.com with SMTP id hy10so651147vcb.31
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 11:53:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53B5A343.4090402@linux.vnet.ibm.com>
References: <1404392547-11648-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	<CA+55aFxOTqUAqEF7+83s890Q18qCHSQqDOxWqWHNjG_25hVhXg@mail.gmail.com>
	<53B59CB5.9060004@linux.vnet.ibm.com>
	<CA+55aFyRgYW6Y8paYKGfqE205enhiPsZ1C8wrKpFavVXq7ZAtA@mail.gmail.com>
	<CA+55aFwwSCrH5QDvrzzyHhRU5R849Mo8A3NdRMwm9OTeWH9diQ@mail.gmail.com>
	<53B5A343.4090402@linux.vnet.ibm.com>
Date: Thu, 3 Jul 2014 11:53:57 -0700
Message-ID: <CA+55aFyqK90YJkjtHR2QGFt4Mvn=mj8a4FkB_8nbTTj3=jp3NA@mail.gmail.com>
Subject: Re: [PATCH] mm readahead: Fix sys_readahead breakage by reverting 2MB
 limit (bug 79111)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, David Rientjes <rientjes@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jul 3, 2014 at 11:38 AM, Raghavendra K T
<raghavendra.kt@linux.vnet.ibm.com> wrote:
>
> Okay, how about something like 256MB? I would be happy to send a patch
> for that change.

I'd like to see some performance numbers. I know at least Fedora uses
"readahead()" in the startup scripts, do we have any performance
numbers for that?

Also, I think 256MB is actually excessive. People still do have really
slow devices out there. USB-2 is still common, and drives that read at
15MB/s are not unusual. Do we really want to do readahead() that can
take tens of seconds (and *will* take tens of seconds sycnhronously,
because the IO requests fill up).

So I wouldn't go from 2 to 256. That seems like an excessive jump. I
was more thinking in the 4-8MB range. But even then, I think we should
always have technical reasons (ie preferably numbers) for the change,
not just randomly change it.

           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
