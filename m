Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 55D2128024A
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 18:28:39 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id o128so8684049pfg.6
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 15:28:39 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id t6si2932718plz.522.2018.01.16.15.28.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Jan 2018 15:28:38 -0800 (PST)
Message-ID: <1516145316.14734.11.camel@HansenPartnership.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] A high-performance userspace block
 driver
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Tue, 16 Jan 2018 15:28:36 -0800
In-Reply-To: <20180116232335.GM8249@thunk.org>
References: <20180116145240.GD30073@bombadil.infradead.org>
	 <20180116232335.GM8249@thunk.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-block@vger.kernel.org, linux-scsi <linux-scsi@vger.kernel.org>

On Tue, 2018-01-16 at 18:23 -0500, Theodore Ts'o wrote:
> On Tue, Jan 16, 2018 at 06:52:40AM -0800, Matthew Wilcox wrote:
> > 
> > 
> > I see the improvements that Facebook have been making to the nbd
> > driver, and I think that's a wonderful thing.A A Maybe the outcome of
> > this topic is simply: "Shut up, Matthew, this is good enough".
> > 
> > It's clear that there's an appetite for userspace block devices;
> > not for swap devices or the root device, but for accessing data
> > that's stored in that silo over there, and I really don't want to
> > bring that entire mess of CORBA / Go / Rust / whatever into the
> > kernel to get to it, but it would be really handy to present it as
> > a block device.
> 
> ... and using iSCSI was too painful and heavyweight.

>From what I've seen a reasonable number of storage over IP cloud
implementations are actually using AoE. A The argument goes that the
protocol is about ideal (at least as compared to iSCSI or FCoE) and the
company behind it doesn't seem to want to add any more features that
would bloat it.

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
