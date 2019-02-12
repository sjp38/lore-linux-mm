Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 244ECC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:35:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6AAC217FA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:35:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Sr/H3MYU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6AAC217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B9E18E0003; Tue, 12 Feb 2019 11:35:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56A798E0001; Tue, 12 Feb 2019 11:35:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4806F8E0003; Tue, 12 Feb 2019 11:35:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0307D8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:35:51 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id e5so1303860pgc.16
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:35:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zNOt7tU83BvxZuWZ7kMdSaQzUFJaNFYMKeSqibVM4lk=;
        b=mScDvHR8Q7+T5BwcebSR61Nnyv7wDMhCUqBsl9dsfzH8xfMxPLZMKyaUfGJN0EOsQC
         FsFFnNp57XIFEffLj0AlrsP2W+LTiivgyQ+shUwZ5zeUyXWBNyilPSmFa9R+0pVJ3FzY
         WDSNQ88JOkvPHVia8e07tstZrDOtQ20LZrql2aEiyEjzxW91ZklBF64WSXPevrBKncOz
         tXNI0sP2uOSKRUmYtRIG/oL3cMo8PP1Arn3QR4bJaF+ECOYNr900z6Jtcg5Mu2bykMJt
         PoGevoFUARCpWJlvHCmAaLJHydQpWgKIRlRnJ4qjFK5JHQPbSM+G8xDDhsmAdZXJmwwN
         bKKQ==
X-Gm-Message-State: AHQUAuahu9dssVwaW0o2vaak3nO8Gzvgs0akISOKTYq2V6/CEHmf20PB
	R7ffny2CQLNUz5DaGteHWWmd9t43K/TZBtyGZQrVNsSmf5A2kznEQuVG8chADWjoEQI2AMRNGPt
	QR5Vn0qPARJ2K7Ld2ZM5mQfH5K3hVSH+akS9RojB5ulIx/goco4q1+zusNnSAXArSTw==
X-Received: by 2002:a63:ae0e:: with SMTP id q14mr4432499pgf.151.1549989350618;
        Tue, 12 Feb 2019 08:35:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYFHPWZ3O7DQ9KuTjIt4IRx7ArRZNX7ynSX7UMzq4xDxUmA/P69PHbEGpBA+vM7e3nKpTzZ
X-Received: by 2002:a63:ae0e:: with SMTP id q14mr4432464pgf.151.1549989349976;
        Tue, 12 Feb 2019 08:35:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549989349; cv=none;
        d=google.com; s=arc-20160816;
        b=ddcOa8inADnupBXTEjYbEE5h4FFrzPWdhq/oCq+iKbPWuyvbnLuEzXf+PJfq+Adyu2
         Nn1TKvzU4pgwPjMwz+Pjkm/dXs9Cv8xU8T2rPnk4wuOi2J0MTddY+gqJP8mZggXlljcd
         ARqYrh7MZid1Z4Uf7iAaXtFfBYQx5aF5uKzc8uEOgp7ldpUTOcCU8xktHyTaC9srmc6d
         qT/ZawCGGp7NBCZORBzrQYdyXgJaf9ZP/ZbWliJO0z5RnRYz67vig4pBa5EDzdrUGE8U
         r1bhMf1EYWudLSqtrG9FVP+RvrAQpCaF4eyDsMKoedMf1wL5AmUZz6oRZchsUAtPjU4i
         6JPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=zNOt7tU83BvxZuWZ7kMdSaQzUFJaNFYMKeSqibVM4lk=;
        b=DMI+08V54mD18H8TnMoC9RPJs6nK7j2MfBlRjqHoBpFZnRHzbUz/ofaF2V52QULcKD
         hqg8YPd8CURPdJA2k3ZfVumJtVzAuI3gBS3Rgfv/CFQ72Jq0KqaASH+/2ni6rLDe+TsJ
         9+NAUhK4lt9NWfokiqsy4CvFbfmjXqZZV9UGnhIV1Bh6MDBd4TExONhUDHcL3NPlLHC2
         0nhRP55w3XrqIkwsN9qyDLybMKzGDu9AEflqMiyk1PJteQhEhvkSqnO3Pp9pTwPw8WSx
         HcqWeU18EZPZshe4n4RwFmBXe/V762xkcYX2FsoMTZ3eb3UWC83E/pKmDgGMNmtAEgKJ
         klsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Sr/H3MYU";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 133si13532020pfw.64.2019.02.12.08.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Feb 2019 08:35:49 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="Sr/H3MYU";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=zNOt7tU83BvxZuWZ7kMdSaQzUFJaNFYMKeSqibVM4lk=; b=Sr/H3MYU50cJw780QDvWtI4BP
	qxCpGcVPAxlRXz+6BLeJDIRS53SsIG61FeRHTWzF8NJSQqcpLmWHbmGrodeoHYg59MottV+fZ8g8A
	puK5aP1RMnD5N7DHKjq2RP5yVEpOV0iZ/b+WQTff8KJQATfENf+5itH5BXJdZoHS3O+WvmOINaEi2
	8Sk3a9P/NVlZr6Ldigb/yHIUI7Af7RbebnXbaIn8OgRjf3ec6/rHLE/dw4zZZGwGb6E8KHPMS5YCE
	/LIb1/wdoK/E7KcpRc8lV0uc9C1iW/6ug5WwrDIFG+irVH13hNF6PE2ihmvcK6gzhN7I7ZZ71/PGY
	J78j/+RCQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtb2B-0002wD-LK; Tue, 12 Feb 2019 16:35:47 +0000
Date: Tue, 12 Feb 2019 08:35:47 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Paul E. McKenney" <paulmck@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	kbuild test robot <lkp@intel.com>,
	Suren Baghdasaryan <surenb@google.com>, kbuild-all@01.org,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [linux-next:master 6618/6917] kernel/sched/psi.c:1230:13:
 sparse: error: incompatible types in comparison expression (different
 address spaces)
Message-ID: <20190212163547.GP12668@bombadil.infradead.org>
References: <201902080231.RZbiWtQ6%fengguang.wu@intel.com>
 <20190208151441.4048e6968579dd178b259609@linux-foundation.org>
 <20190209074407.GE4240@linux.ibm.com>
 <20190212013606.GJ12668@bombadil.infradead.org>
 <20190212163145.GD14231@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212163145.GD14231@cmpxchg.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 11:31:45AM -0500, Johannes Weiner wrote:
> On Mon, Feb 11, 2019 at 05:36:06PM -0800, Matthew Wilcox wrote:
> > On Fri, Feb 08, 2019 at 11:44:07PM -0800, Paul E. McKenney wrote:
> > > On Fri, Feb 08, 2019 at 03:14:41PM -0800, Andrew Morton wrote:
> > > > On Fri, 8 Feb 2019 02:29:33 +0800 kbuild test robot <lkp@intel.com> wrote:
> > > > >   1223	static __poll_t psi_fop_poll(struct file *file, poll_table *wait)
> > > > >   1224	{
> > > > >   1225		struct seq_file *seq = file->private_data;
> > > > >   1226		struct psi_trigger *t;
> > > > >   1227		__poll_t ret;
> > > > >   1228	
> > > > >   1229		rcu_read_lock();
> > > > > > 1230		t = rcu_dereference(seq->private);
> > 
> > So the problem here is the opposite of what we think it is -- seq->private
> > is not marked as being RCU protected.
> >
> > > If you wish to opt into this checking, you need to mark the pointer
> > > definitions (in this case ->private) with __rcu.  It may also
> > > be necessary to mark function parameters as well, as is done for
> > > radix_tree_iter_resume().  If you do not wish to use this checking,
> > > you should ignore these sparse warnings.
> 
> We cannot make struct seq_file->private generally __rcu, but the
> cgroup code has a similar thing with kernfs, where it's doing rcu for
> its particular use of struct kernfs_node->private. This is how it does
> the dereference:
> 
> 	cgrp = rcu_dereference(*(void __rcu __force **)&kn->priv);
> 
> We could do this here as well.
> 
> It's ugly, though. I'd also be fine with ignoring the sparse warning.

How about:

+++ b/include/linux/seq_file.h
@@ -26,7 +26,10 @@ struct seq_file {
        const struct seq_operations *op;
        int poll_event;
        const struct file *file;
-       void *private;
+       union {
+               void *private;
+               void __rcu *rcu_private;
+       };
 };
 
 struct seq_operations {

