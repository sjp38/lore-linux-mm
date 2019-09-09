Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 378FBC4740C
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:13:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BF5F218DE
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 18:13:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BF5F218DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 360C26B026F; Mon,  9 Sep 2019 14:12:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C4BE6B0270; Mon,  9 Sep 2019 14:12:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A0506B0271; Mon,  9 Sep 2019 14:12:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0095.hostedemail.com [216.40.44.95])
	by kanga.kvack.org (Postfix) with ESMTP id D43696B026F
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 14:12:46 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 8792F8243762
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:46 +0000 (UTC)
X-FDA: 75916177932.25.food78_6f74594848a25
X-HE-Tag: food78_6f74594848a25
X-Filterd-Recvd-Size: 4246
Received: from mga01.intel.com (mga01.intel.com [192.55.52.88])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 18:12:45 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Sep 2019 11:12:34 -0700
X-IronPort-AV: E=Sophos;i="5.64,486,1559545200"; 
   d="scan'208";a="178428271"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga008-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Sep 2019 11:12:33 -0700
Message-ID: <576de40e00083206bdb0c2e9f04fe34dd406e6b3.camel@linux.intel.com>
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
Date: Mon, 09 Sep 2019 11:12:33 -0700
In-Reply-To: <cca53aa628a25ead13a2f71060b56bde66e19d05.camel@linux.intel.com>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
	 <20190907172528.10910.37051.stgit@localhost.localdomain>
	 <20190909095608.jwachx3womhqmjbl@box>
	 <cca53aa628a25ead13a2f71060b56bde66e19d05.camel@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-09-09 at 11:01 -0700, Alexander Duyck wrote:
> On Mon, 2019-09-09 at 12:56 +0300, Kirill A. Shutemov wrote:
> > On Sat, Sep 07, 2019 at 10:25:28AM -0700, Alexander Duyck wrote:
> > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > 
> > > In order to support page reporting it will be necessary to store and
> > > retrieve the migratetype of a page. To enable that I am moving the set and
> > > get operations for pcppage_migratetype into the mm/internal.h header so
> > > that they can be used outside of the page_alloc.c file.
> > > 
> > > Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> > > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > 
> > I'm not sure that it's great idea to export this functionality beyond
> > mm/page_alloc.c without any additional safeguards. How would we avoid to
> > messing with ->index when the page is not in the right state of its
> > life-cycle. Can we add some VM_BUG_ON()s here?
> 
> I am not sure what we would need to check on though. There are essentially
> 2 cases where we are using this. The first is the percpu page lists so the
> value is set either as a result of __rmqueue_smallest or
> free_unref_page_prepare. The second one which hasn't been added yet is for
> the Reported pages case which I add with patch 6.
> 
> When I use it for page reporting I am essentially using the Reported flag
> to identify what pages in the buddy list will have this value set versus
> those that may not. I didn't explicitly define it that way, but that is
> how I am using it so that the value cannot be trusted unless the Reported
> flag is set.

I guess the alternative would be to just treat the ->index value as the
index within the boundary array, and not use the per-cpu list functions.
Doing that might make things a bit more clear since all we are really
doing is storing the index into the boundary list the page is contained
in. I could probably combine the value of order and migratetype and save
myself a few cycles in the process by just saving the index into the array
directly.


