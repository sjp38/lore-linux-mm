Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 81F2F6B0005
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 05:46:37 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id ot10so19392481obb.3
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 02:46:37 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0107.outbound.protection.outlook.com. [157.55.234.107])
        by mx.google.com with ESMTPS id 61si12337651otp.38.2016.06.21.02.46.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 21 Jun 2016 02:46:35 -0700 (PDT)
Date: Tue, 21 Jun 2016 12:46:25 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH v3 04/13] mm: Track NR_KERNEL_STACK in KiB instead of
 number of stacks
Message-ID: <20160621094625.GA15970@esperanza>
References: <cover.1466466093.git.luto@kernel.org>
 <053517e55aaf7ab1bbb7424abd89a1ac5535aa64.1466466093.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <053517e55aaf7ab1bbb7424abd89a1ac5535aa64.1466466093.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Brian Gerst <brgerst@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Linus Torvalds <torvalds@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Jann Horn <jann@thejh.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

On Mon, Jun 20, 2016 at 04:43:34PM -0700, Andy Lutomirski wrote:
> Currently, NR_KERNEL_STACK tracks the number of kernel stacks in a
> zone.  This only makes sense if each kernel stack exists entirely in
> one zone, and allowing vmapped stacks could break this assumption.
> 
> Since frv has THREAD_SIZE < PAGE_SIZE, we need to track kernel stack
> allocations in a unit that divides both THREAD_SIZE and PAGE_SIZE on
> all architectures.  Keep it simple and use KiB.
> 
> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: linux-mm@kvack.org
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
