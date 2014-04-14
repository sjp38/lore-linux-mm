Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 750B76B00C6
	for <linux-mm@kvack.org>; Sun, 13 Apr 2014 20:03:24 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id rl12so7547665iec.4
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 17:03:24 -0700 (PDT)
Received: from mail-ie0-x236.google.com (mail-ie0-x236.google.com [2607:f8b0:4001:c03::236])
        by mx.google.com with ESMTPS id x3si10435933igl.28.2014.04.13.17.03.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 13 Apr 2014 17:03:23 -0700 (PDT)
Received: by mail-ie0-f182.google.com with SMTP id y20so7538242ier.13
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 17:03:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrWYRmkM3hyYu8WmSd-M=3mNMU2=xF_bSuTfyfkUTys5sg@mail.gmail.com>
References: <53470E26.2030306@cybernetics.com>
	<CANq1E4RWf_VbzF+dPYhzHKJvnrh86me5KajmaaB1u9f9FLzftA@mail.gmail.com>
	<5347451C.4060106@amacapital.net>
	<5347F188.10408@cybernetics.com>
	<CANq1E4T=38VLezGH2XUZ9kc=Vtp6Ca++-ATwmEfaXZS6UrTPig@mail.gmail.com>
	<53486067.6090506@mit.edu>
	<CANq1E4TBtRcN+tpQW9bozQkRjJ7BJCK+KO0iw5k+8Q3Y3TcUeQ@mail.gmail.com>
	<CALCETrWYRmkM3hyYu8WmSd-M=3mNMU2=xF_bSuTfyfkUTys5sg@mail.gmail.com>
Date: Mon, 14 Apr 2014 02:03:22 +0200
Message-ID: <CANq1E4SU3QfLwBDEwDVGS7HNxOC2m2hjnv=ZuM1i+jCqqDM=sA@mail.gmail.com>
Subject: Re: [PATCH 2/6] shm: add sealing API
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Tony Battersby <tonyb@cybernetics.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>

Hi

On Sat, Apr 12, 2014 at 12:07 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> I bet this is missing from lots of places.  For example, I can't find
> any write_access stuff in the rdma code.
>
> I suspect that the VM_DENYWRITE code is just generally racy.

So what does S_IMMUTABLE do to prevent such races? I somehow suspect
it's broken in that regard, too.

I really dislike pinning pages like this, but if people want to keep
it I guess I have to scan all shmem-inode pages before changing seals.

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
