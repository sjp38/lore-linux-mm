Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id C5F9D6B006E
	for <linux-mm@kvack.org>; Mon, 18 May 2015 18:27:25 -0400 (EDT)
Received: by pabts4 with SMTP id ts4so169460402pab.3
        for <linux-mm@kvack.org>; Mon, 18 May 2015 15:27:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gk9si17847583pbd.150.2015.05.18.15.27.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 15:27:24 -0700 (PDT)
Date: Mon, 18 May 2015 15:27:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: nommu: convert kenter/kleave/kdebug macros to use
 pr_devel()
Message-Id: <20150518152723.769799cced031e71582bfa74@linux-foundation.org>
In-Reply-To: <1431974526-21788-1-git-send-email-leon@leon.nu>
References: <n>
	<1431974526-21788-1-git-send-email-leon@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Romanovsky <leon@leon.nu>
Cc: dhowells@redhat.com, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 18 May 2015 21:42:06 +0300 Leon Romanovsky <leon@leon.nu> wrote:

> kenter/kleave/kdebug are wrapper macros to print functions flow and debug
> information. This set was written before pr_devel() was introduced, so
> it was controlled by "#if 0" construction.
> 
> This patch refactors the current macros to use general pr_devel()
> functions which won't be compiled in if "#define DEBUG" is not declared
> prior to that macros.

I doubt if anyone has used these in a decade and only a tenth of the
mm/nommu.c code is actually wired up to use the macros.

I'd suggest just removing it all.  If someone later has a need, they
can add their own pr_devel() calls.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
