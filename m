Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 06D026B0044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 18:36:10 -0400 (EDT)
Message-ID: <4F6A57D0.4020406@windriver.com>
Date: Wed, 21 Mar 2012 18:36:00 -0400
From: Paul Gortmaker <paul.gortmaker@windriver.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 2/3] thp: add HPAGE_PMD_* definitions for !CONFIG_TRANSPARENT_HUGEPAGE
References: <1331591456-20769-1-git-send-email-n-horiguchi@ah.jp.nec.com>	<1331591456-20769-2-git-send-email-n-horiguchi@ah.jp.nec.com>	<CAP=VYLoGSckJH+2GytZN0V0P3Uuv-PiVneKbFsVb5kQa3kcTCQ@mail.gmail.com> <20120321151900.42234501.akpm@linux-foundation.org>
In-Reply-To: <20120321151900.42234501.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org

On 12-03-21 06:19 PM, Andrew Morton wrote:
> On Wed, 21 Mar 2012 18:07:41 -0400
> Paul Gortmaker <paul.gortmaker@windriver.com> wrote:
> 
>> On Mon, Mar 12, 2012 at 6:30 PM, Naoya Horiguchi
>> <n-horiguchi@ah.jp.nec.com> wrote:
>>> These macros will be used in later patch, where all usage are expected
>>> to be optimized away without #ifdef CONFIG_TRANSPARENT_HUGEPAGE.
>>> But to detect unexpected usages, we convert existing BUG() to BUILD_BUG().
>>
>> Just a heads up that this showed up in linux-next today as the
>> cause of a new build failure for an ARM board:
> 
> Dammit.
> 
>> http://kisskb.ellerman.id.au/kisskb/buildresult/5930053/
> 
> Site is dead.  What was failure, please?

Odd, I just reloaded the above link and it seems alive?
Anyway here is where it goes off the rails.

mm/pgtable-generic.c: In function 'pmdp_clear_flush_young':
mm/pgtable-generic.c:76:136: error: call to '__build_bug_failed' declared with attribute error: BUILD_BUG failed
make[2]: *** [mm/pgtable-generic.o] Error 1

Build was for ARM, tct_hammer_defconfig

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
