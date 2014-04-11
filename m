Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id EBF276B003A
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 17:42:21 -0400 (EDT)
Received: by mail-ig0-f172.google.com with SMTP id hn18so1336132igb.11
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 14:42:21 -0700 (PDT)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id gw5si7094389icb.58.2014.04.11.14.42.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Apr 2014 14:42:21 -0700 (PDT)
Received: by mail-ig0-f172.google.com with SMTP id hn18so1354850igb.5
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 14:42:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53486067.6090506@mit.edu>
References: <53470E26.2030306@cybernetics.com>
	<CANq1E4RWf_VbzF+dPYhzHKJvnrh86me5KajmaaB1u9f9FLzftA@mail.gmail.com>
	<5347451C.4060106@amacapital.net>
	<5347F188.10408@cybernetics.com>
	<CANq1E4T=38VLezGH2XUZ9kc=Vtp6Ca++-ATwmEfaXZS6UrTPig@mail.gmail.com>
	<53486067.6090506@mit.edu>
Date: Fri, 11 Apr 2014 23:42:19 +0200
Message-ID: <CANq1E4TBtRcN+tpQW9bozQkRjJ7BJCK+KO0iw5k+8Q3Y3TcUeQ@mail.gmail.com>
Subject: Re: [PATCH 2/6] shm: add sealing API
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Tony Battersby <tonyb@cybernetics.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>

Hi

On Fri, Apr 11, 2014 at 11:36 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> A quick grep of the kernel tree finds exactly zero code paths
> incrementing i_mmap_writable outside of mmap and fork.
>
> Or do you mean a different kind of write ref?  What am I missing here?

Sorry, I meant i_writecount.

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
