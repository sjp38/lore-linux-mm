Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id E33C66B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 05:14:02 -0400 (EDT)
Received: by yhrr66 with SMTP id r66so332696yhr.3
        for <linux-mm@kvack.org>; Tue, 12 May 2015 02:14:02 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id o6si8107710yke.67.2015.05.12.02.14.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 02:14:01 -0700 (PDT)
Date: Tue, 12 May 2015 12:13:49 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: mm: memory-hotplug: enable memory hotplug to handle hugepage
Message-ID: <20150512091349.GO16501@mwanda>
References: <20150511111748.GA20660@mwanda>
 <20150511235443.GA8513@hori1.linux.bs1.fc.nec.co.jp>
 <20150512084339.GN16501@mwanda>
 <20150512090454.GD3068@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150512090454.GD3068@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, May 12, 2015 at 02:04:55AM -0700, Naoya Horiguchi wrote:
> On Tue, May 12, 2015 at 11:43:39AM +0300, Dan Carpenter wrote:
> > On Mon, May 11, 2015 at 11:54:44PM +0000, Naoya Horiguchi wrote:
> > > @@ -1086,7 +1086,8 @@ static void dissolve_free_huge_page(struct page *page)
> > >   */
> > >  void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
> > >  {
> > > -	unsigned int order = 8 * sizeof(void *);
> > > +	/* Initialized to "high enough" value which is capped later */
> > > +	unsigned int order = 8 * sizeof(void *) - 1;
> > 
> > Why not use UINT_MAX?  It's more clear that it's not valid that way.
> 
> It's OK if code checker doesn't show "too much right shift" warning.

It's a comlicated question to answer but with the new VM_BUG_ON() then
it won't warn.

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
