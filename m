Date: Tue, 20 Jan 2004 10:36:49 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.1-mm5
Message-Id: <20040120103649.6b4ae959.akpm@osdl.org>
In-Reply-To: <20040120183020.GD23765@srv-lnx2600.matchmail.com>
References: <20040120000535.7fb8e683.akpm@osdl.org>
	<20040120183020.GD23765@srv-lnx2600.matchmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Fedyk <mfedyk@matchmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mike Fedyk <mfedyk@matchmail.com> wrote:
>
> What do these patches do?

Trivial stuff.

> > -ext2_new_inode-cleanup.patch

Use a local variable rather than reevaluating EXT2_SB() all over the place.

> > -ext2-s_next_generation-fix.patch
> > -ext3-s_next_generation-fix.patch

Initialisation and locking fixes for EXTx_SB()->s_next_generation.

> > -ext3-journal-mode-fix.patch

Correctly handle ext3's `chattr +j'


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
