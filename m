Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 73FC96B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 09:27:56 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id k104so1429635wrc.19
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 06:27:56 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j53sor1219908ede.4.2017.12.13.06.27.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 06:27:55 -0800 (PST)
Date: Wed, 13 Dec 2017 17:27:53 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH 1/3] mm, numa: rework do_pages_move
Message-ID: <20171213142753.uny2nrpzc6gteon6@node.shutemov.name>
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-2-mhocko@kernel.org>
 <20171213120733.umeb7rylswl7chi5@node.shutemov.name>
 <20171213121703.GD25185@dhcp22.suse.cz>
 <20171213124731.hmg4r5m3efybgjtx@node.shutemov.name>
 <20171213141039.GL25185@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171213141039.GL25185@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 13, 2017 at 03:10:39PM +0100, Michal Hocko wrote:
> On Wed 13-12-17 15:47:31, Kirill A. Shutemov wrote:
> > On Wed, Dec 13, 2017 at 01:17:03PM +0100, Michal Hocko wrote:
> > > On Wed 13-12-17 15:07:33, Kirill A. Shutemov wrote:
> > > [...]
> > > > The approach looks fine to me.
> > > > 
> > > > But patch is rather large and hard to review. And how git mixed add/remove
> > > > lines doesn't help too. Any chance to split it up further?
> > > 
> > > I was trying to do that but this is a drop in replacement so it is quite
> > > hard to do in smaller pieces. I've already put the allocation callback
> > > cleanup into a separate one but this is about all that I figured how to
> > > split. If you have any suggestions I am willing to try them out.
> > 
> > "git diff --patience" seems generate more readable output for the patch.
> 
> Hmm, I wasn't aware of this option. Are you suggesting I should use it
> to general the patch to send?

I don't know if it's better in general (it's not default after all), but it
seems helps for this particular case.

> 
> > > > One nitpick: I don't think 'chunk' terminology should go away with the
> > > > patch.
> > > 
> > > Not sure what you mean here. I have kept chunk_start, chunk_node, so I
> > > am not really changing that terminology
> > 
> > We don't really have chunks anymore, right? We still *may* have per-node
> > batching, but..
> > 
> > Maybe just 'start' and 'current_node'?
> 
> Ohh, I've read your response that you want to preserve the naming. I can
> certainly do the rename.

Yep, that's better.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
