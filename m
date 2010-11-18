Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 139016B0089
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 12:39:59 -0500 (EST)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id oAIHdOi3030672
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 09:39:25 -0800
Received: by iwn4 with SMTP id 4so1134393iwn.14
        for <linux-mm@kvack.org>; Thu, 18 Nov 2010 09:39:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101118125249.GN8135@csn.ul.ie>
References: <patchbomb.1288798055@v2.random> <6022613f956ee326d9b6.1288798072@v2.random>
 <20101118125249.GN8135@csn.ul.ie>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 18 Nov 2010 09:32:36 -0800
Message-ID: <AANLkTikhXS9ot27gS9OpRWbU9zjXns_D96DarZ1jOcR6@mail.gmail.com>
Subject: Re: [PATCH 17 of 66] add pmd mangling generic functions
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 4:52 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Wed, Nov 03, 2010 at 04:27:52PM +0100, Andrea Arcangeli wrote:
>> From: Andrea Arcangeli <aarcange@redhat.com>
>>
>> Some are needed to build but not actually used on archs not supporting
>> transparent hugepages. Others like pmdp_clear_flush are used by x86 too.
>>
>> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>> Acked-by: Rik van Riel <riel@redhat.com>
>
> Acked-by: Mel Gorman <mel@csn.ul.ie>

I dunno. Those macros are _way_ too big and heavy to be macros or
inline functions. Why aren't pmdp_splitting_flush() etc just
functions?

There is no performance advantage to inlining them - the TLB flush is
going to be expensive enough that there's no point in avoiding a
function call. And that header file really does end up being _really_
ugly.

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
