Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 47E106B0035
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 08:46:42 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id jt11so7259073pbb.22
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 05:46:41 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id eb3si15765303pbd.107.2014.01.13.05.46.40
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 05:46:40 -0800 (PST)
Date: Mon, 13 Jan 2014 21:46:09 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/9] re-shrink 'struct page' when SLUB is on.
Message-ID: <20140113134609.GB31640@localhost>
References: <20140103180147.6566F7C1@viggo.jf.intel.com>
 <20140103141816.20ef2a24c8adffae040e53dc@linux-foundation.org>
 <20140106043237.GE696@lge.com>
 <52D05D90.3060809@sr71.net>
 <20140110153913.844e84755256afd271371493@linux-foundation.org>
 <52D0854F.5060102@sr71.net>
 <CAOJsxLE-oMpV2G-gxrhyv0Au1tPd87Ow57VD5CWFo41wF8F4Yw@mail.gmail.com>
 <alpine.DEB.2.10.1401111854580.6036@nuc>
 <20140113014408.GA25900@lge.com>
 <1389584218.11984.0.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389584218.11984.0.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave@sr71.net>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> > So, I think
> > that it is better to get more benchmark results to this patchset for convincing
> > ourselves. If possible, how about asking Fengguang to run whole set of
> > his benchmarks before going forward?
> 
> Cc'ing him.

My pleasure. Is there a git tree for the patches? Git trees
are most convenient for running automated tests and bisects.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
