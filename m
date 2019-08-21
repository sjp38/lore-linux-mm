Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3509C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 00:54:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 877402087E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 00:54:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Js1Jfjif"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 877402087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 341E36B0270; Tue, 20 Aug 2019 20:54:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F2756B0272; Tue, 20 Aug 2019 20:54:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 208D16B0273; Tue, 20 Aug 2019 20:54:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0251.hostedemail.com [216.40.44.251])
	by kanga.kvack.org (Postfix) with ESMTP id F20E56B0270
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 20:54:24 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id A4A086D7D
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:54:24 +0000 (UTC)
X-FDA: 75844614048.23.thumb72_7dc4f303b9956
X-HE-Tag: thumb72_7dc4f303b9956
X-Filterd-Recvd-Size: 3173
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:54:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=WOLUqTOBybrWu/WmLa0SVTrR0ZYSLugUxBFyMLxbqBk=; b=Js1JfjifrXDe1lW3QE0Yt1gQR
	mUJPk4hesVY8anlPMG86AjT2E7bMJlzTIYmfRzQvg4GPxETvFoHfJyFd1r2jMVZIkrSFQTyV3tQOZ
	N5vWvQ0H5Ev3QPSClW7ql5JmjrXRUrKTkQR2y5XKQ3Wa2qA5kEqCmpGQePKVUfvDn3h7JKQrJG7Rr
	6PPyYLWeixe0Lc/05HHGE+hz9Wu27e1xsznb5nyyDY/7Y48C+hh6vV/SRWOSKTtFBXOLv1MNJUKgs
	Rbb0Vzqql47R+Y8WMZZHhIwl/4gFyCLAMCUbSB6LmAw+tVryHKTyF4wzfNZJnC1vdyYjxR0ShVS4O
	Ig8uakCow==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i0EtF-0004F5-It; Wed, 21 Aug 2019 00:54:17 +0000
Date: Tue, 20 Aug 2019 17:54:17 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Wei Yang <richardw.yang@linux.intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christoph Hellwig <hch@infradead.org>,
	akpm@linux-foundation.org, mgorman@techsingularity.net,
	osalvador@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/3] mm/mmap.c: extract __vma_unlink_list as counter part
 for __vma_link_list
Message-ID: <20190821005417.GC18776@bombadil.infradead.org>
References: <20190814021755.1977-1-richardw.yang@linux.intel.com>
 <20190814021755.1977-3-richardw.yang@linux.intel.com>
 <20190814051611.GA1958@infradead.org>
 <20190814065703.GA6433@richard>
 <2c5cdffd-f405-23b8-98f5-37b95ca9b027@suse.cz>
 <20190820172629.GB4949@bombadil.infradead.org>
 <20190821005234.GA5540@richard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190821005234.GA5540@richard>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 08:52:34AM +0800, Wei Yang wrote:
> On Tue, Aug 20, 2019 at 10:26:29AM -0700, Matthew Wilcox wrote:
> >On Wed, Aug 14, 2019 at 11:19:37AM +0200, Vlastimil Babka wrote:
> >> On 8/14/19 8:57 AM, Wei Yang wrote:
> >> > On Tue, Aug 13, 2019 at 10:16:11PM -0700, Christoph Hellwig wrote:
> >> >>Btw, is there any good reason we don't use a list_head for vma linkage?
> >> > 
> >> > Not sure, maybe there is some historical reason?
> >> 
> >> Seems it was single-linked until 2010 commit 297c5eee3724 ("mm: make the vma
> >> list be doubly linked") and I guess it was just simpler to add the vm_prev link.
> >> 
> >> Conversion to list_head might be an interesting project for some "advanced
> >> beginner" in the kernel :)
> >
> >I'm working to get rid of vm_prev and vm_next, so it would probably be
> >wasted effort.
> 
> You mean replace it with list_head?

No, replace the rbtree with a new tree.  https://lwn.net/Articles/787629/

