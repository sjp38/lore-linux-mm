Date: Thu, 10 Jan 2008 10:45:43 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH][RFC][BUG] updating the ctime and mtime time stamps in
 msync()
Message-ID: <20080110104543.398baf5c@bree.surriel.com>
In-Reply-To: <4df4ef0c0801100253m6c08e4a3t917959c030533f80@mail.gmail.com>
References: <1199728459.26463.11.camel@codedot>
	<20080109155015.4d2d4c1d@cuia.boston.redhat.com>
	<26932.1199912777@turing-police.cc.vt.edu>
	<20080109170633.292644dc@cuia.boston.redhat.com>
	<20080109223340.GH25527@unthought.net>
	<20080109184141.287189b8@bree.surriel.com>
	<4df4ef0c0801091603y2bf507e1q2b99971c6028d1f3@mail.gmail.com>
	<20080110085120.GK25527@unthought.net>
	<4df4ef0c0801100253m6c08e4a3t917959c030533f80@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Salikhmetov <salikhmetov@gmail.com>
Cc: Jakob Oestergaard <jakob@unthought.net>, Valdis.Kletnieks@vt.edu, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 10 Jan 2008 13:53:59 +0300
"Anton Salikhmetov" <salikhmetov@gmail.com> wrote:

> Indeed, if msync() is called with MS_SYNC an explicit sync is
> triggered, and Rik's suggestion would work. However, the POSIX
> standard requires a call to msync() with MS_ASYNC to update the
> st_ctime and st_mtime stamps too. No explicit sync of the inode data
> is triggered in the current implementation of msync(). Hence Rik's
> suggestion would fail to satisfy POSIX in the latter case.

Since your patch is already changing msync(), has it occurred
to you that your patch could change msync() to do the right
thing?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
