Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAT6ZNNk028681
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sat, 29 Nov 2008 15:35:23 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BAFE45DE53
	for <linux-mm@kvack.org>; Sat, 29 Nov 2008 15:35:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4761145DE4F
	for <linux-mm@kvack.org>; Sat, 29 Nov 2008 15:35:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C1351DB8040
	for <linux-mm@kvack.org>; Sat, 29 Nov 2008 15:35:23 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D5FC21DB803A
	for <linux-mm@kvack.org>; Sat, 29 Nov 2008 15:35:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 2/2] fs: symlink write_begin allocation context fix
In-Reply-To: <20081128143737.GA15458@wotan.suse.de>
References: <20081127200014.3CF6.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081128143737.GA15458@wotan.suse.de>
Message-Id: <20081129153455.8128.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sat, 29 Nov 2008 15:35:22 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Thu, Nov 27, 2008 at 08:02:32PM +0900, KOSAKI Motohiro wrote:
> > > @@ -2820,8 +2825,7 @@ fail:
> > >  
> > >  int page_symlink(struct inode *inode, const char *symname, int len)
> > >  {
> > > -	return __page_symlink(inode, symname, len,
> > > -			mapping_gfp_mask(inode->i_mapping));
> > > +	return __page_symlink(inode, symname, len, 0);
> > >  }
> > 
> > your patch always pass 0 into __page_symlink().
> > therefore it doesn't change any behavior.
> > 
> > right?
> 
> How about this patch?

looks good to me.
very thanks.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
