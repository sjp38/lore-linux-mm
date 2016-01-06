Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 409FC6B0003
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 04:35:10 -0500 (EST)
Received: by mail-io0-f173.google.com with SMTP id 1so166378439ion.1
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 01:35:10 -0800 (PST)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id cq10si12131377igb.41.2016.01.06.01.35.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 01:35:09 -0800 (PST)
Received: by mail-io0-x22a.google.com with SMTP id 77so182304997ioc.2
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 01:35:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1452056549-10048-2-git-send-email-mguzik@redhat.com>
References: <1452056549-10048-1-git-send-email-mguzik@redhat.com>
	<1452056549-10048-2-git-send-email-mguzik@redhat.com>
Date: Wed, 6 Jan 2016 15:05:09 +0530
Message-ID: <CAKeScWgfg2G6q7ffBLGi2R_xHcp+8NbYEQ7t73pY9oDKWgeqog@mail.gmail.com>
Subject: Re: [PATCH 1/2] prctl: take mmap sem for writing to protect against others
From: Anshuman Khandual <anshuman.linux@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mateusz Guzik <mguzik@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexey Dobriyan <adobriyan@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jarod Wilson <jarod@redhat.com>, Jan Stancek <jstancek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>

On Wed, Jan 6, 2016 at 10:32 AM, Mateusz Guzik <mguzik@redhat.com> wrote:
> The code was taking the semaphore for reading, which does not protect
> against readers nor concurrent modifications.

(down/up)_read does not protect against concurrent readers ?

>
> The problem could cause a sanity checks to fail in procfs's cmdline
> reader, resulting in an OOPS.
>

Can you explain this a bit and may be give some examples ?

> Note that some functions perform an unlocked read of various mm fields,
> but they seem to be fine despite possible modificaton.

Those need to be fixed as well ?

> Signed-off-by: Mateusz Guzik <mguzik@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
