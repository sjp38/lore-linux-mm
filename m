Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 640C96B0044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 19:26:13 -0400 (EDT)
Received: by ggeq1 with SMTP id q1so1780603gge.14
        for <linux-mm@kvack.org>; Wed, 21 Mar 2012 16:26:12 -0700 (PDT)
Message-ID: <4F6A6391.1070105@gmail.com>
Date: Wed, 21 Mar 2012 16:26:09 -0700
From: David Daney <ddaney.cavm@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 2/3] thp: add HPAGE_PMD_* definitions for !CONFIG_TRANSPARENT_HUGEPAGE
References: <1331591456-20769-1-git-send-email-n-horiguchi@ah.jp.nec.com>	<1331591456-20769-2-git-send-email-n-horiguchi@ah.jp.nec.com>	<CAP=VYLoGSckJH+2GytZN0V0P3Uuv-PiVneKbFsVb5kQa3kcTCQ@mail.gmail.com> <20120321151900.42234501.akpm@linux-foundation.org> <4F6A57D0.4020406@windriver.com>
In-Reply-To: <4F6A57D0.4020406@windriver.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org

On 03/21/2012 03:36 PM, Paul Gortmaker wrote:
> On 12-03-21 06:19 PM, Andrew Morton wrote:
>> On Wed, 21 Mar 2012 18:07:41 -0400
>> Paul Gortmaker<paul.gortmaker@windriver.com>  wrote:
>>
>>> On Mon, Mar 12, 2012 at 6:30 PM, Naoya Horiguchi
>>> <n-horiguchi@ah.jp.nec.com>  wrote:
>>>> These macros will be used in later patch, where all usage are expected
>>>> to be optimized away without #ifdef CONFIG_TRANSPARENT_HUGEPAGE.
>>>> But to detect unexpected usages, we convert existing BUG() to BUILD_BUG().
>>>
>>> Just a heads up that this showed up in linux-next today as the
>>> cause of a new build failure for an ARM board:
>>
>> Dammit.
>>
>>> http://kisskb.ellerman.id.au/kisskb/buildresult/5930053/
>>
>> Site is dead.  What was failure, please?
>
> Odd, I just reloaded the above link and it seems alive?
> Anyway here is where it goes off the rails.
>
> mm/pgtable-generic.c: In function 'pmdp_clear_flush_young':
> mm/pgtable-generic.c:76:136: error: call to '__build_bug_failed' declared with attribute error: BUILD_BUG failed
> make[2]: *** [mm/pgtable-generic.o] Error 1
>

This is just another instance of:

https://lkml.org/lkml/2011/12/16/507

There was some discussion in that thread of how it might be fixed.

David Daney


> Build was for ARM, tct_hammer_defconfig
>
> Paul.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
