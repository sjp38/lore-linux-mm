Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 6A1456B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 21:43:02 -0400 (EDT)
Date: Fri, 23 Mar 2012 01:42:51 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 00/16] mm: prepare for converting vm->vm_flags to 64-bit
Message-ID: <20120323014251.GH6589@ZenIV.linux.org.uk>
References: <20120321100602.GA5522@barrios>
 <4F69D496.2040509@openvz.org>
 <20120322142647.42395398.akpm@linux-foundation.org>
 <20120322212810.GE6589@ZenIV.linux.org.uk>
 <20120322144122.59d12051.akpm@linux-foundation.org>
 <4F6BA221.8020602@openvz.org>
 <4F6BA69F.1040707@openvz.org>
 <CA+55aFz4hWfT5c93rUWvN4OsYHjOSAjmNtoT7Rkjz7kYsaC7xg@mail.gmail.com>
 <4F6BAD15.90802@openvz.org>
 <20120322160944.ad06e559.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120322160944.ad06e559.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Linus Torvalds <torvalds@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, Christopher Li <sparse@chrisli.org>

On Thu, Mar 22, 2012 at 04:09:44PM -0700, Andrew Morton wrote:

> > Thanks. Looks like "__nocast" totally undocumented.
> > It would be nice to add something about this into Documentation/sparse.txt
> 
> Yup, Chris has added this to his todo list (thanks!).

Alternatively, we could just remove the remaining instances in the kernel -
cputime_t is the only borderline reasonable one there; xfs ones should be
__bitwise and so should zd_addr_t thing (with cpu_to_le16() moved from
uses of those suckers to macro definitions).  Hell knows - I suspect that
cputime_t also might've been turned into __bitwise u64, but I hadn't checked
if we ever do plain arithmetics on those...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
