Date: Tue, 20 Jan 2004 10:30:20 -0800
From: Mike Fedyk <mfedyk@matchmail.com>
Subject: Re: 2.6.1-mm5
Message-ID: <20040120183020.GD23765@srv-lnx2600.matchmail.com>
References: <20040120000535.7fb8e683.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040120000535.7fb8e683.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 20, 2004 at 12:05:35AM -0800, Andrew Morton wrote:
> -ext2_new_inode-cleanup.patch
> -ext2-s_next_generation-fix.patch
> -ext3-s_next_generation-fix.patch
> -ext3-journal-mode-fix.patch

What do these patches do?

> -nfsd-01-stale-filehandles-fixes.patch
>  Merged

Yes!

I tested this against 2.6.1-bk2 on my knfsd server since friday, and it has
fixed my problems with stale nfs handles.  Without the patch, it wouldn't
last a whole day before the errors started cropping up.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
