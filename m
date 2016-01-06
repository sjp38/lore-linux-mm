Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8300F6B0003
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 04:44:23 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id z14so25103161igp.0
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 01:44:23 -0800 (PST)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id h137si12901228ioh.25.2016.01.06.01.44.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 01:44:23 -0800 (PST)
Received: by mail-io0-x243.google.com with SMTP id f81so539683iof.0
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 01:44:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1452056549-10048-3-git-send-email-mguzik@redhat.com>
References: <1452056549-10048-1-git-send-email-mguzik@redhat.com>
	<1452056549-10048-3-git-send-email-mguzik@redhat.com>
Date: Wed, 6 Jan 2016 15:14:22 +0530
Message-ID: <CAKeScWjvz7Bja6wMw5euWNWYdZ5_ikEdgR1Qk77pcCFajHmbeQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] proc read mm's {arg,env}_{start,end} with mmap
 semaphore taken.
From: Anshuman Khandual <anshuman.linux@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mateusz Guzik <mguzik@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexey Dobriyan <adobriyan@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jarod Wilson <jarod@redhat.com>, Jan Stancek <jstancek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>

On Wed, Jan 6, 2016 at 10:32 AM, Mateusz Guzik <mguzik@redhat.com> wrote:
> Only functions doing more than one read are modified. Consumeres
> happened to deal with possibly changing data, but it does not seem
> like a good thing to rely on.

There are no other functions which might be reading mm-> members without
having a lock ? Why just deal with functions with more than one read ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
