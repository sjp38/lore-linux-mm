Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 932016B0253
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 04:45:57 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 22so6973075wrb.7
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 01:45:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e13si100667wra.456.2017.10.04.01.45.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Oct 2017 01:45:56 -0700 (PDT)
Date: Wed, 4 Oct 2017 10:45:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v9 06/12] mm: zero struct pages during initialization
Message-ID: <20171004084554.fhxpmywtovs5umnm@dhcp22.suse.cz>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-7-pasha.tatashin@oracle.com>
 <20171003130857.vohli6lnqj4tdmhl@dhcp22.suse.cz>
 <73ea1215-7aa2-39e1-b820-30f58119183e@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <73ea1215-7aa2-39e1-b820-30f58119183e@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, mark.rutland@arm.com, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, steven.sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On Tue 03-10-17 11:22:35, Pasha Tatashin wrote:
> 
> 
> On 10/03/2017 09:08 AM, Michal Hocko wrote:
> > On Wed 20-09-17 16:17:08, Pavel Tatashin wrote:
> > > Add struct page zeroing as a part of initialization of other fields in
> > > __init_single_page().
> > > 
> > > This single thread performance collected on: Intel(R) Xeon(R) CPU E7-8895
> > > v3 @ 2.60GHz with 1T of memory (268400646 pages in 8 nodes):
> > > 
> > >                          BASE            FIX
> > > sparse_init     11.244671836s   0.007199623s
> > > zone_sizes_init  4.879775891s   8.355182299s
> > >                    --------------------------
> > > Total           16.124447727s   8.362381922s
> > 
> > Hmm, this is confusing. This assumes that sparse_init doesn't zero pages
> > anymore, right? So these number depend on the last patch in the series?
> 
> Correct, without the last patch sparse_init time won't change.

THen this is just misleading.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
