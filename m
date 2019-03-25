Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C612C10F03
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:47:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 138BA20863
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 16:47:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 138BA20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B90506B0006; Mon, 25 Mar 2019 12:47:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3F986B0007; Mon, 25 Mar 2019 12:47:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A30056B0008; Mon, 25 Mar 2019 12:47:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4CC6B0006
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 12:47:29 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id n5so3253934pgk.9
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 09:47:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vMm1SwFwexRmfe0DhLS1tSZeKphD9ShP6utr7v396Xo=;
        b=aOCeFqb+ZoePm8LA1NzYbU+Zbe0QYbANHsxOLz+bXkp2XOZeDHeXYvSTr1AQjcOucr
         iTUOGZoXzlJFAHPYy+szgPUpHjQgyc8FF6JC1ts68G+s2C/4NfnP/Xo6cEl5YyFFGrJd
         KA5j9AgUg4k8zc1r6V1iP5ixn7mv3CoKeCW7oruJrWNTQkSzOkfCgoixDjmwozNs/Auc
         ypYZgqEvZYL6hqvwf0qU7SLGEsoxrMPinGO/g7kAq1MSpvkqTp0c+Ghta0K4+2LByEKu
         wmYVuDFjDzKfv6bCaiVnuiI1LU7cf33pmpB+O4oP0KZvoWaFathWxD70LjVfjSwRJ4qF
         aCOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVQDWEe7oxyMrFe2Mg6Nvd5URIkx/vaQC9UuZxj01nfve3MHxnu
	sgCcH85W3aH/o9SvNGVh4Uebqo/mPm6EoLtTdgCEn6b/InDIUD4EtOEU6Wnnd46IyEuj1lKat/z
	1PNtc+DytrNkIocF6jes/iI57ov3k3p3JYZej7a9vJcFhdbhS55ZcE4rAE+YLDVpESQ==
X-Received: by 2002:a63:cd06:: with SMTP id i6mr24616068pgg.267.1553532449124;
        Mon, 25 Mar 2019 09:47:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxDfNNyGmX/vDeoYDshb7bhxd46uqPdUIQFa/Cw7p15YongIF3SPa8DdHLcNqXGg42jSwm
X-Received: by 2002:a63:cd06:: with SMTP id i6mr24616000pgg.267.1553532448199;
        Mon, 25 Mar 2019 09:47:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553532448; cv=none;
        d=google.com; s=arc-20160816;
        b=rw76hLCn13pntZmVOnlgBhqNuX2OeeQPHMXo07idJSMIH9ZjPnib6T+lSqUCFWsL/L
         hEEnD8+Yublkv3J+74KZrQ19hhMgiVHMDtPpAAJ3gfR56giZyLXyB2trXt5qTRRrJXsB
         rEYokQI2dyG3CWOCtSdHGXp5Q1FmsClJokDIcCg9/NkIIW51N8V5h5YurSO4COQJ7qu3
         KVh1in/odeqsvEF4jas3VbJoJeoSF7Re02s5mFoeD0PmBL7CgmugacrXT6KQGWUZ2N8m
         TC13sPEEtSbxl/diotXPldfAcJc9zANbdut10i/rthy072O6nrGffO35U5La4d8mpWwF
         EHNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vMm1SwFwexRmfe0DhLS1tSZeKphD9ShP6utr7v396Xo=;
        b=U5HkjJb9kYehWub6Bs6+CJgHwofLaKUmzSEKvDjy8Y+SpuCZlDeKCQbBvqWw4WOoII
         EKC99ij9I2bWgH7d746Rj8AVsaNdvqQhoRJup2T+Y3AtW1odZD/2ivY2hnC/l7oiaqY2
         /jKN62nAYQ4S0nUjZkpQD5NvKH+0jcDiiGFsfezh5BpYG4/q9ORmLagYYb8/bOEUSH+B
         l5h3w+q8R8eUNQ1VCLoic+TF/bVp7sfFkUEBLdNfHA+6SwrmoGkqlGAU4eFFsqbxa4Sj
         SfQjl5dTsn53BkI4FrvkJtazTvNMdYiUIrhfLi+JcsMVOZ58p4WnS2jGeLeTvMIk5sfu
         7PUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id p125si13990491pga.84.2019.03.25.09.47.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 09:47:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Mar 2019 09:47:27 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,269,1549958400"; 
   d="scan'208";a="145091052"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 25 Mar 2019 09:47:25 -0700
Date: Mon, 25 Mar 2019 01:46:14 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Rich Felker <dalias@libc.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>,
	Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-mips@vger.kernel.org,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	linux-s390 <linux-s390@vger.kernel.org>,
	Linux-sh <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: Re: [RESEND 1/7] mm/gup: Replace get_user_pages_longterm() with
 FOLL_LONGTERM
Message-ID: <20190325084614.GE16366@iweiny-DESK2.sc.intel.com>
References: <20190317183438.2057-1-ira.weiny@intel.com>
 <20190317183438.2057-2-ira.weiny@intel.com>
 <CAA9_cmffz1VBOJ0ykBtcj+hiznn-kbbuotu1uUhPiJtXiFjJXg@mail.gmail.com>
 <20190325061941.GA16366@iweiny-DESK2.sc.intel.com>
 <CAPcyv4hPxoX1+u=fjzCeVYOd9Bck9d=A9SQ-mjzeMA2tf9B9dA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hPxoX1+u=fjzCeVYOd9Bck9d=A9SQ-mjzeMA2tf9B9dA@mail.gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 09:45:12AM -0700, Dan Williams wrote:
> On Mon, Mar 25, 2019 at 7:21 AM Ira Weiny <ira.weiny@intel.com> wrote:
> [..]
> > > > @@ -1268,10 +1246,14 @@ static long check_and_migrate_cma_pages(unsigned long start, long nr_pages,
> > > >                                 putback_movable_pages(&cma_page_list);
> > > >                 }
> > > >                 /*
> > > > -                * We did migrate all the pages, Try to get the page references again
> > > > -                * migrating any new CMA pages which we failed to isolate earlier.
> > > > +                * We did migrate all the pages, Try to get the page references
> > > > +                * again migrating any new CMA pages which we failed to isolate
> > > > +                * earlier.
> > > >                  */
> > > > -               nr_pages = get_user_pages(start, nr_pages, gup_flags, pages, vmas);
> > > > +               nr_pages = __get_user_pages_locked(tsk, mm, start, nr_pages,
> > > > +                                                  pages, vmas, NULL,
> > > > +                                                  gup_flags);
> > > > +
> > >
> > > Why did this need to change to __get_user_pages_locked?
> >
> > __get_uer_pages_locked() is now the "internal call" for get_user_pages.
> >
> > Technically it did not _have_ to change but there is no need to call
> > get_user_pages() again because the FOLL_TOUCH flags is already set.  Also this
> > call then matches the __get_user_pages_locked() which was called on the pages
> > we migrated from.  Mostly this keeps the code "symmetrical" in that we called
> > __get_user_pages_locked() on the pages we are migrating from and the same call
> > on the pages we migrated to.
> >
> > While the change here looks funny I think the final code is better.
> 
> Agree, but I think that either needs to be noted in the changelog so
> it's not a surprise, or moved to a follow-on cleanup patch.
> 

Can do...

Thanks!
Ira

