Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B847AC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 15:10:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CCAF20674
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 15:10:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ua+qEoKR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CCAF20674
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E4F706B026B; Tue,  3 Sep 2019 11:10:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCF166B026C; Tue,  3 Sep 2019 11:10:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBC8D6B026D; Tue,  3 Sep 2019 11:10:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0195.hostedemail.com [216.40.44.195])
	by kanga.kvack.org (Postfix) with ESMTP id A93166B026B
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 11:10:21 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 5515A180AD801
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 15:10:21 +0000 (UTC)
X-FDA: 75893945442.08.ice32_3d4118489ff53
X-HE-Tag: ice32_3d4118489ff53
X-Filterd-Recvd-Size: 4419
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 15:10:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=kMYjLPkGWlldvgkaEMtVa8ofXfOGNI4Vt2JfjkgF+V8=; b=ua+qEoKR5NGKobxrhyfObMiaz
	28qJVK5Cmtj469tUpUMjB5lIhBAeCh8YKXRWmBqvQ4pA4q2geWOc7hwsuuLD8+20ifshN6X4mmUS8
	dnku9KimzBjhNU+wOPyckNP9v2fCKVt0JqP6dfPr2Iy2wR6+wKii5AXoHWgk31haG0tSLeZ9E705l
	OgK0SqS7wfjf5NjzHOsFVLkmeE914uKAhFYNYTgaxuyEY7xR1vymBvwcopjWnk96vWdEiuI0IbOp7
	HGt1Xj+QSm5q/t4M5uq0KOhEsWQL/MElDbumvXJxhbLoV4Mop2RQClRXXx2FzsZes+pqT9yHt9vfO
	O3Dtop/1A==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i5ARj-0008Bn-Vp; Tue, 03 Sep 2019 15:10:15 +0000
Date: Tue, 3 Sep 2019 08:10:15 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: William Kucharski <william.kucharski@oracle.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Song Liu <songliubraving@fb.com>,
	Bob Kasten <robert.a.kasten@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Chad Mynhier <chad.mynhier@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Johannes Weiner <jweiner@fb.com>
Subject: Re: [PATCH v5 2/2] mm,thp: Add experimental config option
 RO_EXEC_FILEMAP_HUGE_FAULT_THP
Message-ID: <20190903151015.GF29434@bombadil.infradead.org>
References: <20190902092341.26712-1-william.kucharski@oracle.com>
 <20190902092341.26712-3-william.kucharski@oracle.com>
 <20190903121424.GT14028@dhcp22.suse.cz>
 <20190903122208.GE29434@bombadil.infradead.org>
 <20190903125150.GW14028@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190903125150.GW14028@dhcp22.suse.cz>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 03, 2019 at 02:51:50PM +0200, Michal Hocko wrote:
> On Tue 03-09-19 05:22:08, Matthew Wilcox wrote:
> > On Tue, Sep 03, 2019 at 02:14:24PM +0200, Michal Hocko wrote:
> > > On Mon 02-09-19 03:23:41, William Kucharski wrote:
> > > > Add filemap_huge_fault() to attempt to satisfy page
> > > > faults on memory-mapped read-only text pages using THP when possible.
> > > 
> > > This deserves much more description of how the thing is implemented and
> > > expected to work. For one thing it is not really clear to me why you
> > > need CONFIG_RO_EXEC_FILEMAP_HUGE_FAULT_THP at all. You need a support
> > > from the filesystem anyway. So who is going to enable/disable this
> > > config?
> > 
> > There are definitely situations in which enabling this code will crash
> > the kernel.  But we want to get filesystems to a point where they can
> > start working on their support for large pages.  So our workaround is
> > to try to get the core pieces merged under a CONFIG_I_KNOW_WHAT_IM_DOING
> > flag and let people play with it.  Then continue to work on the core
> > to eliminate those places that are broken.
> 
> I am not sure I understand. Each fs has to opt in to the feature
> anyway. If it doesn't then there should be no risk of regression, right?
> I do not expect any fs would rush an implementation in while not being
> sure about the correctness. So how exactly does a config option help
> here.

Filesystems won't see large pages unless they've opted into them.
But there's a huge amount of page-cache work that needs to get done
before this can be enabled by default.  For example, truncate() won't
work properly.

Rather than try to do all the page cache work upfront, then wait for the
filesystems to catch up, we want to get some basics merged.  Since we've
been talking about this for so long without any movement in the kernel
towards actual support, this felt like a good way to go.

We could, of course, develop the entire thing out of tree, but that's
likely to lead to pain and anguish.


