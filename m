Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FC1CC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:31:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA72A20842
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:31:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="2GFIMDys"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA72A20842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60B1F8E0005; Tue, 12 Feb 2019 11:31:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5943A8E0001; Tue, 12 Feb 2019 11:31:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45DB58E0005; Tue, 12 Feb 2019 11:31:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 143CA8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:31:53 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id i2so2055120ywb.1
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:31:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=k383lkrnMIT9hl6jPf7ElzcUVczNMkWeD3scLLSruZk=;
        b=UsBe7X9Dh4l9WlClT8a/2Bq/uvtWaufMUi7C16DIgMNFzkBVp3lymJwxABj3chNwWy
         bhh8ADB8jbWfTmOJBvEdFGLLrYcsZJytUOO68gIqUzUdd3E8cnf9ZTJkUDsJzmmjkVmA
         Qss7Ys3SXqUkJXYPqwwVmDfZ02QTY+CbmCHdDVLT7SPNXw8vW6UhD1KVuANwm5Qps1EN
         V6HL9bvARwnYzVnbsNZb6Tb7yUKEcdAhua7iwL0CEmC40FZ3nw4KffPDSK7htjvhrtj+
         XvBeOnLy4wsPqnT3t+VvUriacGxSOZYCbLLQr6gYdQwXp9ZARvuG7KaYAB7O/8ZoYDF3
         BQuw==
X-Gm-Message-State: AHQUAuY+KOvNtv8RFzD70flswqmVAzM5bLsxe2DHfgv1TTJY3k9yzjWq
	GC+umhuGrF4OPdlZginrsIYIRXhI/fmE2g2/j6qSAVh+b+QfHLFlqeGBIZLL7IZVZYMqUT4qH78
	SORgKyGSMsSanUHGjcRiUYcNgdx1CMj60zbdMSFqRAwYbsgHiAe0psRhDsYjRGY+jCwDPv9UXLU
	wz9k8VMPlCvWat+K1DZ3tgLHL8nZq18oBi8qM9hL96lvpNrqNW+uDNMjELLGUYNl9LC5741rgUU
	nZVFMtULTvz2GIDgLMPHg7JTHEtmchfK3KXxVe1uuznl8o39jqm7WcY5i7AIDmowdGdk5QXOK5+
	UKbqj2V6XSHAWG40lTGa60GSxBB57nSSreMjaB9XmU7tZnZFKZON0Sv6333YUQhOM45MkrEBWoo
	O
X-Received: by 2002:a81:2e86:: with SMTP id u128mr753047ywu.241.1549989112802;
        Tue, 12 Feb 2019 08:31:52 -0800 (PST)
X-Received: by 2002:a81:2e86:: with SMTP id u128mr753001ywu.241.1549989112245;
        Tue, 12 Feb 2019 08:31:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549989112; cv=none;
        d=google.com; s=arc-20160816;
        b=vjLmZY/mzdvq3+6n+j7d8LbIwOHmVCQBilOTDmMxcD1BB1YpTihTsvTExkFZY++8VI
         HsImu7gzZODqwynATM2QbkPWfHWaanOSq52E6cYgTguYctqh2l6LoyHE5F3Sjb8lF67u
         Xp/PSSJKkMgVPGCQLN1TKnrOROsRn5Wb8egx4FQ4f96jM7AXaphVqEjiv4OXFzd/sfwl
         IqmgdPVK55DTauAnu01i09BXIL1I5rUFBqr0BtAvgDKlUmEWfP039cMY22Dfg1bRzIV+
         IQqhrSG/PzPnb6lbQhzpqEStrkP+JDU/VSSipoxsoUvgF4mCXHQ6GAVfjfYzjSqF5P+0
         +EEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=k383lkrnMIT9hl6jPf7ElzcUVczNMkWeD3scLLSruZk=;
        b=AweAEND94skMzhI3cxS7/HUKWQW0TIfH5g0dKEGZ4pSostIq68DhWTzfhn1mMR8n/7
         XBghzR4FD2rpUpwCF461aGKKWPovzgWdVFtm1nUpYGZg9ajI+1MM2OW7a7vUsSu3ZTjN
         PQ9d/OkJO6woF+h3w0c/aphFaji6Q2WBovfeaeYF1Ip7J+dJILmwwbC7etfDpFo5Jx54
         9Dg7EGxDY7c32w5Y1mJnIcwnDWflO5lmrudZil3yjtxPn5fn1CaZU4KwHbA1TZecuO5z
         ySIL9ygX+Bnk0bUs3YIvKSbL94JOULDtd/ai4qdYPnCCVd28HjuEtMhOkCfMgxaLCDu7
         6oAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=2GFIMDys;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l74sor1862350ywb.163.2019.02.12.08.31.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 08:31:47 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=2GFIMDys;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=k383lkrnMIT9hl6jPf7ElzcUVczNMkWeD3scLLSruZk=;
        b=2GFIMDysrPLYLxvwEyC9v5xoewI4XO35dm3Y6X2rgPAggpwetTFPsErOgfqoOYF6+t
         MVLiXMrouzsO8WFsYLZ1ipi3P4st0oPZX/y5uJJ2ALkJjmPKE3M1KuNMPe/3DY2sJf58
         rhu5ebL9iwHX54M+PGcsAV1fmtl6l3tom+nGIo5Qnvl61u0a/lS7f9k6Z9EZpryBVzvA
         n9nVctDuKEXGtbpPXlUyPPcQW920S3/66BIcxHIo0NI0bYNorBKSX6AdHro3y35+pf8c
         /gZcadMFQwHb5c5f49enCGft3ecq5c2wwchku+ERyNP7dmsrwXgVGV7rFUDuW8qzhhhT
         DDqA==
X-Google-Smtp-Source: AHgI3IYWpqqXurq1JnNK68GVZHNBQkrbFiLjQnkrXQ9hQdJBYhLzawF5oOCA2B7R1ZXAB1TATGjnJw==
X-Received: by 2002:a0d:e741:: with SMTP id q62mr805378ywe.34.1549989107465;
        Tue, 12 Feb 2019 08:31:47 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::4:41f4])
        by smtp.gmail.com with ESMTPSA id p3sm4004282ywp.44.2019.02.12.08.31.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Feb 2019 08:31:46 -0800 (PST)
Date: Tue, 12 Feb 2019 11:31:45 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Paul E. McKenney" <paulmck@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	kbuild test robot <lkp@intel.com>,
	Suren Baghdasaryan <surenb@google.com>, kbuild-all@01.org,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [linux-next:master 6618/6917] kernel/sched/psi.c:1230:13:
 sparse: error: incompatible types in comparison expression (different
 address spaces)
Message-ID: <20190212163145.GD14231@cmpxchg.org>
References: <201902080231.RZbiWtQ6%fengguang.wu@intel.com>
 <20190208151441.4048e6968579dd178b259609@linux-foundation.org>
 <20190209074407.GE4240@linux.ibm.com>
 <20190212013606.GJ12668@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212013606.GJ12668@bombadil.infradead.org>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 05:36:06PM -0800, Matthew Wilcox wrote:
> On Fri, Feb 08, 2019 at 11:44:07PM -0800, Paul E. McKenney wrote:
> > On Fri, Feb 08, 2019 at 03:14:41PM -0800, Andrew Morton wrote:
> > > On Fri, 8 Feb 2019 02:29:33 +0800 kbuild test robot <lkp@intel.com> wrote:
> > > >   1223	static __poll_t psi_fop_poll(struct file *file, poll_table *wait)
> > > >   1224	{
> > > >   1225		struct seq_file *seq = file->private_data;
> > > >   1226		struct psi_trigger *t;
> > > >   1227		__poll_t ret;
> > > >   1228	
> > > >   1229		rcu_read_lock();
> > > > > 1230		t = rcu_dereference(seq->private);
> 
> So the problem here is the opposite of what we think it is -- seq->private
> is not marked as being RCU protected.
>
> > If you wish to opt into this checking, you need to mark the pointer
> > definitions (in this case ->private) with __rcu.  It may also
> > be necessary to mark function parameters as well, as is done for
> > radix_tree_iter_resume().  If you do not wish to use this checking,
> > you should ignore these sparse warnings.

We cannot make struct seq_file->private generally __rcu, but the
cgroup code has a similar thing with kernfs, where it's doing rcu for
its particular use of struct kernfs_node->private. This is how it does
the dereference:

	cgrp = rcu_dereference(*(void __rcu __force **)&kn->priv);

We could do this here as well.

It's ugly, though. I'd also be fine with ignoring the sparse warning.

