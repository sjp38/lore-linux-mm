Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 2DE066B0096
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 16:22:41 -0400 (EDT)
Received: by mail-da0-f54.google.com with SMTP id s35so3100774dak.13
        for <linux-mm@kvack.org>; Mon, 29 Apr 2013 13:22:40 -0700 (PDT)
Date: Mon, 29 Apr 2013 13:22:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 0/2] mm: Promote huge_pmd_share from x86 to mm.
In-Reply-To: <1367247356-11246-1-git-send-email-steve.capper@linaro.org>
Message-ID: <alpine.DEB.2.02.1304291321070.29766@chino.kir.corp.google.com>
References: <1367247356-11246-1-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>

On Mon, 29 Apr 2013, Steve Capper wrote:

> Under x86, multiple puds can be made to reference the same bank of
> huge pmds provided that they represent a full PUD_SIZE of shared
> huge memory that is aligned to a PUD_SIZE boundary.
> 
> The code to share pmds does not require any architecture specific
> knowledge other than the fact that pmds can be indexed, thus can
> be beneficial to some other architectures.
> 
> This RFC promotes the huge_pmd_share code (and dependencies) from
> x86 to mm to make it accessible to other architectures.
> 
> I am working on ARM64 support for huge pages and rather than
> duplicate the x86 huge_pmd_share code, I thought it would be better
> to promote it to mm.
> 

No objections to this, but I think you should do it as the first patch in 
a series that adds the arm support.  There's no need for this to be moved 
until that support is tested, proposed, reviewed, and merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
