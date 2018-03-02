Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D1AAC6B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 18:38:53 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v16so7361070wrv.14
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 15:38:53 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p4si1452951wmh.161.2018.03.02.15.38.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 15:38:52 -0800 (PST)
Date: Fri, 2 Mar 2018 15:38:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] userfaultfd: non-cooperative: syncronous events
Message-Id: <20180302153849.d9d7b9a873755c6f5e883d0d@linux-foundation.org>
In-Reply-To: <1519719592-22668-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1519719592-22668-1-git-send-email-rppt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, linux-api <linux-api@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, crml <criu@openvz.org>

On Tue, 27 Feb 2018 10:19:49 +0200 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> Hi,
> 
> These patches add ability to generate userfaultfd events so that their
> processing will be synchronized with the non-cooperative thread that caused
> the event.
> 
> In the non-cooperative case userfaultfd resumes execution of the thread
> that caused an event when the notification is read() by the uffd monitor.
> In some cases, like, for example, madvise(MADV_REMOVE), it might be
> desirable to keep the thread that caused the event suspended until the
> uffd monitor had the event handled to avoid races between the thread that
> caused the and userfaultfd ioctls.
> 
> Theses patches extend the userfaultfd API with an implementation of
> UFFD_EVENT_REMOVE_SYNC that allows to keep the thread that triggered
> UFFD_EVENT_REMOVE until the uffd monitor would not wake it explicitly.

"might be desirable" is a bit weak.  It might not be desirable, too ;)

_Is_ it desirable?  What are the use-cases and what is the end-user
benefit?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
