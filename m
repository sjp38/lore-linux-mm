Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 61F0C8D0040
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 07:11:54 -0400 (EDT)
Received: by vws4 with SMTP id 4so7358919vws.14
        for <linux-mm@kvack.org>; Tue, 12 Apr 2011 04:11:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTinLdWB+ON=TY=KHyzsrC8gC5bXg7Q@mail.gmail.com>
References: <20110412151116.B50D.A69D9226@jp.fujitsu.com>
	<20110411233358.dd400e59.akpm@linux-foundation.org>
	<20110412161315.B518.A69D9226@jp.fujitsu.com>
	<BANLkTinLdWB+ON=TY=KHyzsrC8gC5bXg7Q@mail.gmail.com>
Date: Tue, 12 Apr 2011 14:11:52 +0300
Message-ID: <BANLkTikjcws6c9hK7WdyrDT_+ss6EfLr0g@mail.gmail.com>
Subject: Re: mm: convert vma->vm_flags to 64bit
From: Alexey Dobriyan <adobriyan@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>, Russell King <linux@arm.linux.org.uk>

On Tue, Apr 12, 2011 at 2:06 PM, Alexey Dobriyan <adobriyan@gmail.com> wrote:
> On Tue, Apr 12, 2011 at 10:12 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
>> After next year? All developers don't have to ignore compiler warnings!
>
> At least add vm_flags_t which is sparse-checked, just like we do with gfp_t.

Or even vma_flags_t.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
