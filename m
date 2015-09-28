Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2465E82F65
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:32:28 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so85528114pab.3
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 12:32:27 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id qy7si30829357pab.12.2015.09.28.12.32.27
        for <linux-mm@kvack.org>;
        Mon, 28 Sep 2015 12:32:27 -0700 (PDT)
Subject: Re: [PATCH 10/26] x86, pkeys: notify userspace about protection key
 faults
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174906.51062FBC@viggo.jf.intel.com>
 <20150924092320.GA26876@gmail.com> <56042F96.6030107@sr71.net>
 <56099444.1010902@de.ibm.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <560995CA.2000403@sr71.net>
Date: Mon, 28 Sep 2015 12:32:26 -0700
MIME-Version: 1.0
In-Reply-To: <56099444.1010902@de.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>, Ingo Molnar <mingo@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On 09/28/2015 12:25 PM, Christian Borntraeger wrote:
> We do not have the storage keys per page table, but for the page frame instead 
> (shared among all mappers) so I am not sure if the whole thing will fit for s390.
> Having a signal for page protection errors might be useful for us - not sure yet.

Ugh, yeah, that's a pretty different architecture.  The stuff we have
here (syscall, VMA flags, etc...) is probably useful to you only for
controlling access to non-shared memory.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
