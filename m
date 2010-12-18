Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0E86B009A
	for <linux-mm@kvack.org>; Fri, 17 Dec 2010 19:29:33 -0500 (EST)
Message-ID: <4D0C0043.7090408@oracle.com>
Date: Fri, 17 Dec 2010 16:28:51 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: mmotm 2010-12-16-14-56 uploaded (hugetlb)
References: <201012162329.oBGNTdPY006808@imap1.linux-foundation.org> <20101217143316.fa36be7d.randy.dunlap@oracle.com> <20101217145334.3d67d80b.akpm@linux-foundation.org> <20101217233740.GR1671@random.random>
In-Reply-To: <20101217233740.GR1671@random.random>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 12/17/10 15:37, Andrea Arcangeli wrote:
> Hello,
> 
> On Fri, Dec 17, 2010 at 02:53:34PM -0800, Andrew Morton wrote:
>> afacit, CONFIG_HUGETLBFS must be enabled if CONFIG_HUGETLB_PAGE=y, and
>> thp-config_transparent_hugepage.patch broke that, by permitting
>> CONFIG_HUGETLBFS=n, CONFIG_HUGETLB_PAGE=y,
>> CONFIG_TRANSPARENT_HUGEPAGE=y.
> 
> CONFIG_HUGETLBFS and CONFIG_HUGETLB_PAGE existed before, and
> HUGETLBFS=n && HUGETLB_PAGE=y used to build just fine, I clearly
> didn't try a build with HUGETLBFS=n recently.
> 
>> There's lots of stuff in hugetlb.h which is clearly related to
>> hugetlbfs, but is enabled by CONFIG_HUGETLB_PAGE, so those things seem
>> to be pretty joined at the hip nowadays.
> 
> Yes, it used to build just fine but I guess after the last hugetlbfs
> updates I'm getting flood of errors no matter how I adjust things.
> hugetlbfs code who needs some fixup here.

I see a real *flood* of errors when I try building ARCH=um SUBARCH={i386|x86_64}:

> grep -c error: UM*/build*
UM32/build-defcfg.out:454539
UM64/build-defcfg.out:453707


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
