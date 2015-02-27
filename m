Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0E16B006C
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 05:59:08 -0500 (EST)
Received: by wevl61 with SMTP id l61so19379575wev.2
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 02:59:08 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id et16si6583285wjc.84.2015.02.27.02.52.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Feb 2015 02:52:25 -0800 (PST)
Message-ID: <54F04C64.3050503@suse.cz>
Date: Fri, 27 Feb 2015 11:52:20 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] enhance shmem process and swap accounting
References: <1424958666-18241-1-git-send-email-vbabka@suse.cz> <CAHO5Pa0xmquUbzkZvow_PxRGZpA7MVEPFcRL2LPXv7hU41uxDw@mail.gmail.com>
In-Reply-To: <CAHO5Pa0xmquUbzkZvow_PxRGZpA7MVEPFcRL2LPXv7hU41uxDw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Jerome Marchand <jmarchan@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>

On 02/27/2015 11:36 AM, Michael Kerrisk wrote:
> [CC += linux-api@]
> 
> Hello Vlastimil,
> 
> Since this is a kernel-user-space API change, please CC linux-api@.
> The kernel source file Documentation/SubmitChecklist notes that all
> Linux kernel patches that change userspace interfaces should be CCed
> to linux-api@vger.kernel.org, so that the various parties who are
> interested in API changes are informed. For further information, see
> https://www.kernel.org/doc/man-pages/linux-api-ml.html

Yes I meant to do that but forgot in the end, what a shame. Sorry for the trouble.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
