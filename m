Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7997C282DF
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 20:11:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AB0921872
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 20:11:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AB0921872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08A806B0007; Fri, 19 Apr 2019 16:11:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03B076B0008; Fri, 19 Apr 2019 16:11:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E6C1A6B000A; Fri, 19 Apr 2019 16:11:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id AEBBE6B0007
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 16:11:15 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d10so4031978plo.12
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 13:11:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aYbOhLlfWOpzwfuvn674kunT6p2rc8MzEepYDPlO1gQ=;
        b=eHCiKB/TJYaKFG0cyY3AKHJY1UpZCHKRz7xE9qtiZWlfHaoih5LTCodQkgqyU3+2yW
         lK7M4nTLxLyjdFEIORY5mkdyO8WTNQDktjlfd8R+AUDuWMFKvwX3legaWv2rfx4WmA7L
         8n5QLMJj3VOf8mbcKLGAd69bwiHZ0UoNDVU3jn5DPDxrsNW+vMuN87eDBuopwgL8bapL
         1pub+PVw4RrShbL8KfeOfinLMRpWwFUQJ2oVB/0ye6dGcnGE3Yxq73gNKbFawMYbmX1n
         +PSrRvyDiUTmiJaQFBEkGokg+a0GSf1/6uFxxIZ3+4AhcUCPPrP5o1gUNC74uCQy/cKI
         0ijA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=q68w=sv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Q68w=SV=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAUpBiEO+YsKGz5y3NVKLRgKu0RrmmgHJqzGpxbvtlM45Nks/8wY
	i42K6fxVB8kRkulfrL8pqiT66wV1+tA5cP+U1TE33Nh9BlvqxNbizMvr1gIPkY4fJaVqaqK7gFc
	vW8A4PNBUaa8D2dufKHIs2XC3YttIf1olLCET2tWJJyenG+qO11PkNSk08FzFIG0=
X-Received: by 2002:a65:4482:: with SMTP id l2mr5523160pgq.362.1555704675331;
        Fri, 19 Apr 2019 13:11:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIohEzdbBmgYPidgNv0XI3YyDOrtpm06zqzWSaCxyCeT9ElaXwuf2j9JWd8nF1WyIVKNTm
X-Received: by 2002:a65:4482:: with SMTP id l2mr5523116pgq.362.1555704674699;
        Fri, 19 Apr 2019 13:11:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555704674; cv=none;
        d=google.com; s=arc-20160816;
        b=euGRJ2VNEN5AA8TvDb/jmybPXj8EMO13IjFpEUp9RtehlE+oVkpJUi+TDGDZ7lPFRq
         +wTOL/lN43zhFPOtUgDBp+37Kq17Ui41mTbQXyzQ0ZYvFwUe3KJUQTXgbINpfLR/YvpG
         VAmM1QIsGcmRyrVXy9CHiL0cJUeEI3/ayHWk8mwwEM6t9tq976GB/NpEmEsArpxhdP6Y
         SrGzDP1AizArHrueQP7Sn36OsUGlxSQcY44PU6rRK9vUL8ujlOVmhBQrLbgvN0dqb14m
         dh9EeKxWwgS9qhLEfsPOpMPHDpGJA+mPLp7MCZ6jXQsttGjGzIfqFzxUAQiICFmt3SJW
         4HKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=aYbOhLlfWOpzwfuvn674kunT6p2rc8MzEepYDPlO1gQ=;
        b=PERvXYY4nIxhYwrSKvI2fUu1DmS5UuE/ulqRESAHHZXqg6Rpr2qjSNTbTTKTUTwbQR
         Gz8h0dooeWpNZ109BWrBk1zWFpPpytTV9zoxbQihXniMN9vY7M94VnmdtbLTJ6fhZr3R
         ab55y/GXI94pCidDUvN7S+nowus7XEelw3iaXaCy0xaBI+9zO8Olln1B+WdGlH2TYfeE
         0upZlY/MmVjmbSzvO+2J3INH9MK/X+jC+daBXaKEhHQ+lu2M97bA3y5HhecftpshgG4Z
         muWXk+7UDeMkcG+u9dI6Ppt/lArS05EtaxXLpeL48Q6f/WZ4Pwi7s+p1BFpmkLvHMEGt
         vEwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=q68w=sv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Q68w=SV=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h126si5585275pgc.508.2019.04.19.13.11.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 13:11:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=q68w=sv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=q68w=sv=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=Q68w=SV=goodmis.org=rostedt@kernel.org"
Received: from gandalf.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0CD282171F;
	Fri, 19 Apr 2019 20:11:10 +0000 (UTC)
Date: Fri, 19 Apr 2019 16:11:09 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf
 <jpoimboe@redhat.com>, x86@kernel.org, Andy Lutomirski <luto@kernel.org>,
 Alexander Potapenko <glider@google.com>, Alexey Dobriyan
 <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka
 Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes
 <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Catalin Marinas
 <catalin.marinas@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey
 Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com, Mike
 Rapoport <rppt@linux.vnet.ibm.com>, Akinobu Mita <akinobu.mita@gmail.com>,
 iommu@lists.linux-foundation.org, Robin Murphy <robin.murphy@arm.com>,
 Christoph Hellwig <hch@lst.de>, Marek Szyprowski
 <m.szyprowski@samsung.com>, Johannes Thumshirn <jthumshirn@suse.de>, David
 Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>, Josef Bacik
 <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org, dm-devel@redhat.com,
 Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>,
 intel-gfx@lists.freedesktop.org, Joonas Lahtinen
 <joonas.lahtinen@linux.intel.com>, Maarten Lankhorst
 <maarten.lankhorst@linux.intel.com>, dri-devel@lists.freedesktop.org, David
 Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>,
 Daniel Vetter <daniel@ffwll.ch>, Rodrigo Vivi <rodrigo.vivi@intel.com>,
 linux-arch@vger.kernel.org
Subject: Re: [patch V2 23/29] tracing: Simplify stack trace retrieval
Message-ID: <20190419161109.5f981236@gandalf.local.home>
In-Reply-To: <20190418084255.186774860@linutronix.de>
References: <20190418084119.056416939@linutronix.de>
	<20190418084255.186774860@linutronix.de>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Apr 2019 10:41:42 +0200
Thomas Gleixner <tglx@linutronix.de> wrote:

> Replace the indirection through struct stack_trace by using the storage
> array based interfaces.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Steven Rostedt <rostedt@goodmis.org>

Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>

-- Steve

