Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id 51DDC6B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 19:47:18 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id d10so812029eaj.9
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 16:47:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id f2si9775516eeo.112.2014.01.15.16.47.16
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 16:47:17 -0800 (PST)
Date: Wed, 15 Jan 2014 19:46:58 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1389833218-jf8gq9bo-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20140115163230.fdf99574f0e1b0cf97d5cf07@linux-foundation.org>
References: <1389632051-25159-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140115163230.fdf99574f0e1b0cf97d5cf07@linux-foundation.org>
Subject: Re: [PATCH 00/11 v4] update page table walker
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

On Wed, Jan 15, 2014 at 04:32:30PM -0800, Andrew Morton wrote:
> On Mon, 13 Jan 2014 11:54:00 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > This is ver.4 of page table walker patchset.
> > I rebased it onto mmotm-2014-01-09-16-23, refactored, and commented more.
> > Changes since ver.3 are only on 1/11 and 2/11.
> 
> Looks good to me.

Thanks for the review.

> Patch [1/11] breaks the build ("mm/pagewalk.c:201: error: 'hmask'
> undeclared") and [10/11] fixes that up.
> 
> Please resend everything after 3.14-rc1?

Sure, I'll do with fixing the build warning.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
