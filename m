Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 2A9F06B005A
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 17:15:12 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 0/3 v2] HWPOISON: improve dirty pagecache error reporting
Date: Wed, 22 Aug 2012 17:14:54 -0400
Message-Id: <1345670094-13610-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <m2obm27k37.fsf@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>, Al Viro <viro@ZenIV.linux.org.uk>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 22, 2012 at 01:22:36PM -0700, Andi Kleen wrote:
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
> 
> > Hi,
> >
> > Based on the previous discussion, in this version I propose only error
> > reporting fix ("overwrite recovery" is sparated out from this series.)
> >
> > I think Fengguang's patch (patch 2 in this series) has a corner case
> > about inode cache drop, so I added patch 3 for it.
> 
> New patchkit looks very reasonable to me.

OK, thanks.

> I haven't gone through all the corner cases the inode pinning may
> have though. You probably want an review from Al Viro on this.

Yes. Al, can I have your review on patch 3 in this series?
https://lkml.org/lkml/2012/8/22/400

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
