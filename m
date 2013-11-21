Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id AA8746B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 19:52:13 -0500 (EST)
Received: by mail-qc0-f174.google.com with SMTP id r5so2471841qcx.5
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 16:52:13 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id nj18si17969579qeb.35.2013.11.20.16.52.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Nov 2013 16:52:10 -0800 (PST)
Message-ID: <528D5935.6070907@infradead.org>
Date: Wed, 20 Nov 2013 16:52:05 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: mmotm 2013-11-20-16-13 uploaded (arch/um/kernel/sysrq.c)
References: <20131121001408.17DC85A41C6@corp2gmr1-2.hot.corp.google.com>
In-Reply-To: <20131121001408.17DC85A41C6@corp2gmr1-2.hot.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Richard Weinberger <richard@nod.at>, user-mode-linux-devel@lists.sourceforge.net

On 11/20/13 16:14, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2013-11-20-16-13 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 

on i386:
(with um i386 defconfig)

arch/um/kernel/sysrq.c:22:13: error: expected identifier or '(' before 'do'
um/kernel/sysrq.c:22:13: error: expected identifier or '(' before 'while'


so sysrq.c is picking up <linux/stacktrace.h> somehow and not liking it.


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
