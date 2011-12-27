Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 048686B004F
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 08:21:19 -0500 (EST)
Received: by wibhq12 with SMTP id hq12so6873310wib.14
        for <linux-mm@kvack.org>; Tue, 27 Dec 2011 05:21:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111227125945.GH5344@tiehlicka.suse.cz>
References: <CAJd=RBCXTp0GrMGw+MBDdj0K15+L5v+O2t6EcDghFk34aNwt1g@mail.gmail.com>
	<20111227125945.GH5344@tiehlicka.suse.cz>
Date: Tue, 27 Dec 2011 21:21:18 +0800
Message-ID: <CAJd=RBA70k8pCoP26hoJua=h1DHgx7eLHU0qrukJRxwoaxB65Q@mail.gmail.com>
Subject: Re: [PATCH] mm: hugetlb: add might_sleep() for gigantic page
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, Dec 27, 2011 at 8:59 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Fri 23-12-11 21:41:08, Hillf Danton wrote:
>> From: Hillf Danton <dhillf@gmail.com>
>> Subject: [PATCH] mm: hugetlb: add might_sleep() for gigantic page
>>
>> Like the case of huge page, might_sleep() is added for gigantic page, then
>> both are treated in same way.
>
> Why do we need to call might_sleep here? There is cond_resched in the
> loop...
>

IIUC it is the reason to add... and the comment says

/**
 * might_sleep - annotation for functions that can sleep
 *
 * this macro will print a stack trace if it is executed in an atomic
 * context (spinlock, irq-handler, ...).
 *
 * This is a useful debugging help to be able to catch problems early and not
 * be bitten later when the calling function happens to sleep when it is not
 * supposed to.
 */

Thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
