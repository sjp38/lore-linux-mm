Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 35DBA6B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 16:35:00 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/3] mm: print out information of file affected by memory error
Date: Thu, 25 Oct 2012 16:34:49 -0400
Message-Id: <1351197289-13946-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20121025193249.GC3262@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi.kleen@intel.com>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Akira Fujita <a-fujita@rs.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org

Hi Jan,

Thank you for taking time for the review.

On Thu, Oct 25, 2012 at 09:32:49PM +0200, Jan Kara wrote:
> On Thu 25-10-12 11:12:47, Naoya Horiguchi wrote:
> > Printing out the information about which file can be affected by a
> > memory error in generic_error_remove_page() is helpful for user to
> > estimate the impact of the error.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  mm/truncate.c | 8 +++++++-
> >  1 file changed, 7 insertions(+), 1 deletion(-)
> > 
> > diff --git v3.7-rc2.orig/mm/truncate.c v3.7-rc2/mm/truncate.c
> > index d51ce92..df0c6ab7 100644
> > --- v3.7-rc2.orig/mm/truncate.c
> > +++ v3.7-rc2/mm/truncate.c
> > @@ -151,14 +151,20 @@ int truncate_inode_page(struct address_space *mapping, struct page *page)
> >   */
> >  int generic_error_remove_page(struct address_space *mapping, struct page *page)
> >  {
> > +	int ret;
> > +	struct inode *inode = mapping->host;
> > +
>   This will oops if mapping == NULL. Currently the only caller seems to
> check beforehand but still, it's better keep the code as robust as it it.

OK. Adding a comment about it will be helpful for that purpose.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
