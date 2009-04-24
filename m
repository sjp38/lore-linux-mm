Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C02BB6B0047
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 03:32:48 -0400 (EDT)
In-reply-to: <E1LxFd4-0008Ih-Rd@pomaz-ex.szeredi.hu> (message from Miklos
	Szeredi on Fri, 24 Apr 2009 09:15:22 +0200)
Subject: Re: Why doesn't zap_pte_range() call page_mkwrite()
References: <1240510668.11148.40.camel@heimdal.trondhjem.org>
	 <E1Lx4yU-0007A8-Gl@pomaz-ex.szeredi.hu> <1240519320.5602.9.camel@heimdal.trondhjem.org> <E1LxFd4-0008Ih-Rd@pomaz-ex.szeredi.hu>
Message-Id: <E1LxFuD-0008M9-1a@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 24 Apr 2009 09:33:05 +0200
Sender: owner-linux-mm@kvack.org
To: trond.myklebust@fys.uio.no
Cc: miklos@szeredi.hu, npiggin@suse.de, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 Apr 2009, Miklos Szeredi wrote:
> Hmm, I guess this is a bit nasty: the VM promises filesystems that
> ->page_mkwrite() will be called when the page is dirtied through a
> mapping, _almost_ all of the time.  Except when munmap happens to race
> with clear_page_dirty_for_io().
> 
> I don't have any ideas how this could be fixed, CC-ing linux-mm...

On second thought, we could possibly just ignore the dirty bit in that
case.  Trying to write to a mapping _during_ munmap() will have pretty
undefined results, I don't think any sane application out there should
rely on the results of this.

But how knows, the world is a weird place...

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
