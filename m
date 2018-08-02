Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 977A36B0006
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 17:02:35 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id o12-v6so1973065pls.20
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 14:02:35 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i184-v6si2967824pfg.250.2018.08.02.14.02.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 14:02:24 -0700 (PDT)
Date: Thu, 2 Aug 2018 14:02:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm:bugfix check return value of ioremap_prot
Message-Id: <20180802140222.5957911883678f8271f636aa@linux-foundation.org>
In-Reply-To: <CAHbLzkpj9chSMFWWhSb1hTL86rWdys3a=2oHgLjp_e-mDGF1Sw@mail.gmail.com>
References: <1533195441-58594-1-git-send-email-chenjie6@huawei.com>
	<CAHbLzkpj9chSMFWWhSb1hTL86rWdys3a=2oHgLjp_e-mDGF1Sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <shy828301@gmail.com>
Cc: chenjie6@huawei.com, linux-mm@kvack.org, tj@kernel.org, lizefan@huawei.com, chen jie <"chen jie@chenjie6"@huwei.com>, Alexey Dobriyan <adobriyan@gmail.com>

On Thu, 2 Aug 2018 09:47:52 -0700 Yang Shi <shy828301@gmail.com> wrote:

> On Thu, Aug 2, 2018 at 12:37 AM,  <chenjie6@huawei.com> wrote:
> > From: chen jie <chen jie@chenjie6@huwei.com>
> >
> >         ioremap_prot can return NULL which could lead to an oops
> 
> What oops? You'd better to have the oops information in your commit log.

Doesn't matter much - the code is clearly buggy.

Looking at the callers, I have suspicions about
fs/proc/base.c:environ_read().  It's assuming that access_remote_vm()
returns an errno.  But it doesn't - it returns number of bytes copied.

Alexey, could you please take a look?  While in there, I'd suggest
adding some return value documentation to __access_remote_vm() and
access_remote_vm().  Thanks.
