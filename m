Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id F2EE56B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 05:57:06 -0400 (EDT)
Received: by wetk59 with SMTP id k59so27784725wet.3
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 02:57:06 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id uo8si6246926wjc.43.2015.03.18.02.57.04
        for <linux-mm@kvack.org>;
        Wed, 18 Mar 2015 02:57:05 -0700 (PDT)
Date: Wed, 18 Mar 2015 11:57:02 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH RFC] mm: protect suid binaries against rowhammer with
 copy-on-read mappings
Message-ID: <20150318095702.GA2479@node.dhcp.inet.fi>
References: <20150318083040.7838.76933.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150318083040.7838.76933.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>

On Wed, Mar 18, 2015 at 11:30:40AM +0300, Konstantin Khlebnikov wrote:
> From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> 
> Each user gets private copy of the code thus nobody will be able to exploit
> pages in the page cache. This works for statically-linked binaries. Shared
> libraries are still vulnerable, but setting suid bit will protect them too.

Hm. Do we have suid/sgid semantic defiend for non-executables?

To me we should do this for all file private mappings of the suid process
or don't do it at all.

And what about forked suid process which dropped privilages. We still have
code pages shared.

I don't think it worth it. The only right way to fix the problem is ECC
memory.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
