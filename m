Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7791FC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 18:04:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AA8720820
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 18:04:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AA8720820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC5E96B0003; Wed, 10 Apr 2019 14:04:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C74656B0005; Wed, 10 Apr 2019 14:04:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B68216B0006; Wed, 10 Apr 2019 14:04:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5EF6B0003
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 14:04:25 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e20so2310479pfn.8
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 11:04:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YDrd9Qpwq/SvgfcV8AmwI+eduMlPH4IzdD55lPwhQiE=;
        b=gkZxj0MKsfwKb2bQ0hEWoMLpj22mfM8fqJz9S02f0qtmao15V5LxfFZ270gpnU5AfC
         Ueg2NJ0+SdVGKi2PuvGbpeeBqr2tboqKPe2/SnNZt+x0VtYs1+UBl9C99GTbf1CwY6f3
         mXkyME6naZS37FZ/2tSXXeNNeYzmRXXclmY2bvLiVPErbL4BS84cSRm8qlmXztMy/Cru
         KuI7WpqwX9xfo0e/VX9JwTTDOpHgjVf9rayLntrs8vzluRx52mnNfHlwVMCzGJVnMBvp
         z1QWHsyHAMl1qABDflbZuEyIT7GEQwCIY3aGdaNHlKe4EVqpBB59lWBsAj+IXO2Vsiyb
         Qd+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVJyjTXQekwkFPCxcw/I4BF40nm6MNuW9129la/8oS2xtJNRCzu
	7LPR1sqnIXGvh51VL1Fq+tZEDFanWMldZY/2zZbYV5d+jcZxoSfDVFTEquVOwJZLIJt6JXK/rMW
	kMIutRDPebUWsaBaXwK8Vura3TxMvVLKc2D+B+nkCtocFxDzKJZISaze3YQV3pwlxDw==
X-Received: by 2002:aa7:82d6:: with SMTP id f22mr44927168pfn.190.1554919464912;
        Wed, 10 Apr 2019 11:04:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrbcS9V/twEQkAocb1KqcZOmLWfwK/D4Oofw2XdPQP5ttYxOlhdukIhGgtynZdTD2Q31cw
X-Received: by 2002:aa7:82d6:: with SMTP id f22mr44927058pfn.190.1554919463802;
        Wed, 10 Apr 2019 11:04:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554919463; cv=none;
        d=google.com; s=arc-20160816;
        b=zTn+ZGJhnxW3kPKkqxx+P5IDlYsC/MrUXJFX5G+uxNVvkShKEbnF5r2DvNcAXE2LFX
         AeMkZIkhCHbgUs0nfpVNCkIb9tl6TjAMul+FgtHQmaBqHShEodHDTMjUHL9uuhMVnOKd
         Eb5Z/3B75063yNMg8CJeDEvmmYn5pJ13O+LL+S5rBXpTJQD/jF0JMocq5rzMNBliaUko
         GZTu8mbVqCZZXTDBSfDGMiMi+sBi7XaA4l4jeJ4wMzhu9YjSNdfnzcM1WB3A/vNgZxoP
         EXzCx2U+J3ATg0KN5/jGBsnWbRteJGbgbrilIurqU1kLOLmmP6ujQZkyAxTwAq9wrPjD
         jPqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YDrd9Qpwq/SvgfcV8AmwI+eduMlPH4IzdD55lPwhQiE=;
        b=ARnNh3TXpCsRfRF9b83msCMz5c3lDR542F4liwc3PCOrly5R6+fp7bGn9SpswzRFTS
         3t4OX+h0ioLq9NNVZddgu5v7HxtgdUwf88IkDjzXj8ZsN7dW6dNJV5ueFq5KiNk1xAAM
         HeXG5cn3J7ds5O0v8Cm0kXuAm5FA7q/7YNm+ps4qen8/W2fPjK3HYChuLNOxysZYzcyO
         EWd5E/DEhhzUpgU5zpsNyIc2iDo3NhY4H+ylx847+jPNdtajjPGwDSNaYU4UPp7OuSHH
         x7WPzgTTtq30bt5MjK4AUU5gZKrq/EEwthddjvglZmGxg+xoqNeyBhHGfTGh8q8xabTY
         sQ1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id q20si30333933pgv.6.2019.04.10.11.04.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 11:04:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Apr 2019 11:04:22 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,334,1549958400"; 
   d="scan'208";a="149739907"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 10 Apr 2019 11:04:21 -0700
Date: Wed, 10 Apr 2019 11:04:18 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Huang Shijie <sjhuang@iluvatar.ai>
Cc: Matthew Wilcox <willy@infradead.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"william.kucharski@oracle.com" <william.kucharski@oracle.com>,
	"palmer@sifive.com" <palmer@sifive.com>,
	"axboe@kernel.dk" <axboe@kernel.dk>,
	"keescook@chromium.org" <keescook@chromium.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 1/2] mm/gup.c: fix the wrong comments
Message-ID: <20190410180417.GC22989@iweiny-DESK2.sc.intel.com>
References: <20190408023746.16916-1-sjhuang@iluvatar.ai>
 <20190408141313.GU22763@bombadil.infradead.org>
 <20190409010832.GA28081@hsj-Precision-5520>
 <20190409024929.GW22763@bombadil.infradead.org>
 <20190409030417.GA3324@hsj-Precision-5520>
 <20190409111905.GY22763@bombadil.infradead.org>
 <2807E5FD2F6FDA4886F6618EAC48510E79CA51BA@CRSMSX101.amr.corp.intel.com>
 <20190410012034.GB3640@hsj-Precision-5520>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190410012034.GB3640@hsj-Precision-5520>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2019 at 09:20:36AM +0800, Huang Shijie wrote:
> On Tue, Apr 09, 2019 at 02:55:31PM +0000, Weiny, Ira wrote:
> > > On Tue, Apr 09, 2019 at 11:04:18AM +0800, Huang Shijie wrote:
> > > > On Mon, Apr 08, 2019 at 07:49:29PM -0700, Matthew Wilcox wrote:
> > > > > On Tue, Apr 09, 2019 at 09:08:33AM +0800, Huang Shijie wrote:
> > > > > > On Mon, Apr 08, 2019 at 07:13:13AM -0700, Matthew Wilcox wrote:
> > > > > > > On Mon, Apr 08, 2019 at 10:37:45AM +0800, Huang Shijie wrote:
> > > > > > > > The root cause is that sg_alloc_table_from_pages() requires
> > > > > > > > the page order to keep the same as it used in the user space,
> > > > > > > > but
> > > > > > > > get_user_pages_fast() will mess it up.
> > > > > > >
> > > > > > > I don't understand how get_user_pages_fast() can return the
> > > > > > > pages in a different order in the array from the order they appear in
> > > userspace.
> > > > > > > Can you explain?
> > > > > > Please see the code in gup.c:
> > > > > >
> > > > > > 	int get_user_pages_fast(unsigned long start, int nr_pages,
> > > > > > 				unsigned int gup_flags, struct page **pages)
> > > > > > 	{
> > > > > > 		.......
> > > > > > 		if (gup_fast_permitted(start, nr_pages)) {
> > > > > > 			local_irq_disable();
> > > > > > 			gup_pgd_range(addr, end, gup_flags, pages, &nr);
> > > // The @pages array maybe filled at the first time.
> > > > >
> > > > > Right ... but if it's not filled entirely, it will be filled
> > > > > part-way, and then we stop.
> > > > >
> > > > > > 			local_irq_enable();
> > > > > > 			ret = nr;
> > > > > > 		}
> > > > > > 		.......
> > > > > > 		if (nr < nr_pages) {
> > > > > > 			/* Try to get the remaining pages with
> > > get_user_pages */
> > > > > > 			start += nr << PAGE_SHIFT;
> > > > > > 			pages += nr;                                                  // The
> > > @pages is moved forward.
> > > > >
> > > > > Yes, to the point where gup_pgd_range() stopped.
> > > > >
> > > > > > 			if (gup_flags & FOLL_LONGTERM) {
> > > > > > 				down_read(&current->mm->mmap_sem);
> > > > > > 				ret = __gup_longterm_locked(current,
> > > current->mm,      // The @pages maybe filled at the second time
> > > > >
> > > > > Right.
> > > > >
> > > > > > 				/*
> > > > > > 				 * retain FAULT_FOLL_ALLOW_RETRY
> > > optimization if
> > > > > > 				 * possible
> > > > > > 				 */
> > > > > > 				ret = get_user_pages_unlocked(start,
> > > nr_pages - nr,    // The @pages maybe filled at the second time.
> > > > > > 							      pages, gup_flags);
> > > > >
> > > > > Yes.  But they'll be in the same order.
> > > > >
> > > > > > BTW, I do not know why we mess up the page order. It maybe used in
> > > some special case.
> > > > >
> > > > > I'm not discounting the possibility that you've found a bug.
> > > > > But documenting that a bug exists is not the solution; the solution
> > > > > is fixing the bug.
> > > > I do not think it is a bug :)
> > > >
> > > > If we use the get_user_pages_unlocked(), DMA is okay, such as:
> > > >                      ....
> > > > 		     get_user_pages_unlocked()
> > > > 		     sg_alloc_table_from_pages()
> > > > 	             .....
> > > >
> > > > I think the comment is not accurate enough. So just add more comments,
> > > > and tell the driver users how to use the GUPs.
> > > 
> > > gup_fast() and gup_unlocked() should return the pages in the same order.
> > > If they do not, then it is a bug.
> > 
> > Is there a reproducer for this?  Or do you have some debug output which shows this problem?
> Is Matthew right?
> 
>  " gup_fast() and gup_unlocked() should return the pages in the same order.
>  If they do not, then it is a bug."

Yes I think he is...

Ira

> 
> If Matthew is right,
> I need more time to debug the DMA issue...
> 	
> 
> Thanks
> Huang Shijie
>  
> 
> > 
> > Ira
> > 
> 

