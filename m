Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id ABB876B0047
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 10:02:18 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] Fix for hugetlb-add-map_hugetlb-for-mmaping-pseudo-anonymous-huge-page-regions.patch in -mm
Date: Tue, 9 Feb 2010 16:01:27 +0100
References: <1252487811-9205-1-git-send-email-ebmunson@us.ibm.com> <Pine.LNX.4.64.0909152146470.25625@sister.anvils> <20100208145605.5eea30b5.randy.dunlap@oracle.com>
In-Reply-To: <20100208145605.5eea30b5.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201002091601.28463.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Eric B Munson <ebmunson@us.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com
List-ID: <linux-mm.kvack.org>

On Monday 08 February 2010, Randy Dunlap wrote:
> On Tue, 15 Sep 2009 21:53:12 +0100 (BST) Hugh Dickins wrote:
> 
> > On Tue, 15 Sep 2009, Eric B Munson wrote:
> > > Resending because this seems to have fallen between the cracks.
> > 
> > Yes, indeed.  I think it isn't quite what Arnd was suggesting, but I
> > agree with you that we might as well go for 0x080000 (so that even Alpha
> > can be just a cut-and-paste job from asm-generic), and right now it's
> > more important to finalize the number than what file it appears in.
> > 
> > Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> 
> so what happened with this patch ??

In a later revision, we agreed to put the definition into
asm-generic/mman.h, where it was merged in 2.6.32.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
