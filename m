Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id E29546B004A
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 10:03:54 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so1350237vbb.14
        for <linux-mm@kvack.org>; Sat, 31 Mar 2012 07:03:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201203311334.q2VDYGiL005854@farm-0012.internal.tilera.com>
References: <201203302018.q2UKIFH5020745@farm-0012.internal.tilera.com>
	<CAJd=RBCoLNB+iRX1shKGAwSbE8PsZXyk9e3inPTREcm2kk3nXA@mail.gmail.com>
	<201203311334.q2VDYGiL005854@farm-0012.internal.tilera.com>
Date: Sat, 31 Mar 2012 22:03:53 +0800
Message-ID: <CAJd=RBDEAMgDviSwugt7dHKPGXCCF5jQSDtHdXvt5VnSBmK3bA@mail.gmail.com>
Subject: Re: [PATCH v2] arch/tile: support multiple huge page sizes dynamically
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>

On Sat, Mar 31, 2012 at 3:37 AM, Chris Metcalf <cmetcalf@tilera.com> wrote:
>
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> ---
> This change incorporates Hillf Danton's suggestion to not use a
> macro for arch_make_huge_pte() but instead use the standard hugetlb
> model of providing an empty inline function for every other platform.
>
Oh my god.

First my bad, no clear comment provided:(

What I meant actually is to add something in

include/asm-generic/pgtable.h

#ifndef __HAVE_ARCH_FOO_BAR
the_default_foo_bar()
{
}
#endif

or it is too hard to add default foo_bar for each arch involved.

Say sorry again
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
