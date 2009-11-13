Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C9B426B006A
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 06:50:33 -0500 (EST)
Date: Fri, 13 Nov 2009 12:50:26 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/6] mm: mlocking in try_to_unmap_one
Message-ID: <20091113115026.GU21482@random.random>
References: <Pine.LNX.4.64.0911111048170.12126@sister.anvils>
 <20091113143930.33BF.A69D9226@jp.fujitsu.com>
 <20091113172453.33CB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091113172453.33CB.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 13, 2009 at 05:26:14PM +0900, KOSAKI Motohiro wrote:
> Probably we can remove VM_NONLINEAR perfectly. I've never seen real user of it.

Do you mean as a whole or in the mlock logic? databases are using
remap_file_pages on 32bit archs to avoid generating zillon of vmas on
tmpfs scattered mappings. On 64bits it could only be useful to some
emulators but with real shadow paging and nonlinear rmap already
created on shadow pagetables, it looks pretty useless on 64bit archs
to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
