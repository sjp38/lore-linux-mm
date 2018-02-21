Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 47B616B0003
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 19:44:11 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w10so9446373wrg.2
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 16:44:11 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y6si8511036wrg.454.2018.02.20.16.44.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Feb 2018 16:44:09 -0800 (PST)
Date: Tue, 20 Feb 2018 16:44:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 0/4] vm: add a syscall to map a process memory into a
 pipe
Message-Id: <20180220164406.3ec34509376f16841dc66e34@linux-foundation.org>
In-Reply-To: <1515479453-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1515479453-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, criu@openvz.org, gdb@sourceware.org, devel@lists.open-mpi.org, rr-dev@mozilla.org, Arnd Bergmann <arnd@arndb.de>, Pavel Emelyanov <xemul@virtuozzo.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Josh Triplett <josh@joshtriplett.org>, Jann Horn <jannh@google.com>, Greg KH <gregkh@linuxfoundation.org>, Andrei Vagin <avagin@openvz.org>

On Tue,  9 Jan 2018 08:30:49 +0200 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> This patches introduces new process_vmsplice system call that combines
> functionality of process_vm_read and vmsplice.

All seems fairly strightforward.  The big question is: do we know that
people will actually use this, and get sufficient value from it to
justify its addition?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
