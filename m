Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 5C1C96B004D
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 17:01:08 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so3827049vbk.14
        for <linux-mm@kvack.org>; Fri, 27 Jul 2012 14:01:07 -0700 (PDT)
Date: Fri, 27 Jul 2012 16:59:36 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH 0/4] promote zcache from staging
Message-ID: <20120727205932.GA12650@localhost.localdomain>
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <b95aec06-5a10-4f83-bdfd-e7f6adabd9df@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b95aec06-5a10-4f83-bdfd-e7f6adabd9df@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Fri, Jul 27, 2012 at 12:21:50PM -0700, Dan Magenheimer wrote:
> > From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> > Subject: [PATCH 0/4] promote zcache from staging
> > 
> > zcache is the remaining piece of code required to support in-kernel
> > memory compression.  The other two features, cleancache and frontswap,
> > have been promoted to mainline in 3.0 and 3.5.  This patchset
> > promotes zcache from the staging tree to mainline.
> > 
> > Based on the level of activity and contributions we're seeing from a
> > diverse set of people and interests, I think zcache has matured to the
> > point where it makes sense to promote this out of staging.
> 
> Hi Seth --
> 
> Per offline communication, I'd like to see this delayed for three
> reasons:
> 
> 1) I've completely rewritten zcache and will post the rewrite soon.
>    The redesigned code fixes many of the weaknesses in zcache that
>    makes it (IMHO) unsuitable for an enterprise distro.  (Some of
>    these previously discussed in linux-mm [1].)
> 2) zcache is truly mm (memory management) code and the fact that
>    it is in drivers at all was purely for logistical reasons
>    (e.g. the only in-tree "staging" is in the drivers directory).
>    My rewrite promotes it to (a subdirectory of) mm where IMHO it
>    belongs.
> 3) Ramster heavily duplicates code from zcache.  My rewrite resolves
>    this.  My soon-to-be-post also places the re-factored ramster
>    in mm, though with some minor work zcache could go in mm and
>    ramster could stay in staging.
> 
> Let's have this discussion, but unless the community decides
> otherwise, please consider this a NACK.

Hold on, that is rather unfair. The zcache has been in staging
for quite some time - your code has not been posted. Part of
"unstaging" a driver is for folks to review the code - and you
just said "No, mine is better" without showing your goods.

There is a third option - which is to continue the promotion
of zcache from staging, get reviews, work on them ,etc, and
alongside of that you can work on fixing up (or ripping out)
zcache1 with zcache2 components as they make sense. Or even
having two of them - an enterprise and an embedded version
that will eventually get merged together. There is nothing
wrong with modifying a driver once it has left staging.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
