Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id D6A226B0062
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 17:01:28 -0500 (EST)
Received: by mail-we0-f170.google.com with SMTP id r1so5343987wey.1
        for <linux-mm@kvack.org>; Fri, 28 Dec 2012 14:01:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1356714442-27028-1-git-send-email-cdall@cs.columbia.edu>
References: <1356714442-27028-1-git-send-email-cdall@cs.columbia.edu>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 28 Dec 2012 14:01:06 -0800
Message-ID: <CA+55aFzaQqe4YEqfJVxwUPW8RyrwZKGzQz6ieFKO_UU=yrnPVA@mail.gmail.com>
Subject: Re: [PATCH] mm: Fix PageHead when !CONFIG_PAGEFLAGS_EXTENDED
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: c.dall@virtualopensystems.com
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Christoffer Dall <cdall@cs.columbia.edu>, Steve Capper <steve.capper@arm.com>, Will Deacon <will.deacon@arm.com>, Andrea Arcangeli <arcange@redhat.com>

On Fri, Dec 28, 2012 at 9:07 AM,  <c.dall@virtualopensystems.com> wrote:
> From: Christoffer Dall <cdall@cs.columbia.edu>
>
> Unfortunately with !CONFIG_PAGEFLAGS_EXTENDED, (!PageHead) is false, and
> (PageHead) is true, for tail pages.  This breaks cache cleaning on some
> ARM systems, and may cause other bugs.

So this already got committed earlier as commit ad4b3fb7ff99 ("mm: Fix
PageHead when !CONFIG_PAGEFLAGS_EXTENDED")

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
