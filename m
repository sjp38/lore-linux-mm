Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3B3DC6B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 13:46:26 -0400 (EDT)
Date: Wed, 6 May 2009 19:47:05 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/6] ksm: change the KSM_REMOVE_MEMORY_REGION ioctl.
Message-ID: <20090506174705.GB16078@random.random>
References: <1241475935-21162-3-git-send-email-ieidus@redhat.com> <1241475935-21162-4-git-send-email-ieidus@redhat.com> <4A00DF9B.1080501@redhat.com> <4A014C7B.9080702@redhat.com> <Pine.LNX.4.64.0905061110470.3519@blonde.anvils> <20090506133434.GX16078@random.random> <4A019719.7030504@redhat.com> <Pine.LNX.4.64.0905061739540.5934@blonde.anvils> <20090506164945.GD15712@x200.localdomain> <Pine.LNX.4.64.0905061754250.7350@blonde.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0905061754250.7350@blonde.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Chris Wright <chrisw@redhat.com>, Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Wed, May 06, 2009 at 05:57:14PM +0100, Hugh Dickins wrote:
> No need to decide today anyway: let's see how others feel.

It guess is decided today, the length of this thread is enough
regardless of its content. To me madvise looks overdesign but then I'm
also sure KSM is here to stay and it'll soon swap too, so I think it's
no problem at all, if part of it is always present in the VM
core. KSM=N must stay for embedded. Not sure if it worth to keep
KSM=M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
