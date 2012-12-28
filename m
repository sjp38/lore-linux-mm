Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 195096B0062
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 17:21:00 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id rl6so6247114pac.15
        for <linux-mm@kvack.org>; Fri, 28 Dec 2012 14:20:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzaQqe4YEqfJVxwUPW8RyrwZKGzQz6ieFKO_UU=yrnPVA@mail.gmail.com>
References: <1356714442-27028-1-git-send-email-cdall@cs.columbia.edu>
	<CA+55aFzaQqe4YEqfJVxwUPW8RyrwZKGzQz6ieFKO_UU=yrnPVA@mail.gmail.com>
Date: Fri, 28 Dec 2012 17:20:58 -0500
Message-ID: <CAEDV+gJV+90jUQgc5iEotUXMVhx5PYv8zWsUHzKFLpj-8uxQ5A@mail.gmail.com>
Subject: Re: [PATCH] mm: Fix PageHead when !CONFIG_PAGEFLAGS_EXTENDED
From: Christoffer Dall <cdall@cs.columbia.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Steve Capper <steve.capper@arm.com>, Will Deacon <will.deacon@arm.com>, Andrea Arcangeli <arcange@redhat.com>

On Fri, Dec 28, 2012 at 5:01 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Fri, Dec 28, 2012 at 9:07 AM,  <c.dall@virtualopensystems.com> wrote:
>> From: Christoffer Dall <cdall@cs.columbia.edu>
>>
>> Unfortunately with !CONFIG_PAGEFLAGS_EXTENDED, (!PageHead) is false, and
>> (PageHead) is true, for tail pages.  This breaks cache cleaning on some
>> ARM systems, and may cause other bugs.
>
> So this already got committed earlier as commit ad4b3fb7ff99 ("mm: Fix
> PageHead when !CONFIG_PAGEFLAGS_EXTENDED")
>
>                     Linus

Sorry about the noise then, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
