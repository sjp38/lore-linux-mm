Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B90626B0033
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 05:57:05 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id i83so3941928wma.4
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 02:57:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a22si1480004edb.327.2017.12.04.02.57.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 02:57:04 -0800 (PST)
Date: Mon, 4 Dec 2017 11:55:49 +0100
From: Cyril Hrubis <chrubis@suse.cz>
Subject: Re: [PATCH v2] mmap.2: MAP_FIXED updated documentation
Message-ID: <20171204105549.GA31332@rei>
References: <20171204021411.4786-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171204021411.4786-1-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, linux-man <linux-man@vger.kernel.org>, linux-api@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Jann Horn <jannh@google.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, John Hubbard <jhubbard@nvidia.com>

Hi!
I know that we are not touching the rest of the existing description for
MAP_FIXED however the second sentence in the manual page says that "addr
must be a multiple of the page size." Which however is misleading as
this is not enough on some architectures. Code in the wild seems to
(mis)use SHMLBA for aligment purposes but I'm not sure that we should
advise something like that in the manpages.

So what about something as:

"addr must be suitably aligned, for most architectures multiple of page
size is sufficient, however some may impose additional restrictions for
page mapping addresses."

Which should at least hint the reader that this is architecture specific.

-- 
Cyril Hrubis
chrubis@suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
