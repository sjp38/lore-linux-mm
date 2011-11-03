Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id B63876B0069
	for <linux-mm@kvack.org>; Thu,  3 Nov 2011 06:18:40 -0400 (EDT)
Date: Thu, 3 Nov 2011 11:18:29 +0100
From: "Roedel, Joerg" <Joerg.Roedel@amd.com>
Subject: Re: [RFC][PATCH 0/3] Add support for non-CPU TLBs in MMU-Notifiers
Message-ID: <20111103101829.GR13244@amd.com>
References: <1319199708-17777-1-git-send-email-joerg.roedel@amd.com>
 <20111102094601.GN28536@sgi.com>
 <20111102095740.GM13244@amd.com>
 <20111103000725.GD18879@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20111103000725.GD18879@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Robin Holt <holt@sgi.com>, Rik van Riel <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "joro@8bytes.org" <joro@8bytes.org>

On Wed, Nov 02, 2011 at 08:07:25PM -0400, Andrea Arcangeli wrote:
> On Wed, Nov 02, 2011 at 10:57:40AM +0100, Roedel, Joerg wrote:
> > I have included this mailing list in my post afaics. I talked with
> > Andrea Arcangeli about these patches at LinuxCon in Prague and will post
> > a new version based on his comments.
> 
> Thanks!
> Andrea
> 
> PS. Luckily I already read your patches before we met :).

Yeah, otherwise we would have done some kind of peer-review ;)


	Joerg

-- 
AMD Operating System Research Center

Advanced Micro Devices GmbH Einsteinring 24 85609 Dornach
General Managers: Alberto Bozzo, Andrew Bowd
Registration: Dornach, Landkr. Muenchen; Registerger. Muenchen, HRB Nr. 43632

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
