Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8A9C86B005D
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 06:27:22 -0400 (EDT)
Date: Wed, 17 Jun 2009 12:28:10 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 01/11] ext3: Get rid of extenddisksize parameter of ext3_get_blocks_handle()
Message-ID: <20090617102810.GA29931@wotan.suse.de>
References: <1245088797-29533-1-git-send-email-jack@suse.cz> <1245088797-29533-2-git-send-email-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1245088797-29533-2-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 07:59:48PM +0200, Jan Kara wrote:
> Get rid of extenddisksize parameter of ext3_get_blocks_handle(). This seems to
> be a relict from some old days and setting disksize in this function does not
> make much sence. Currently it was set only by ext3_getblk().  Since the
> parameter has some effect only if create == 1, it is easy to check that the
> three callers which end up calling ext3_getblk() with create == 1 (ext3_append,
> ext3_quota_write, ext3_mkdir) do the right thing and set disksize themselves.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>

I guess something like this should just go in this merge window if
ext3 developers are happy with it? There is no real reason to keep
it with the main patchset is there?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
