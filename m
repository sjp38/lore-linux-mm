Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1155C8D0001
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 17:25:38 -0500 (EST)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id oAQMOxlo007809
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 14:25:00 -0800
Received: by iwn38 with SMTP id 38so1605692iwn.14
        for <linux-mm@kvack.org>; Fri, 26 Nov 2010 14:24:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101125173518.GR6118@random.random>
References: <patchbomb.1288798055@v2.random> <6022613f956ee326d9b6.1288798072@v2.random>
 <20101118125249.GN8135@csn.ul.ie> <AANLkTikhXS9ot27gS9OpRWbU9zjXns_D96DarZ1jOcR6@mail.gmail.com>
 <20101125173518.GR6118@random.random>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 27 Nov 2010 07:24:37 +0900
Message-ID: <AANLkTinasCexaptMzKkY7CO3SAAUiVvp+W=FAYkk+6+q@mail.gmail.com>
Subject: Re: [PATCH 17 of 66] add pmd mangling generic functions
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 26, 2010 at 2:35 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> On Thu, Nov 18, 2010 at 09:32:36AM -0800, Linus Torvalds wrote:
>> I dunno. Those macros are _way_ too big and heavy to be macros or
>> inline functions. Why aren't pmdp_splitting_flush() etc just
>> functions?
>
> That's because ptep_clear_flush and everything else in that file named
> with ptep_* and doing expensive tlb flushes was a macro.

That may be, and you needn't necessarily clean up old use (although
that might be nice as a separate thing), but I wish we didn't make
what is already messy bigger and messier.

         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
