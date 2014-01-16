Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id C42C96B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 19:32:33 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md12so1884270pbc.30
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 16:32:33 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id j5si5222554pbs.121.2014.01.15.16.32.32
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 16:32:32 -0800 (PST)
Date: Wed, 15 Jan 2014 16:32:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/11 v4] update page table walker
Message-Id: <20140115163230.fdf99574f0e1b0cf97d5cf07@linux-foundation.org>
In-Reply-To: <1389632051-25159-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1389632051-25159-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

On Mon, 13 Jan 2014 11:54:00 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> This is ver.4 of page table walker patchset.
> I rebased it onto mmotm-2014-01-09-16-23, refactored, and commented more.
> Changes since ver.3 are only on 1/11 and 2/11.

Looks good to me.

Patch [1/11] breaks the build ("mm/pagewalk.c:201: error: 'hmask'
undeclared") and [10/11] fixes that up.

Please resend everything after 3.14-rc1?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
