Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39055C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 23:23:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2DB0206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 23:23:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2DB0206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 458EF8E0003; Wed,  6 Mar 2019 18:23:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 408208E0002; Wed,  6 Mar 2019 18:23:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F75B8E0003; Wed,  6 Mar 2019 18:23:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E49DC8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 18:23:40 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id q21so15322056pfi.17
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 15:23:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Ovdoz3WLJE3wW+s01LjPOLg6bb0NHObOQSg10b+ECEU=;
        b=Pcu+DK7kydVe62xaywu/LCeuc/nttAkf/9mRIjOLiLdrl+AeF2J8N2Eq8Sb4S3Mp9F
         Ck1Kj+OfDTn9Q0sDuGzRzvKeHABMWMqJ6Uc3ZVB5H8gJyBysKg1gx4FWRBl1ho99w6CS
         dR8hucSKKQyU+/F8CJtHHUkM3f8k1vzXPsbHCluFDFJPU2h/CA093XnY1yDanp3rbbT+
         r6SPAu+IgtiMfYm1cNs52rzLcfo4OrenAKrhR9Z4cgm9Lle4nwL4nTtizyMuYx6YJg/T
         fY/iK2O4v6udLoEwDCu0BS8qPinVbHdR5egpFnmdoY2GpGBZJFi4sJzBxWEIafQwknHG
         hkWQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAXhy9EiJGzs7hicfILcAgp3WPrDKjpT8tWEOAgX9K8JwvaJAInO
	MwUcmaBDEvjYNzV5+ShF7XJVXul9o7g5oR7TC5AW/4WW54rGDC1l/bMmYi2BgS3TD8MmZ9mfd+B
	kjwvGWxG1AmrmtxwvcZ2ApKeQRfc11FYE/3v+rp+fS+40mkIdobJwFd8Kvmx6Io3Khw==
X-Received: by 2002:a63:1b4d:: with SMTP id b13mr1447460pgm.388.1551914620595;
        Wed, 06 Mar 2019 15:23:40 -0800 (PST)
X-Google-Smtp-Source: APXvYqzK/L6iNxXkSIJqZzVGSH5dIPu+PbzL78SVNxLryqicYAp/4Y+sCG1cFF8eoT8D0hfiXhpo
X-Received: by 2002:a63:1b4d:: with SMTP id b13mr1447406pgm.388.1551914619673;
        Wed, 06 Mar 2019 15:23:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551914619; cv=none;
        d=google.com; s=arc-20160816;
        b=IhTG1VCwioN/KnADTKf3pCXalxpmkuj7774XR8noEDJSX8iLjx5TvRGxV6M2kKSTPh
         Z6bYlCHOLqveo3NfJ3YdejIyUeGc9WJbTZtMqc9ZqOAlYhjUCASROjRuCIK9A4MSKlLW
         u1dnr37Zv9VnpDuV+mPjplg1Og0xNZEQrEMeS2TFoGdlh1slR+5ktE2hpAwsa56jYYUD
         uFEwIfQmxYxX20Rd9J0SO9b0hav62rS0te+d5Ws6UGlLwW/tJH9iFsUJsryBpGAieSed
         qZr/Cwe+8RWd0luYPBDSuwoiY/VupbqixVamhQli76CoUkBl83z6Ea8IqSXvTaz7OxnI
         XhNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=Ovdoz3WLJE3wW+s01LjPOLg6bb0NHObOQSg10b+ECEU=;
        b=W/E8+795nQh7SRm2Yb1X47iTMhzKB6UHMaiYDX8DGL2CXk/GnV3eN+YvTRJYPLqDLt
         LKSy6M6+1IZESTkMV21fpXdDnAbF4T59D3rjURzBPGdTzR3ZMi4C4Cq7lbf+NN1K1plG
         jYIn3bwhzwqWBp7hpa2KpOCjJqG/QeNxk41s9vDRKKJVB7k+rR9hb6VDtAzqdRpNPvu5
         rOjFEvuigqwGLmPI2XGYbR4oiB9DxOBr9NeV0C2XK1uhICmk5tMm9eICH/m4Ej7NEsc5
         F0/ICCxHAvg7j6icCOvvGPwURVldwV1e96H/e5D3ZGw+AXxBIwqesYoneyN8fMDCyKVn
         92KA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i63si2878472pli.40.2019.03.06.15.23.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 15:23:39 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id CD598737C;
	Wed,  6 Mar 2019 23:23:38 +0000 (UTC)
Date: Wed, 6 Mar 2019 15:23:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds
 <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-api@vger.kernel.org, Peter Zijlstra
 <peterz@infradead.org>, Greg KH <gregkh@linuxfoundation.org>, Jann Horn
 <jannh@google.com>, Andy Lutomirski <luto@amacapital.net>, Cyril Hrubis
 <chrubis@suse.cz>, Daniel Gruss <daniel@gruss.cc>, Dave Chinner
 <david@fromorbit.com>, Dominique Martinet <asmadeus@codewreck.org>, Kevin
 Easton <kevin@guarana.org>, "Kirill A. Shutemov" <kirill@shutemov.name>,
 Matthew Wilcox <willy@infradead.org>, Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/3] mincore() and IOCB_NOWAIT adjustments
Message-Id: <20190306152337.e06cbc530fbfbcfcfe0dc37c@linux-foundation.org>
In-Reply-To: <nycvar.YFH.7.76.1903062342020.19912@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
	<20190130124420.1834-1-vbabka@suse.cz>
	<nycvar.YFH.7.76.1903061310170.19912@cbobk.fhfr.pm>
	<20190306143547.c686225447822beaf3b6e139@linux-foundation.org>
	<nycvar.YFH.7.76.1903062342020.19912@cbobk.fhfr.pm>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Mar 2019 23:48:03 +0100 (CET) Jiri Kosina <jikos@kernel.org> wrote:

> 3/3 is actually waiting for your decision, see
> 
> 	https://lore.kernel.org/lkml/20190212063643.GL15609@dhcp22.suse.cz/

I pity anyone who tried to understand this code by reading this code. 
Can we please get some careful commentary in there explaining what is
going on, and why things are thus?

I guess the [3/3] change makes sense, although it's unclear whether
anyone really needs it?  5.0 was released with 574823bfab8 ("Change
mincore() to count "mapped" pages rather than "cached" pages") so we'll
have a release cycle to somewhat determine how much impact 574823bfab8
has on users.  How about I queue up [3/3] and we reevaluate its
desirability in a couple of months?



