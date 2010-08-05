Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5A6A96B02A9
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 07:02:29 -0400 (EDT)
Date: Thu, 5 Aug 2010 20:57:26 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: scalability investigation: Where can I get your latest patches?
Message-ID: <20100805105726.GB5683@amd>
References: <1278579387.2096.889.camel@ymzhang.sh.intel.com>
 <20100720031201.GC21274@amd>
 <1280883843.2125.20.camel@ymzhang.sh.intel.com>
 <F4DF93C7785E2549970341072BC32CD78D8FC01B@irsmsx503.ger.corp.intel.com>
 <1280908717.2125.33.camel@ymzhang.sh.intel.com>
 <F4DF93C7785E2549970341072BC32CD78D8FC0CC@irsmsx503.ger.corp.intel.com>
 <1280911823.2125.35.camel@ymzhang.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1280911823.2125.35.camel@ymzhang.sh.intel.com>
Sender: owner-linux-mm@kvack.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: "Kleen, Andi" <andi.kleen@intel.com>, Nick Piggin <npiggin@suse.de>, "Shi, Alex" <alex.shi@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 04, 2010 at 04:50:23PM +0800, Zhang, Yanmin wrote:
> On Wed, 2010-08-04 at 09:06 +0100, Kleen, Andi wrote:
> > > > I believe the latest version of Nick's patchkit has a likely fix for
> > > that.
> > > >
> > > > http://git.kernel.org/?p=linux/kernel/git/npiggin/linux-
> > > npiggin.git;a=commitdiff;h=9edd35f9aeafc8a5e1688b84cf4488a94898ca45
> > > 
> > > Thanks Andi. The patch has no ext3 part.
> > 
> > Good point. But perhaps the ext2 patch can be adapted. The ACL code
> > should be similar in ext2 and ext3 (and 4)
> I ported ext2 part to ext3. aim7 testing on Nehalem EX 4 socket machine
> shows the regression disappears.

Thanks, this looks fine I'll port several more of the popular
filesystems over asap.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
