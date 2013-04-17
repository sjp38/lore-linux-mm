Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 73BC96B0089
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 09:58:27 -0400 (EDT)
Date: Wed, 17 Apr 2013 09:58:18 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1366207098-f00491sj-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1365779583-o4ykbecv-mutt-n-horiguchi@ah.jp.nec.com>
References: <51662D5B.3050001@hitachi.com>
 <20130411134915.GH16732@two.firstfloor.org>
 <1365693788-djsd2ymu-mutt-n-horiguchi@ah.jp.nec.com>
 <20130411181004.GK16732@two.firstfloor.org>
 <51680E63.3070100@hitachi.com>
 <1365779583-o4ykbecv-mutt-n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC Patch 0/2] mm: Add parameters to make kernel behavior at
 memory error on dirty cache selectable
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mitsuhiro Tanino <mitsuhiro.tanino.gm@hitachi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Fri, Apr 12, 2013 at 11:13:03AM -0400, Naoya Horiguchi wrote:
...
> > So my proposal is as follows,
> >   For short term solution to care both memory error and I/O error:
> >     - I will resend a panic knob to handle data lost related to dirty cache
> >       which is caused by memory error and I/O error.
> 
> Sorry, I still think "panic on dirty pagecache error" is feasible in userspace.
> This new knob will be completely useless after memory error reporting is
> fixed in the future, so whenever possible I like the userspace solution
> even for a short term one.

My apology, you mentioned both memory error and I/O error.
So I guess that in your next post, a new sysctl knob will be implemented
around filemap_fdatawait_range() to make kernel panic immediately
if a process finds the AS_EIO set.
It's also effective for the processes which poorly handle EIO, so can
be useful even after the error reporting is fixed in the future.

Anyway, my previous comment is pointless, so ignore it.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
