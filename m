Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id D0E756B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 17:11:39 -0500 (EST)
Date: Tue, 6 Nov 2012 14:11:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/16] mm: use augmented rbtrees for finding unmapped
 areas
Message-Id: <20121106141137.68bbd4ea.akpm@linux-foundation.org>
In-Reply-To: <1352155633-8648-1-git-send-email-walken@google.com>
References: <1352155633-8648-1-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@tilera.com>, x86@kernel.org, William Irwin <wli@holomorphy.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

On Mon,  5 Nov 2012 14:46:57 -0800
Michel Lespinasse <walken@google.com> wrote:

> Earlier this year, Rik proposed using augmented rbtrees to optimize
> our search for a suitable unmapped area during mmap(). This prompted
> my work on improving the augmented rbtree code. Rik doesn't seem to
> have time to follow up on his idea at this time, so I'm sending this
> series to revive the idea.

Well, the key word here is "optimize".  Some quantitative testing
results would be nice, please!

People do occasionally see nasty meltdowns in the get_unmapped_area()
vicinity.  There was one case 2-3 years ago which was just ghastly, but
I can't find the email (it's on linux-mm somewhere).  This one might be
another case:
http://lkml.indiana.edu/hypermail/linux/kernel/1101.1/00896.html

If you can demonstrate that this patchset fixes some of all of the bad
search complexity scenarios then that's quite a win?

> These changes are against v3.7-rc4. I have not converted all applicable
> architectuers yet, but we don't necessarily need to get them all onboard
> at once - the series is fully bisectable and additional architectures
> can be added later on. I am confident enough in my tests for patches 1-8;
> however the second half of the series basically didn't get tested as
> I don't have access to all the relevant architectures.

Yes, I'll try to get these into -next so that the thousand monkeys at
least give us some compilation coverage testing.  Hopefully the
relevant arch maintainers will find time to perform a runtime test.

> Patch 1 is the validate_mm() fix from Bob Liu (+ fixed-the-fix from me :)

I grabbed this one separately, as a post-3.6 fix.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
