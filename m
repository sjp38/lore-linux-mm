Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id A2B926B002B
	for <linux-mm@kvack.org>; Sat, 13 Oct 2012 11:22:25 -0400 (EDT)
Date: Sat, 13 Oct 2012 17:22:23 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB v4
Message-ID: <20121013152223.GG16230@one.firstfloor.org>
References: <1349999637-8613-1-git-send-email-andi@firstfloor.org> <CAJd=RBByzsGUaOxOoQpu_SN+K5XRxd2PEGhB48CHkuO5qJ5grA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBByzsGUaOxOoQpu_SN+K5XRxd2PEGhB48CHkuO5qJ5grA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

> > -                               struct user_struct **user, int creat_flags);
> > +                               struct user_struct **user, int creat_flags,
> > +                               int page_size_log);
> > +int hugetlb_get_quota(struct address_space *mapping, long delta);
> > +void hugetlb_put_quota(struct address_space *mapping, long delta);
> > +
> > +int hugetlb_get_quota(struct address_space *mapping, long delta);
> > +void hugetlb_put_quota(struct address_space *mapping, long delta);
> 
> 
> For what to add(twice) hugetlb_get/put_quota?

Hmm probably a merge error. Thanks for catching. 

I can repost or post the trivial incremential.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
