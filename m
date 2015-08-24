Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id C9D196B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 04:51:31 -0400 (EDT)
Received: by wijp15 with SMTP id p15so70451431wij.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 01:51:31 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id u9si30772141wjx.196.2015.08.24.01.51.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 01:51:30 -0700 (PDT)
Received: by wijp15 with SMTP id p15so70450608wij.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 01:51:29 -0700 (PDT)
Date: Mon, 24 Aug 2015 10:51:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
Message-ID: <20150824085127.GB17078@dhcp22.suse.cz>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
 <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1440059182-19798-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150820110004.GB4632@dhcp22.suse.cz>
 <20150820233450.GB10807@hori1.linux.bs1.fc.nec.co.jp>
 <20150821065321.GD23723@dhcp22.suse.cz>
 <20150821163033.GA4600@Sligo.logfs.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150821163033.GA4600@Sligo.logfs.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri 21-08-15 09:30:33, Jorn Engel wrote:
> On Fri, Aug 21, 2015 at 08:53:21AM +0200, Michal Hocko wrote:
> > On Thu 20-08-15 23:34:51, Naoya Horiguchi wrote:
> > [...]
> > > > Reading a single file is, of course, easier but is it really worth the
> > > > additional code? I haven't really looked at the patch so I might be
> > > > missing something but what would be an advantage over reading
> > > > /proc/<pid>/smaps and extracting the information from there?
> > > 
> > > My first idea was just "users should feel it useful", but permission as David
> > > commented sounds a good technical reason to me.
> > 
> > 9 files changed, 112 insertions(+), 1 deletion(-)
> > 
> > is quite a lot especially when it touches hot paths like fork so it
> > better should have a good usecase. I have already asked in the other
> > email but is actually anybody requesting this? Nice to have is not
> > a good justification IMO.
> 
> I need some way to judge the real rss of a process, including huge
> pages.  No strong opinion on implementation details, but something is
> clearly needed.

The current implementation makes me worry. Is the per hstate break down
really needed? The implementation would be much more easier without it.

> If you have processes with 99% huge pages, you are currently reduced to
> guesswork.

If you have 99% of hugetlb pages then your load is rather specific and I
would argue that /proc/<pid>/smaps (after patch 1) is a much better way to
get what you want.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
