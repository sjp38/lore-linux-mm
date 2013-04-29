Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 6ABE96B00A2
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 18:10:28 -0400 (EDT)
Date: Mon, 29 Apr 2013 23:10:35 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC PATCH 0/2] mm: Promote huge_pmd_share from x86 to mm.
Message-ID: <20130429221034.GA49470@MacBook-Pro.local>
References: <1367247356-11246-1-git-send-email-steve.capper@linaro.org>
 <alpine.DEB.2.02.1304291321070.29766@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1304291321070.29766@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Steve Capper <steve.capper@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <Will.Deacon@arm.com>

On Mon, Apr 29, 2013 at 09:22:38PM +0100, David Rientjes wrote:
> On Mon, 29 Apr 2013, Steve Capper wrote:
> 
> > Under x86, multiple puds can be made to reference the same bank of
> > huge pmds provided that they represent a full PUD_SIZE of shared
> > huge memory that is aligned to a PUD_SIZE boundary.
> > 
> > The code to share pmds does not require any architecture specific
> > knowledge other than the fact that pmds can be indexed, thus can
> > be beneficial to some other architectures.
> > 
> > This RFC promotes the huge_pmd_share code (and dependencies) from
> > x86 to mm to make it accessible to other architectures.
> > 
> > I am working on ARM64 support for huge pages and rather than
> > duplicate the x86 huge_pmd_share code, I thought it would be better
> > to promote it to mm.
> 
> No objections to this, but I think you should do it as the first patch in 
> a series that adds the arm support.  There's no need for this to be moved 
> until that support is tested, proposed, reviewed, and merged.

I agree, it would be good to see the arm64 support in this series as
well (though eventual upstreaming may go via separate paths).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
