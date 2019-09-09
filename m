Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DABC3C4740C
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:01:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFA2E2086D
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:01:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFA2E2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47A306B0005; Mon,  9 Sep 2019 14:01:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 429F66B0006; Mon,  9 Sep 2019 14:01:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 318666B0007; Mon,  9 Sep 2019 14:01:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0156.hostedemail.com [216.40.44.156])
	by kanga.kvack.org (Postfix) with ESMTP id 1448B6B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 14:01:08 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id B0FB9BEF6
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:01:07 +0000 (UTC)
X-FDA: 75916148574.18.head25_9c1db613b53e
X-HE-Tag: head25_9c1db613b53e
X-Filterd-Recvd-Size: 3583
Received: from mga14.intel.com (mga14.intel.com [192.55.52.115])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:01:06 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Sep 2019 11:01:05 -0700
X-IronPort-AV: E=Sophos;i="5.64,486,1559545200"; 
   d="scan'208";a="196273339"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga002-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Sep 2019 11:01:05 -0700
Message-ID: <cca53aa628a25ead13a2f71060b56bde66e19d05.camel@linux.intel.com>
Subject: Re: [PATCH v9 3/8] mm: Move set/get_pcppage_migratetype to mmzone.h
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Alexander Duyck
	 <alexander.duyck@gmail.com>
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, mst@redhat.com, 
 catalin.marinas@arm.com, david@redhat.com, dave.hansen@intel.com, 
 linux-kernel@vger.kernel.org, willy@infradead.org, mhocko@kernel.org, 
 linux-mm@kvack.org, akpm@linux-foundation.org, will@kernel.org, 
 linux-arm-kernel@lists.infradead.org, osalvador@suse.de,
 yang.zhang.wz@gmail.com,  pagupta@redhat.com, konrad.wilk@oracle.com,
 nitesh@redhat.com, riel@surriel.com,  lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com,  ying.huang@intel.com,
 pbonzini@redhat.com, dan.j.williams@intel.com,  fengguang.wu@intel.com,
 kirill.shutemov@linux.intel.com
Date: Mon, 09 Sep 2019 11:01:04 -0700
In-Reply-To: <20190909095608.jwachx3womhqmjbl@box>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
	 <20190907172528.10910.37051.stgit@localhost.localdomain>
	 <20190909095608.jwachx3womhqmjbl@box>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-09-09 at 12:56 +0300, Kirill A. Shutemov wrote:
> On Sat, Sep 07, 2019 at 10:25:28AM -0700, Alexander Duyck wrote:
> > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > In order to support page reporting it will be necessary to store and
> > retrieve the migratetype of a page. To enable that I am moving the set and
> > get operations for pcppage_migratetype into the mm/internal.h header so
> > that they can be used outside of the page_alloc.c file.
> > 
> > Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
> I'm not sure that it's great idea to export this functionality beyond
> mm/page_alloc.c without any additional safeguards. How would we avoid to
> messing with ->index when the page is not in the right state of its
> life-cycle. Can we add some VM_BUG_ON()s here?

I am not sure what we would need to check on though. There are essentially
2 cases where we are using this. The first is the percpu page lists so the
value is set either as a result of __rmqueue_smallest or
free_unref_page_prepare. The second one which hasn't been added yet is for
the Reported pages case which I add with patch 6.

When I use it for page reporting I am essentially using the Reported flag
to identify what pages in the buddy list will have this value set versus
those that may not. I didn't explicitly define it that way, but that is
how I am using it so that the value cannot be trusted unless the Reported
flag is set.


