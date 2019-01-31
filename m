Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54B08C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 20:46:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1937220881
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 20:46:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1937220881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A74AC8E0002; Thu, 31 Jan 2019 15:46:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FBB58E0001; Thu, 31 Jan 2019 15:46:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C4328E0002; Thu, 31 Jan 2019 15:46:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 553C78E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 15:46:58 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id x26so2983542pgc.5
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 12:46:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oc9CKATewAk9bcDSzrXUTEmcfyPPyJrGSlUNghjlmqc=;
        b=p7aNEkKpeTbJLHViwQPyeWSNgJPOt3arJxgvUvXtuUOJWbOhoVTDlyFV8WHIc86XhL
         J6ZGPnehSU8EEoFYyD4jY5+FMSSg449mUECDvRiC0CmwGI32IGOBaI0janB81J/oByhQ
         O4y+2ovOM45VBSkT2Oy3lJDIL2eW4+liuNTqecyHCPeu6upm4uLv3TRd1AeSEj/Yy66+
         02t9Hhd4cVh10B1bDNSvZ9cXVBey4K+t9h+hxUIO49ecKC3ggvhyvVkunrc2CEC9Zu9I
         Iy9WRusC2Qmfhjado4lUGjgystO31Dmi1HXZs2DMPbR7jCgLBHNoo5lCE2EcBTE4gZdX
         +h0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukfKW66OZ8Ui+aHYBv0lfKPU5IKUbaQB3e4kXIK8VWeutVexqXxX
	8Xinljdzkl8255ccuZxvBiniqTkMvKkplrI5VFGXJzDSZdiBi3Lda2C1bHu8vL45KvRmiva+iHf
	ZWMZaXvCqutng2Ac4WK0iunR/7zLwbSvtMmYFDtz5EBpjjkFMXqbF4HoRsbXkVDNJGw==
X-Received: by 2002:a62:26c7:: with SMTP id m190mr36981925pfm.79.1548967617906;
        Thu, 31 Jan 2019 12:46:57 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5QyvuQ92Rq1Gn5Yyv9SGdmcvx/zhKfFfpdbXNr3NYAPgfto2n41HRCh9XRkuhf7ryRAVyd
X-Received: by 2002:a62:26c7:: with SMTP id m190mr36981895pfm.79.1548967617194;
        Thu, 31 Jan 2019 12:46:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548967617; cv=none;
        d=google.com; s=arc-20160816;
        b=UluPAt0jaDpsbEYStOsQ3s5/oq+oepBU2IczOb2/fkrz8s3KCfvMz2RzXIchdBveOZ
         ccuJxMp7DKVlN1ZwLArCpcKEY/9qutEqU0F/iIPqH56SACvQ7fx4fVTldTlqADDRy6vp
         IWXP9muSvdshYGYrujpaIZlCWXsT14AXFuNOZc8iJJmjQ55/OAP+TAgtWf/Bu6zYUx4q
         SfNXSFQ+5OSMJ0LXeBfUmd4P/Xv0C8DcjVGF2jeEZzPH7gveUZ4hTZGbUiVmPlSq+UXA
         ZHhan3f5dIsMLGLtTEQmTSvR8aMjst/eL7+44ZyjaXS3JEaf7A0xjj9JaA3s/K2ayo6r
         8ngw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=oc9CKATewAk9bcDSzrXUTEmcfyPPyJrGSlUNghjlmqc=;
        b=W4kkM8+2EVz4iRchZxCfdnEO4KsV6UzK7b4v5ZeccoeEZgRkRfOCQn1aXsMMztmcOU
         2wHnx/Yl7lbmiiMPl44nEYt7zS/agd80zp4qo6Y9sNgEd4koWYJwRVPOK0abwx5qQev8
         sWZs6KGUnOXJZvriJm7QzsaJr++uUuRBpPBslovOtqLXA5qP5S3t9TAPvroB2amF2jGD
         KI5B8Iys2ezxAzdfmhA6jZe18uQUhyRMo0OrNCLUVeFKysBYiCoeEAA+8vMLD3t/f63o
         ogCRt7NIEobl5ICu+TAWW9tdFiPVDNWxkOtGNkTGIe5E9/lr28VqxdO0zvv2h3IrNRMF
         NptQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 12si5394806pfx.102.2019.01.31.12.46.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 12:46:57 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 477B2490C;
	Thu, 31 Jan 2019 20:46:56 +0000 (UTC)
Date: Thu, 31 Jan 2019 12:46:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: "Huang\, Ying" <ying.huang@intel.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, <dan.carpenter@oracle.com>,
 <andrea.parri@amarulasolutions.com>, <shli@kernel.org>,
 <dave.hansen@linux.intel.com>, <sfr@canb.auug.org.au>, <osandov@fb.com>,
 <tj@kernel.org>, <ak@linux.intel.com>, <linux-mm@kvack.org>,
 <kernel-janitors@vger.kernel.org>, <paulmck@linux.ibm.com>,
 <stern@rowland.harvard.edu>, <peterz@infradead.org>, <will.deacon@arm.com>
Subject: Re: About swapoff race patch  (was Re: [PATCH] mm, swap: bounds
 check swap_info accesses to avoid NULL derefs)
Message-Id: <20190131124655.96af1eb7e2f7bb0905527872@linux-foundation.org>
In-Reply-To: <87tvhpy22q.fsf_-_@yhuang-dev.intel.com>
References: <20190114222529.43zay6r242ipw5jb@ca-dmjordan1.us.oracle.com>
	<20190115002305.15402-1-daniel.m.jordan@oracle.com>
	<20190129222622.440a6c3af63c57f0aa5c09ca@linux-foundation.org>
	<87tvhpy22q.fsf_-_@yhuang-dev.intel.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2019 10:48:29 +0800 "Huang\, Ying" <ying.huang@intel.com> wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> > mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch is very
> > stuck so can you please redo this against mainline?
> 
> Allow me to be off topic, this patch has been in mm tree for quite some
> time, what can I do to help this be merged upstream?

I have no evidence that it has been reviewed, for a start.  I've asked
Hugh to look at it.

