Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 91A3F6B0069
	for <linux-mm@kvack.org>; Sat, 30 Sep 2017 15:20:28 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 53so1388382qtz.21
        for <linux-mm@kvack.org>; Sat, 30 Sep 2017 12:20:28 -0700 (PDT)
Received: from outprodmail01.cc.columbia.edu (outprodmail01.cc.columbia.edu. [128.59.72.39])
        by mx.google.com with ESMTPS id t3si5483066qtd.285.2017.09.30.12.20.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Sep 2017 12:20:27 -0700 (PDT)
Received: from hazelnut (hazelnut.cc.columbia.edu [128.59.213.250])
	by outprodmail01.cc.columbia.edu (8.14.4/8.14.4) with ESMTP id v8UJK87U011404
	for <linux-mm@kvack.org>; Sat, 30 Sep 2017 15:20:27 -0400
Received: from hazelnut (localhost.localdomain [127.0.0.1])
	by hazelnut (Postfix) with ESMTP id 549C27E
	for <linux-mm@kvack.org>; Sat, 30 Sep 2017 15:20:27 -0400 (EDT)
Received: from sendprodmail03.cc.columbia.edu (sendprodmail03.cc.columbia.edu [128.59.72.15])
	by hazelnut (Postfix) with ESMTP id 3AC337E
	for <linux-mm@kvack.org>; Sat, 30 Sep 2017 15:20:27 -0400 (EDT)
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by sendprodmail03.cc.columbia.edu (8.14.4/8.14.4) with ESMTP id v8UJKQoo041796
	(version=TLSv1/SSLv3 cipher=AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 30 Sep 2017 15:20:27 -0400
Received: by mail-wr0-f197.google.com with SMTP id a43so2103077wrc.2
        for <linux-mm@kvack.org>; Sat, 30 Sep 2017 12:20:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAASgV=sdweCbYxZRn3RR_gEm5qzyjLRHq+Ctk1vTD0yj5VjjLw@mail.gmail.com>
References: <CAASgV=sdweCbYxZRn3RR_gEm5qzyjLRHq+Ctk1vTD0yj5VjjLw@mail.gmail.com>
From: Shankara Pailoor <sp3485@columbia.edu>
Date: Sat, 30 Sep 2017 15:20:25 -0400
Message-ID: <CAASgV=tjsY1tdxryj_3_TeA_N_SjbXUoUfVd8fu33+dHTx13tw@mail.gmail.com>
Subject: Re: Hung Task Linux 4.13-rc7 Reiserfs
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, reiserfs-devel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Zhu Aday <andrew.aday@columbia.edu>, syzkaller <syzkaller@googlegroups.com>

Hi,

I have a reproducer program. It takes about 3-5 minutes to trigger the
hang. The only calls are mmap, open, write, and readahead and the
writes are fairly small (512 bytes).

Reproducer Program: https://pastebin.com/cx1cgABc
Report: https://pastebin.com/uGTAw45E
Logs: https://pastebin.com/EaiE0JLf
Kernel Configs: https://pastebin.com/i6URdADw

Regards,
Shankara

On Fri, Sep 29, 2017 at 11:56 PM, Shankara Pailoor <sp3485@columbia.edu> wrote:
> Hi,
>
> I am fuzzing the kernel 4.13-rc7 with Syzkaller with Reiserfs. I am
> getting the following crash:
>
> INFO: task kworker/0:3:1103 blocked for more than 120 seconds.
>
>
> Here is the full stack trace. I noticed that there are a few tasks
> holding a sbi->lock. Below are a report and a log of all the programs
> executing at the time of the incident.
>
>
> Report: https://pastebin.com/uGTAw45E
> Logs: https://pastebin.com/EaiE0JLf
> Kernel Configs: https://pastebin.com/i6URdADw
>
> I don't have a reproducer yet and any assistance would be appreciated.
>
> Regards,
> Shankara

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
