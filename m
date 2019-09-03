Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC64BC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 12:22:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BECB2087E
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 12:22:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="sdAJgqyO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BECB2087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28BA96B0003; Tue,  3 Sep 2019 08:22:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23B896B0005; Tue,  3 Sep 2019 08:22:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 104546B0006; Tue,  3 Sep 2019 08:22:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0113.hostedemail.com [216.40.44.113])
	by kanga.kvack.org (Postfix) with ESMTP id E50D46B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 08:22:14 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 85EEC180AD7C3
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 12:22:14 +0000 (UTC)
X-FDA: 75893521788.20.copy35_30a05d9198323
X-HE-Tag: copy35_30a05d9198323
X-Filterd-Recvd-Size: 3750
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf25.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 12:22:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=ccUGFVNxssVWDcbI4ftnmg58MbgKoeWD8Ifd/JsATGA=; b=sdAJgqyOjMVv5fGaTpFicA5RP
	0MALv5u8khHy2K9Yl7P37X5h9KAHJlerdtdvJhnb3lJKI4pzP9dQt487I46HmBIrgC7njktl3YgWa
	SQWOLRQhasxNetbiJq1YJk4ow8C0kTd+vCWMFmUZ6CEBLYUz/expOYSTwdf+ImbTf9OT3sMVRk3t6
	djywTV4fdBXWnWMXlOtU+Cat+AE2NfVI1wgF9MBF2jwWESybVK2yGLv3CBrmVVHgms+SvUPg8M7I3
	iEbvurEHnm0jQ2rV1vxDYUqKxI+1SX8YNQGuHQUesSirCQB4QGmdBwrzX3+BvYyxkIGXP6l3GDVH7
	QA3EPd7bg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i57p2-0006Fn-RW; Tue, 03 Sep 2019 12:22:08 +0000
Date: Tue, 3 Sep 2019 05:22:08 -0700
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
Message-ID: <20190903122208.GE29434@bombadil.infradead.org>
References: <20190902092341.26712-1-william.kucharski@oracle.com>
 <20190902092341.26712-3-william.kucharski@oracle.com>
 <20190903121424.GT14028@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190903121424.GT14028@dhcp22.suse.cz>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 03, 2019 at 02:14:24PM +0200, Michal Hocko wrote:
> On Mon 02-09-19 03:23:41, William Kucharski wrote:
> > Add filemap_huge_fault() to attempt to satisfy page
> > faults on memory-mapped read-only text pages using THP when possible.
> 
> This deserves much more description of how the thing is implemented and
> expected to work. For one thing it is not really clear to me why you
> need CONFIG_RO_EXEC_FILEMAP_HUGE_FAULT_THP at all. You need a support
> from the filesystem anyway. So who is going to enable/disable this
> config?

There are definitely situations in which enabling this code will crash
the kernel.  But we want to get filesystems to a point where they can
start working on their support for large pages.  So our workaround is
to try to get the core pieces merged under a CONFIG_I_KNOW_WHAT_IM_DOING
flag and let people play with it.  Then continue to work on the core
to eliminate those places that are broken.

> I cannot really comment on fs specific parts but filemap_huge_fault
> sounds convoluted so much I cannot wrap my head around it. One thing
> stand out though. The generic filemap_huge_fault depends on ->readpage
> doing the right thing which sounds quite questionable to me. If nothing
> else  I would expect ->readpages to do the job.

Ah, that's because you're not a filesystem person ;-)  ->readpages is
really ->readahead.  It's a crappy interface and should be completely
redesigned.

Thanks for looking!

