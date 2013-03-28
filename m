Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 9EB736B0002
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 15:39:24 -0400 (EDT)
Date: Thu, 28 Mar 2013 19:39:01 +0000
From: Ben Hutchings <ben@decadent.org.uk>
Message-ID: <20130328193901.GQ9079@decadent.org.uk>
References: <1364485358-8745-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1364485358-8745-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130328155109.GA13075@kroah.com>
 <1364486669-10tbmvlb-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1364486669-10tbmvlb-mutt-n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/2] hugetlbfs: stop setting VM_DONTDUMP in
 initializing vma(VM_HUGETLB)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Konstantin Khlebnikov <khlebnikov@openvz.org>

On Thu, Mar 28, 2013 at 12:04:29PM -0400, Naoya Horiguchi wrote:
[...]
> I guess you mean this patch violates one/both of these rules:
> 
>  - It must fix a problem that causes a build error (but not for things
>    marked CONFIG_BROKEN), an oops, a hang, data corruption, a real
>    security issue, or some "oh, that's not good" issue.  In short, something
>    critical.
>  - It or an equivalent fix must already exist in Linus' tree (upstream).
> 
> I'm not sure if the problem "we can't get any hugepage in coredump"
> is considered as 'some "oh, that's not good" issue'.
> But yes, it's not a critical one.
> If you mean I violated the second rule, sorry, I'll get it into upstream first.
 
The second rule is the clear one.  If you are submitting a patch to
a subsystem maintainer and you want it to go into stable branches as
well, you must put 'Cc: stable@vger.kernel.org' in the commit message,
not just the mail header.

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
