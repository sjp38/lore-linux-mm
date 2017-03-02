Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 267ED6B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 23:45:40 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id x63so3875617pfx.7
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 20:45:40 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id r131si6419848pgr.156.2017.03.01.20.45.38
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 20:45:39 -0800 (PST)
From: "byungchul.park" <byungchul.park@lge.com>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com> <1484745459-2055-7-git-send-email-byungchul.park@lge.com> <20170228181547.GM5680@worktop> <20170302042021.GN16328@bombadil.infradead.org>
In-Reply-To: <20170302042021.GN16328@bombadil.infradead.org>
Subject: RE: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Date: Thu, 2 Mar 2017 13:45:35 +0900
Message-ID: <004101d2930f$d51a9f90$7f4fdeb0$@lge.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Matthew Wilcox' <willy@infradead.org>, 'Peter Zijlstra' <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com

> -----Original Message-----
> From: Matthew Wilcox [mailto:willy@infradead.org]
> Sent: Thursday, March 02, 2017 1:20 PM
> To: Peter Zijlstra
> Cc: Byungchul Park; mingo@kernel.org; tglx@linutronix.de;
> walken@google.com; boqun.feng@gmail.com; kirill@shutemov.name; linux-
> kernel@vger.kernel.org; linux-mm@kvack.org; iamjoonsoo.kim@lge.com;
> akpm@linux-foundation.org; npiggin@gmail.com
> Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
> 
> On Tue, Feb 28, 2017 at 07:15:47PM +0100, Peter Zijlstra wrote:
> > (And we should not be returning to userspace with locks held anyway --
> > lockdep already has a check for that).
> 
> Don't we return to userspace with page locks held, eg during async
> directio?

Hello,

I think that the check when returning to user with crosslocks held
should be an exception. Don't you think so?

Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
