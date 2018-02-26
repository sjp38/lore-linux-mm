Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C48D6B0006
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 04:02:37 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id n11so7372261plp.13
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 01:02:37 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0130.outbound.protection.outlook.com. [104.47.2.130])
        by mx.google.com with ESMTPS id v10-v6si6350704plz.406.2018.02.26.01.02.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 26 Feb 2018 01:02:36 -0800 (PST)
Subject: Re: [PATCH v5 0/4] vm: add a syscall to map a process memory into a
 pipe
References: <1515479453-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180220164406.3ec34509376f16841dc66e34@linux-foundation.org>
From: Pavel Emelyanov <xemul@virtuozzo.com>
Message-ID: <3122ec5a-7f73-f6b4-33ea-8c10ef32e5b0@virtuozzo.com>
Date: Mon, 26 Feb 2018 12:02:25 +0300
MIME-Version: 1.0
In-Reply-To: <20180220164406.3ec34509376f16841dc66e34@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, criu@openvz.org, gdb@sourceware.org, devel@lists.open-mpi.org, rr-dev@mozilla.org, Arnd Bergmann <arnd@arndb.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Josh Triplett <josh@joshtriplett.org>, Jann Horn <jannh@google.com>, Greg KH <gregkh@linuxfoundation.org>, Andrei Vagin <avagin@openvz.org>

On 02/21/2018 03:44 AM, Andrew Morton wrote:
> On Tue,  9 Jan 2018 08:30:49 +0200 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> 
>> This patches introduces new process_vmsplice system call that combines
>> functionality of process_vm_read and vmsplice.
> 
> All seems fairly strightforward.  The big question is: do we know that
> people will actually use this, and get sufficient value from it to
> justify its addition?

Yes, that's what bothers us a lot too :) I've tried to start with finding out if anyone 
used the sys_read/write_process_vm() calls, but failed :( Does anybody know how popular
these syscalls are? If its users operate on big amount of memory, they could benefit from
the proposed splice extension.

-- Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
