Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id ABCE06B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 17:42:03 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so6772065pab.19
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 14:42:03 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id bq5si16850012pbb.108.2014.02.10.14.42.02
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 14:42:02 -0800 (PST)
Date: Mon, 10 Feb 2014 14:42:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/11 v5] update page table walker
Message-Id: <20140210144201.b237008068e7d4e0f7a5e0a8@linux-foundation.org>
In-Reply-To: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

On Mon, 10 Feb 2014 16:44:25 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> This is ver.5 of page table walker patchset.

   text    data     bss     dec     hex filename
 882373  264146  757256 1903775  1d0c9f mm/built-in.o (before)
 881205  264146  757128 1902479  1d078f mm/built-in.o (after)

That worked.  But it adds 15 lines to mm/*.[ch] ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
