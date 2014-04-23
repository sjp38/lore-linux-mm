Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 34AFD6B0037
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 18:18:24 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id up15so1230421pbc.20
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 15:18:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id va2si1382481pac.227.2014.04.23.15.18.22
        for <linux-mm@kvack.org>;
        Wed, 23 Apr 2014 15:18:23 -0700 (PDT)
Date: Wed, 23 Apr 2014 15:18:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2014-04-22-15-20 uploaded (uml 32- and 64-bit defconfigs)
Message-Id: <20140423151819.d752391e323a850ca0aded57@linux-foundation.org>
In-Reply-To: <20140424081019.596b5d23c624f5721ba0480a@canb.auug.org.au>
References: <20140422222121.2FAB45A431E@corp2gmr1-2.hot.corp.google.com>
	<5357F405.20205@infradead.org>
	<20140423134131.778f0d0a@redhat.com>
	<5357FCEB.2060507@infradead.org>
	<20140423141600.4a303d95@redhat.com>
	<20140423112442.5a5c8f23d580a65575e0c5fc@linux-foundation.org>
	<20140424081019.596b5d23c624f5721ba0480a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, nacc@linux.vnet.ibm.com, Richard Weinberger <richard@nod.at>

On Thu, 24 Apr 2014 08:10:19 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Hi all,
> 
> On Wed, 23 Apr 2014 11:24:42 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> >
> > I'll try moving hugepages_supported() into the #ifdef
> > CONFIG_HUGETLB_PAGE section.
> > 
> > --- a/include/linux/hugetlb.h~hugetlb-ensure-hugepage-access-is-denied-if-hugepages-are-not-supported-fix-fix
> > +++ a/include/linux/hugetlb.h
> > @@ -412,6 +412,16 @@ static inline spinlock_t *huge_pte_lockp
> >  	return &mm->page_table_lock;
> >  }
> >  
> > +static inline bool hugepages_supported(void)
> > +{
> > +	/*
> > +	 * Some platform decide whether they support huge pages at boot
> > +	 * time. On these, such as powerpc, HPAGE_SHIFT is set to 0 when
> > +	 * there is no such support
> > +	 */
> > +	return HPAGE_SHIFT != 0;
> > +}
> > +
> >  #else	/* CONFIG_HUGETLB_PAGE */
> >  struct hstate {};
> >  #define alloc_huge_page_node(h, nid) NULL
> > @@ -460,14 +470,4 @@ static inline spinlock_t *huge_pte_lock(
> >  	return ptl;
> >  }
> >  
> > -static inline bool hugepages_supported(void)
> > -{
> > -	/*
> > -	 * Some platform decide whether they support huge pages at boot
> > -	 * time. On these, such as powerpc, HPAGE_SHIFT is set to 0 when
> > -	 * there is no such support
> > -	 */
> > -	return HPAGE_SHIFT != 0;
> > -}
> > -
> >  #endif /* _LINUX_HUGETLB_H */
> 
> Clearly, noone reads my emails :-(
> 

Stephen who?

Oh, that guy who sends stuff first then comes last when others use LIFO :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
