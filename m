Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D709C4740C
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 13:55:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D00A82086D
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 13:55:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Uxim2b/q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D00A82086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61DA76B0005; Mon,  9 Sep 2019 09:55:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CCB66B0006; Mon,  9 Sep 2019 09:55:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E2B26B0007; Mon,  9 Sep 2019 09:55:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0124.hostedemail.com [216.40.44.124])
	by kanga.kvack.org (Postfix) with ESMTP id 2DC456B0005
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 09:55:35 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D1323824376D
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 13:55:34 +0000 (UTC)
X-FDA: 75915529788.18.pipe34_30a81ee134352
X-HE-Tag: pipe34_30a81ee134352
X-Filterd-Recvd-Size: 4125
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 13:55:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=UkyPHsUqAei6DhO0zB/xoh0Ya9g+WCqG9FpRgGkoXso=; b=Uxim2b/qFkMsY2cR6yo+ozIvX
	VeiO14bsaHIOwUVUkaeAgpqC1XJOyNg5vIRNnN435YkyFCwCDzUHcgDIw/FzAIZn1O+56JTEv743M
	6Qd4DyiweN4ivLrHZoU1EqNzTS3mG3RcTdM1uD/7nmiqGL+n3bCnJLZEGtTW7K8fnk1hnVyvb9Pof
	wZUdRewXSz3Rj16snxGC1ma20JFW/HtSjNSliq45SVNpdtfRFqPMVJzTOoMsuqSNU2nx8n5LJvjoD
	L8hqNE9VG3wAH3Nvss6Ib7rJRqflvu4AG7tnrdjKsIVzlek3SWK/4R33gn7C3ahRZDd3azas3TUzZ
	MmZiNPygw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i7K8X-0000wL-DR; Mon, 09 Sep 2019 13:55:21 +0000
Date: Mon, 9 Sep 2019 06:55:21 -0700
From: Matthew Wilcox <willy@infradead.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hillf Danton <hdanton@sina.com>,
	syzbot <syzbot+03ee87124ee05af991bd@syzkaller.appspotmail.com>,
	hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	syzkaller-bugs@googlegroups.com
Subject: Re: KASAN: use-after-free Read in shmem_fault (2)
Message-ID: <20190909135521.GD29434@bombadil.infradead.org>
References: <20190831045826.748-1-hdanton@sina.com>
 <20190902135254.GC2431@bombadil.infradead.org>
 <20190902142029.fyq3dwn72pqqlzul@box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190902142029.fyq3dwn72pqqlzul@box>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 02, 2019 at 05:20:30PM +0300, Kirill A. Shutemov wrote:
> On Mon, Sep 02, 2019 at 06:52:54AM -0700, Matthew Wilcox wrote:
> > On Sat, Aug 31, 2019 at 12:58:26PM +0800, Hillf Danton wrote:
> > > On Fri, 30 Aug 2019 12:40:06 -0700
> > > > syzbot found the following crash on:
> > > > 
> > > > HEAD commit:    a55aa89a Linux 5.3-rc6
> > > > git tree:       upstream
> > > > console output: https://syzkaller.appspot.com/x/log.txt?x=12f4beb6600000
> > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=2a6a2b9826fdadf9
> > > > dashboard link: https://syzkaller.appspot.com/bug?extid=03ee87124ee05af991bd
> > > > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> > > > 
> > > > ==================================================================
> > > > BUG: KASAN: use-after-free in perf_trace_lock_acquire+0x401/0x530  
> > > > include/trace/events/lock.h:13
> > > > Read of size 8 at addr ffff8880a5cf2c50 by task syz-executor.0/26173
> > > 
> > > --- a/mm/shmem.c
> > > +++ b/mm/shmem.c
> > > @@ -2021,6 +2021,12 @@ static vm_fault_t shmem_fault(struct vm_
> > >  			shmem_falloc_waitq = shmem_falloc->waitq;
> > >  			prepare_to_wait(shmem_falloc_waitq, &shmem_fault_wait,
> > >  					TASK_UNINTERRUPTIBLE);
> > > +			/*
> > > +			 * it is not trivial to see what will take place after
> > > +			 * releasing i_lock and taking a nap, so hold inode to
> > > +			 * be on the safe side.
> > 
> > I think the comment could be improved.  How about:
> > 
> > 			 * The file could be unmapped by another thread after
> > 			 * releasing i_lock, and the inode then freed.  Hold
> > 			 * a reference to the inode to prevent this.
> 
> It only can happen if mmap_sem was released, so it's better to put
> __iget() to the branch above next to up_read(). I've got confused at first
> how it is possible from ->fault().
> 
> This way iput() below should only be called for ret == VM_FAULT_RETRY.

Looking at the rather similar construct in filemap.c, should we solve
it the same way, where we inc the refcount on the struct file instead
of the inode before releasing the mmap_sem?

