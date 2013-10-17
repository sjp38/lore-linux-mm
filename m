Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id E2B716B0069
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 09:14:49 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id y10so30246pdj.38
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 06:14:49 -0700 (PDT)
Received: by mail-qc0-f176.google.com with SMTP id s19so74757qcw.7
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 06:14:46 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 17 Oct 2013 18:44:45 +0530
Message-ID: <CAJ_BOiC3gSUKwQg8maayg0S7tdcY6ME86QBYWpiGwXk7mBSL_Q@mail.gmail.com>
Subject: x86 like DEBUG_PAGEALLOC for ARM
From: Prabhat Kumar Ravi <prabhatravi09@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi all,

As in our present ARM kernel we don't have feature like
DEBUG_PAGEALLOC which generate exception if a program touched the
unmaped pages.

Trying to implement kernel_map_pages() for ARM,

Can anyone help me in that.


Regards,
Prabhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
