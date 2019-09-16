Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9534CC49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 20:58:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B25C206C2
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 20:58:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="HACGFBeK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B25C206C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A49996B0003; Mon, 16 Sep 2019 16:58:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F9B26B0006; Mon, 16 Sep 2019 16:58:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9376A6B0007; Mon, 16 Sep 2019 16:58:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0144.hostedemail.com [216.40.44.144])
	by kanga.kvack.org (Postfix) with ESMTP id 718346B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 16:58:08 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id D9831181AC9AE
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 20:58:07 +0000 (UTC)
X-FDA: 75941996214.15.sack08_46e82270c5a00
X-HE-Tag: sack08_46e82270c5a00
X-Filterd-Recvd-Size: 4230
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 20:58:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=yeJayqOR9sbkuSoE2xkkfI48PIerp6/smkJ5wYd6VHo=; b=HACGFBeKT5pI2El5XJm2wRaxy
	4NzAYGacsQiBSEMLV48E2a8borqjI8BwHHRbsW6wzrSqUXk3pLIHNeJtYzwnHSCRELUd9zlsq7pgQ
	+8CN3XusJBI5lrtz5NufdBfaJXfoQod4jEXvtAcAqZwq7jmo7AC/xzXs9vITUj6AXAU2OOSlUhAGA
	vBt0tJ09fwkT6LoK1jv9AGl70cQOzqeGTt3iVzy8ylxmSzBxm32aWLHfgFZuD0HkYLqGNiEoaHnvn
	/6VjKlZp2e6g7xv6Lb/fuqkNRkP43WpHtG61o39zZE+9D9fp25WmToPQESE1/2DtJtasDEW64MWr2
	jNey2LZgw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92.2 #3 (Red Hat Linux))
	id 1i9y4L-0001LW-Dy; Mon, 16 Sep 2019 20:57:57 +0000
Date: Mon, 16 Sep 2019 13:57:57 -0700
From: Matthew Wilcox <willy@infradead.org>
To: David Rientjes <rientjes@google.com>
Cc: syzbot <syzbot+e38fe539fedfc127987e@syzkaller.appspotmail.com>,
	Jiri Kosina <jikos@kernel.org>,
	Benjamin Tissoires <benjamin.tissoires@redhat.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>, andreyknvl@google.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-usb@vger.kernel.org, mhocko@suse.com,
	syzkaller-bugs@googlegroups.com, vbabka@suse.cz,
	yang.shi@linux.alibaba.com, zhongjiang@huawei.com
Subject: Re: WARNING in __alloc_pages_nodemask
Message-ID: <20190916205756.GR29434@bombadil.infradead.org>
References: <00000000000025ae690592b00fbd@google.com>
 <alpine.DEB.2.21.1909161258150.118156@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1909161258150.118156@chino.kir.corp.google.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 16, 2019 at 01:00:11PM -0700, David Rientjes wrote:
> On Mon, 16 Sep 2019, syzbot wrote:
> > HEAD commit:    f0df5c1b usb-fuzzer: main usb gadget fuzzer driver
> > git tree:       https://github.com/google/kasan.git usb-fuzzer
> > console output: https://syzkaller.appspot.com/x/log.txt?x=14b15371600000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=5c6633fa4ed00be5
> > dashboard link: https://syzkaller.appspot.com/bug?extid=e38fe539fedfc127987e
> > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=1093bed1600000
> > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=1603cfc6600000
> > 
> > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > Reported-by: syzbot+e38fe539fedfc127987e@syzkaller.appspotmail.com
> > 
> > WARNING: CPU: 0 PID: 1720 at mm/page_alloc.c:4696
> > __alloc_pages_nodemask+0x36f/0x780 mm/page_alloc.c:4696
> > Kernel panic - not syncing: panic_on_warn set ...

> > alloc_pages_current+0xff/0x200 mm/mempolicy.c:2153
> > alloc_pages include/linux/gfp.h:509 [inline]
> > kmalloc_order+0x1a/0x60 mm/slab_common.c:1257
> > kmalloc_order_trace+0x18/0x110 mm/slab_common.c:1269
> > __usbhid_submit_report drivers/hid/usbhid/hid-core.c:588 [inline]
> > usbhid_submit_report+0x5b5/0xde0 drivers/hid/usbhid/hid-core.c:638
> > usbhid_request+0x3c/0x70 drivers/hid/usbhid/hid-core.c:1252
> > hid_hw_request include/linux/hid.h:1053 [inline]
> > hiddev_ioctl+0x526/0x1550 drivers/hid/usbhid/hiddev.c:735
> Adding Jiri and Benjamin.  The hid report length is simply too large for 
> the page allocator to allocate: this is triggering because the resulting 
> allocation order is > MAX_ORDER-1.  Any way to make this allocate less 
> physically contiguous memory?

The HID code should, presumably, reject reports which are larger than
PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER.  Particularly since it's using
GFP_ATOMIC.


