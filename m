Date: Fri, 22 Oct 2004 18:19:33 +0200
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: [PATCH] zap_pte_range should not mark non-uptodate pages dirty
Message-ID: <20041022161933.GG14325@dualathlon.random>
References: <20041022004159.GB14325@dualathlon.random> <Pine.LNX.4.44.0410212250500.13944-100000@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0410212250500.13944-100000@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@osdl.org>, shaggy@austin.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 21, 2004 at 10:51:34PM -0400, Rik van Riel wrote:
> That depends on the filesystem.  I hope the clustered filesystems

I agree if you do a "is_underlying_fs_GFS?" check then you can make more
assumptions.

But if you don't do that, the linux API always left undefined the
mmapped contents after O_DIRECT writes on the mmapped data.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
