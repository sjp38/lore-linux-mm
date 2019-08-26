Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_2 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7C6DC3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 15:56:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CBD6217F5
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 15:56:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CBD6217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC9CA6B05A8; Mon, 26 Aug 2019 11:56:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7A336B05A9; Mon, 26 Aug 2019 11:56:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8F176B05AA; Mon, 26 Aug 2019 11:56:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0201.hostedemail.com [216.40.44.201])
	by kanga.kvack.org (Postfix) with ESMTP id 9308A6B05A8
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 11:56:56 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 3F4861F17
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:56:56 +0000 (UTC)
X-FDA: 75865032432.22.cub50_250dc5fbf201
X-HE-Tag: cub50_250dc5fbf201
X-Filterd-Recvd-Size: 2085
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:56:55 +0000 (UTC)
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 899FD20828;
	Mon, 26 Aug 2019 15:56:53 +0000 (UTC)
Date: Mon, 26 Aug 2019 11:56:51 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Nadav Amit <namit@vmware.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Song Liu <songliubraving@fb.com>,
 LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
 "kernel-team@fb.com" <kernel-team@fb.com>, "stable@vger.kernel.org"
 <stable@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen
 <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Daniel
 Bristot de Oliveira <bristot@redhat.com>
Subject: Re: [PATCH] x86/mm: Do not split_large_page() for
 set_kernel_text_rw()
Message-ID: <20190826115651.43c9bde3@gandalf.local.home>
In-Reply-To: <31AB5512-F083-4DC3-BA73-D5D65CBC410A@vmware.com>
References: <20190823052335.572133-1-songliubraving@fb.com>
	<20190823093637.GH2369@hirez.programming.kicks-ass.net>
	<20190826073308.6e82589d@gandalf.local.home>
	<31AB5512-F083-4DC3-BA73-D5D65CBC410A@vmware.com>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 26 Aug 2019 15:41:24 +0000
Nadav Amit <namit@vmware.com> wrote:

> > Anyway, I believe Nadav has some patches that converts ftrace to use
> > the shadow page modification trick somewhere.  
> 
> For the record - here is my previous patch:
> https://lkml.org/lkml/2018/12/5/211

FYI, when referencing older patches, please use lkml.kernel.org or
lore.kernel.org, lkml.org is slow and obsolete.

ie. http://lkml.kernel.org/r/20181205013408.47725-9-namit@vmware.com

-- Steve

