Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94689C04AAA
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 13:00:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D7172087F
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 13:00:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D7172087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE8536B000A; Fri,  3 May 2019 09:00:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E97BE6B000C; Fri,  3 May 2019 09:00:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D60A86B000D; Fri,  3 May 2019 09:00:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 86D4B6B000A
	for <linux-mm@kvack.org>; Fri,  3 May 2019 09:00:34 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z5so3694731edz.3
        for <linux-mm@kvack.org>; Fri, 03 May 2019 06:00:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=7JDqtrySAW6usgsqeRsDuiEzWJJXOn9TnzTEMRr2A8o=;
        b=hdbDpcNyP8rrIISpAIEUpDHgxf+n8MvhgLGt+qrG4ae6D+ZjirSCyHwHFEWkvITMqW
         VdrQHwSYcoDx9rYYgAiift2gO7tSdwha32vPJJEkxGoOPcvgpoth8ZGFsNdtg+CynnWz
         fMT/Tnm+dwc/DwgyNlbW7f50UNSy0u3zNWhDcAVuTz/3vMXfxc8lNxrzWS3YBWry7IFk
         yWjhM2mRSj+MyNV+Ne0Jtfv9FKZIMxyxz2OpUFOow2YOJ075z5anGf5hDmICut84U8gk
         iMyb6bgEjkuxb2kxEqGNXUsde/w6Qgm3vxos3n4IrrfZCq1jdfcMsgSexode7r5Ep5bj
         LIZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWJhzIHSz0rpJn+/N5CZXYKV+HLNStroZF9GGrozWZ5lGOXnWIq
	rbtmoxVm1s536OUThwNYdjLV8M7U4ipYqwoKEd57qi/wKQZB2Yx2QYSrz/df09RZq6J87oInnEb
	nqta1GTSEP0sCKBrJw4jKgzsDhlbbm8yhks5mvaYUbfoU6Ji9ZKvHLGWPYVGBol9zIA==
X-Received: by 2002:a50:b835:: with SMTP id j50mr8055414ede.63.1556888433794;
        Fri, 03 May 2019 06:00:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTx7L0kpDVsTgpAJNSkBv+YjIWkNFmfB3Iz5msZdnCmIh/yDJdGpDJnSS7zBV/82nijEh3
X-Received: by 2002:a50:b835:: with SMTP id j50mr8055302ede.63.1556888433059;
        Fri, 03 May 2019 06:00:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556888433; cv=none;
        d=google.com; s=arc-20160816;
        b=KPn4ki7cdh8mRrzSNJAWEpRCVKpIXajRoOkaNcZRMIwhU0bJy5tFCRfzfLRtHB+CD3
         TeKWCyp1iFU/5RO2ImmYf/8VK1wk8apbjUoov+DSeGuArAeMJJLIC+Ww3fijLzpDC7CO
         ZrEjo4jdwCpxf+AoWbMk76tLTo9w6c36BkNl47AVUc4ExXx+IaYgl2MLSVWKV/RM55EQ
         UyY/OLangQyAdp40gLds01DGfCozx4rXnrezqSaMv70ILOjAUslAnXKR96HZ++IS2FlM
         EeZ2ySmJhGwlmvjRMCKtV+tgJ5j2B1J8wunkMHT89NcBLrDGzCYxdhdFRqHWz3u+xhis
         yRrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=7JDqtrySAW6usgsqeRsDuiEzWJJXOn9TnzTEMRr2A8o=;
        b=evhqAdragecNAMZ3s/+qJOQPoh84zz2ffZClnwhwThuw0JrJR4cZXiVNKPlvJ9qrc/
         qolamuhMpkRhRqQfHJ4dB+qsvaz1iJbfFdeMpdK33cfniEyENL3ivVjCBMJuNRhkpH2t
         cEpLPBbRTE9QcKmqt7kwCnaGx44PrCz0Y1azIZAilSlpnN6tYR2e+1h75ed4GNJqcQPp
         WuLylgQTQMa0S3Oe+Qr76tPjt+HFp+Sc8LOyL2L6jefX5E/UmBQD5Y2p81PsOlMl/7oO
         9XJzae8wEZ7k0iY4tl7KUIbx7MsaOMRMCwECoG0Jc1QdNH096QaOQ32odV0lSepmqVcW
         JCbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gw3si1232948ejb.145.2019.05.03.06.00.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 May 2019 06:00:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 317A5AE63;
	Fri,  3 May 2019 13:00:32 +0000 (UTC)
Date: Fri, 3 May 2019 15:00:29 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Robin Murphy <robin.murphy@arm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	linux-mm <linux-mm@kvack.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Hildenbrand <david@redhat.com>
Subject: Re: [PATCH v6 02/12] mm/sparsemem: Introduce common definitions for
 the size and mask of a section
Message-ID: <20190503130023.GA22564@linux>
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552634586.2015392.2662168839054356692.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CA+CK2bCkqLc82G2MW+rYrKTi4KafC+tLCASkaT8zRfVJCCe8HQ@mail.gmail.com>
 <CAPcyv4g+KNu=upejy7Xm=jWR0cdhygPAdSRbkfFGpJeHFGc4+w@mail.gmail.com>
 <bd76cb2f-7cdc-f11b-11ec-285862db66f3@arm.com>
 <CA+CK2bBS5Csz0O9sDVwt_NjtrBtLaMfkycjhaOmR7mXoKJ5XEg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+CK2bBS5Csz0O9sDVwt_NjtrBtLaMfkycjhaOmR7mXoKJ5XEg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 03, 2019 at 08:57:09AM -0400, Pavel Tatashin wrote:
> On Fri, May 3, 2019 at 6:35 AM Robin Murphy <robin.murphy@arm.com> wrote:
> >
> > On 03/05/2019 01:41, Dan Williams wrote:
> > > On Thu, May 2, 2019 at 7:53 AM Pavel Tatashin <pasha.tatashin@soleen.com> wrote:
> > >>
> > >> On Wed, Apr 17, 2019 at 2:52 PM Dan Williams <dan.j.williams@intel.com> wrote:
> > >>>
> > >>> Up-level the local section size and mask from kernel/memremap.c to
> > >>> global definitions.  These will be used by the new sub-section hotplug
> > >>> support.
> > >>>
> > >>> Cc: Michal Hocko <mhocko@suse.com>
> > >>> Cc: Vlastimil Babka <vbabka@suse.cz>
> > >>> Cc: Jérôme Glisse <jglisse@redhat.com>
> > >>> Cc: Logan Gunthorpe <logang@deltatee.com>
> > >>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > >>
> > >> Should be dropped from this series as it has been replaced by a very
> > >> similar patch in the mainline:
> > >>
> > >> 7c697d7fb5cb14ef60e2b687333ba3efb74f73da
> > >>   mm/memremap: Rename and consolidate SECTION_SIZE
> > >
> > > I saw that patch fly by and acked it, but I have not seen it picked up
> > > anywhere. I grabbed latest -linus and -next, but don't see that
> > > commit.
> > >
> > > $ git show 7c697d7fb5cb14ef60e2b687333ba3efb74f73da
> > > fatal: bad object 7c697d7fb5cb14ef60e2b687333ba3efb74f73da
> >
> > Yeah, I don't recognise that ID either, nor have I had any notifications
> > that Andrew's picked up anything of mine yet :/
> 
> Sorry for the confusion. I thought I checked in a master branch, but
> turns out I checked in a branch where I applied arm hotremove patches
> and Robin's patch as well. These two patches are essentially the same,
> so which one goes first the other should be dropped.
> 
> Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>

Hey Pavel,

just a friendly note :-) :

you are reviewing v6, I think you might want to review v7 [1] instead ;-)?

[1] https://patchwork.kernel.org/cover/10926035/
 

-- 
Oscar Salvador
SUSE L3

