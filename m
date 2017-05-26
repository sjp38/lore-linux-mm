Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E4AF6B02B4
	for <linux-mm@kvack.org>; Fri, 26 May 2017 12:23:36 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c6so18700023pfj.5
        for <linux-mm@kvack.org>; Fri, 26 May 2017 09:23:36 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t78si1310254pfi.321.2017.05.26.09.23.35
        for <linux-mm@kvack.org>;
        Fri, 26 May 2017 09:23:35 -0700 (PDT)
Date: Fri, 26 May 2017 17:23:30 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2 2/3] mm: kmemleak: Factor object reference updating
 out of scan_block()
Message-ID: <20170526162329.GD30853@e104818-lin.cambridge.arm.com>
References: <1495726937-23557-1-git-send-email-catalin.marinas@arm.com>
 <1495726937-23557-3-git-send-email-catalin.marinas@arm.com>
 <20170526160916.ptlc2huao3bn4qwq@hermes.olymp>
 <20170526162107.GC30853@e104818-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170526162107.GC30853@e104818-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luis Henriques <lhenriques@suse.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Andy Lutomirski <luto@amacapital.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, May 26, 2017 at 05:21:08PM +0100, Catalin Marinas wrote:
> On Fri, May 26, 2017 at 05:09:17PM +0100, Luis Henriques wrote:
> > On Thu, May 25, 2017 at 04:42:16PM +0100, Catalin Marinas wrote:
> > > The scan_block() function updates the number of references (pointers) to
> > > objects, adding them to the gray_list when object->min_count is reached.
> > > The patch factors out this functionality into a separate update_refs()
> > > function.
> > > 
> > > Cc: Michal Hocko <mhocko@kernel.org>
> > > Cc: Andy Lutomirski <luto@amacapital.net>
> > > Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
> > > Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
[...]
> > FWIW, I've tested this patchset and I don't see kmemleak triggering the
> > false positives anymore.
> 
> Thanks for re-testing (I dropped your tested-by from the initial patch
> since I made a small modification).

Sorry, the "re-testing" comment was meant at the other Luis on cc ;)
(Luis R. Rodriguez). It's been a long day...

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
