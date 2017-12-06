Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9C66B030C
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 20:51:13 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id a12so30470pll.21
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 17:51:13 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id u2si994917pge.188.2017.12.05.17.51.11
        for <linux-mm@kvack.org>;
        Tue, 05 Dec 2017 17:51:12 -0800 (PST)
Date: Wed, 6 Dec 2017 12:51:08 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v4 00/73] XArray version 4
Message-ID: <20171206015108.GB4094@dastard>
References: <20171206004159.3755-1-willy@infradead.org>
 <20171206014536.GA4094@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171206014536.GA4094@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Dec 06, 2017 at 12:45:49PM +1100, Dave Chinner wrote:
> On Tue, Dec 05, 2017 at 04:40:46PM -0800, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > I looked through some notes and decided this was version 4 of the XArray.
> > Last posted two weeks ago, this version includes a *lot* of changes.
> > I'd like to thank Dave Chinner for his feedback, encouragement and
> > distracting ideas for improvement, which I'll get to once this is merged.
> 
> BTW, you need to fix the "To:" line on your patchbombs:
> 
> > To: unlisted-recipients: ;, no To-header on input <@gmail-pop.l.google.com> 
> 
> This bad email address getting quoted to the cc line makes some MTAs
> very unhappy.
> 
> > 
> > Highlights:
> >  - Over 2000 words of documentation in patch 8!  And lots more kernel-doc.
> >  - The page cache is now fully converted to the XArray.
> >  - Many more tests in the test-suite.
> > 
> > This patch set is not for applying.  0day is still reporting problems,
> > and I'd feel bad for eating someone's data.  These patches apply on top
> > of a set of prepatory patches which just aren't interesting.  If you
> > want to see the patches applied to a tree, I suggest pulling my git tree:
> > http://git.infradead.org/users/willy/linux-dax.git/shortlog/refs/heads/xarray-2017-12-04
> > I also left out the idr_preload removals.  They're still in the git tree,
> > but I'm not looking for feedback on them.
> 
> I'll give this a quick burn this afternoon and see what catches fire...

Build warnings/errors:

.....
lib/radix-tree.c:700:13: warning: ?radix_tree_free_nodes? defined but not used [-Wunused-function]
 static void radix_tree_free_nodes(struct radix_tree_node *node)
.....
lib/xarray.c: In function ?xas_max?:
lib/xarray.c:291:16: warning: unused variable ?mask?
[-Wunused-variable]
  unsigned long mask, max = xas->xa_index;
                  ^~~~
......
fs/dax.c: In function ?grab_mapping_entry?:
fs/dax.c:305:2: error: implicit declaration of function ?xas_set_order?; did you mean ?xas_set_err??  [-Werror=implicit-function-declaration]
  xas_set_order(&xas, index, size_flag ? PMD_ORDER : 0);
    ^~~~~~~~~~~~~
scripts/Makefile.build:310: recipe for target 'fs/dax.o' failed
make[1]: *** [fs/dax.o] Error 1

-Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
