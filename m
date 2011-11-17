Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C1C376B0069
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 04:54:23 -0500 (EST)
Date: Thu, 17 Nov 2011 10:54:16 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] mm: cleanup the comment for head/tail pages of compound
 pages in mm/page_alloc.c
In-Reply-To: <20111117082148.GA30544@tiehlicka.suse.cz>
Message-ID: <alpine.LNX.2.00.1111171054050.15187@pobox.suse.cz>
References: <4EC21D78.4080508@gmail.com> <20111115132409.GA7551@tiehlicka.suse.cz> <4EC2FE33.7030905@gmail.com> <20111117082148.GA30544@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Wang Sheng-Hui <shhuiw@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 17 Nov 2011, Michal Hocko wrote:

> [CCing trivial tree]
> 
> Unquoted patch at https://lkml.org/lkml/2011/11/15/402
> 
> On Wed 16-11-11 08:05:07, Wang Sheng-Hui wrote:
> [...]
> > Thanks, Michal.
> > 
> > New patch generated.
> > 
> > 
> > [PATCH] mm: cleanup the comment for head/tail pages of compound pages in mm/page_alloc.c
> > 
> > Only tail pages point at the head page using their ->first_page fields.
> > 
> > Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
> 
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

Applied, thanks.

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
