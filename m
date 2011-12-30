Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id DF6736B005D
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 23:02:28 -0500 (EST)
Received: by qadc16 with SMTP id c16so10119721qad.14
        for <linux-mm@kvack.org>; Thu, 29 Dec 2011 20:02:28 -0800 (PST)
Message-ID: <4EFD37D1.9040201@gmail.com>
Date: Thu, 29 Dec 2011 23:02:25 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] pagemap: document KPF_THP and make page-types aware
 of it
References: <1324506228-18327-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1324506228-18327-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1324506228-18327-5-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

(12/21/11 5:23 PM), Naoya Horiguchi wrote:
> page-types, which is a common user of pagemap, gets aware of thp
> with this patch. This helps system admins and kernel hackers know
> about how thp works.
> Here is a sample output of page-types over a thp:
> 
>    $ page-types -p<pid>  --raw --list
> 
>    voffset offset  len     flags
>    ...
>    7f9d40200       3f8400  1       ___U_lA____Ma_bH______t____________
>    7f9d40201       3f8401  1ff     ________________T_____t____________
> 
>                 flags      page-count       MB  symbolic-flags                     long-symbolic-flags
>    0x0000000000410000             511        1  ________________T_____t____________        compound_tail,thp
>    0x000000000040d868               1        0  ___U_lA____Ma_bH______t____________        uptodate,lru,active,mmap,anonymous,swapbacked,compound_head,thp
> 
> Signed-off-by: Naoya Horiguchi<n-horiguchi@ah.jp.nec.com>
> Acked-by: Wu Fengguang<fengguang.wu@intel.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
