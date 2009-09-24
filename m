Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A10FF6B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 12:18:43 -0400 (EDT)
Date: Thu, 24 Sep 2009 17:18:44 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] ksm: change default values to better fit into mainline
 kernel
In-Reply-To: <4ABB99FE.3060105@redhat.com>
Message-ID: <Pine.LNX.4.64.0909241715260.19324@sister.anvils>
References: <1253736347-3779-1-git-send-email-ieidus@redhat.com>
 <Pine.LNX.4.64.0909241644110.16561@sister.anvils> <4ABB99FE.3060105@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 24 Sep 2009, Izik Eidus wrote:
> On 09/24/2009 06:52 PM, Hugh Dickins wrote:
> > You rather caught me by surprise with this one, Izik: I was thinking
> > more rc7 than rc1 for switching it off;
> 
> I thought that after the merge window -> only fixes can get in, but I guess I
> was wrong...

Linus much prefers new features in rc1, though sometimes allowed in rc2;
from then on it should be mainly bugfixing, yes, but lots of work does
go in then, and tweaks to defaults, additions to documentation, etc,
are perfectly acceptable.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
