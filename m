Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id E4A0782966
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 18:08:00 -0400 (EDT)
Received: by mail-qc0-f178.google.com with SMTP id i8so6721464qcq.9
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 15:08:00 -0700 (PDT)
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
        by mx.google.com with ESMTPS id s32si2592424qgd.143.2014.04.11.15.08.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Apr 2014 15:08:00 -0700 (PDT)
Received: by mail-qg0-f45.google.com with SMTP id j5so5958904qga.4
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 15:07:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANq1E4TBtRcN+tpQW9bozQkRjJ7BJCK+KO0iw5k+8Q3Y3TcUeQ@mail.gmail.com>
References: <53470E26.2030306@cybernetics.com> <CANq1E4RWf_VbzF+dPYhzHKJvnrh86me5KajmaaB1u9f9FLzftA@mail.gmail.com>
 <5347451C.4060106@amacapital.net> <5347F188.10408@cybernetics.com>
 <CANq1E4T=38VLezGH2XUZ9kc=Vtp6Ca++-ATwmEfaXZS6UrTPig@mail.gmail.com>
 <53486067.6090506@mit.edu> <CANq1E4TBtRcN+tpQW9bozQkRjJ7BJCK+KO0iw5k+8Q3Y3TcUeQ@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 11 Apr 2014 15:07:38 -0700
Message-ID: <CALCETrWYRmkM3hyYu8WmSd-M=3mNMU2=xF_bSuTfyfkUTys5sg@mail.gmail.com>
Subject: Re: [PATCH 2/6] shm: add sealing API
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: Tony Battersby <tonyb@cybernetics.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>

On Fri, Apr 11, 2014 at 2:42 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
> Hi
>
> On Fri, Apr 11, 2014 at 11:36 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>> A quick grep of the kernel tree finds exactly zero code paths
>> incrementing i_mmap_writable outside of mmap and fork.
>>
>> Or do you mean a different kind of write ref?  What am I missing here?
>
> Sorry, I meant i_writecount.

I bet this is missing from lots of places.  For example, I can't find
any write_access stuff in the rdma code.

I suspect that the VM_DENYWRITE code is just generally racy.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
