Return-Path: <SRS0=AfK9=QX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 618C0C43381
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 13:15:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0370E222D0
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 13:15:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0370E222D0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-m68k.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96F128E0002; Sat, 16 Feb 2019 08:15:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91E078E0001; Sat, 16 Feb 2019 08:15:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80F1C8E0002; Sat, 16 Feb 2019 08:15:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2AE178E0001
	for <linux-mm@kvack.org>; Sat, 16 Feb 2019 08:15:23 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id a5so5207352wrq.3
        for <linux-mm@kvack.org>; Sat, 16 Feb 2019 05:15:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=/aKBnGVtmV9CYgt1ebj1ZRWuKacuYlUC0X/RbXVV5vg=;
        b=FzGLKMigK5qxhALiBnIAN2S+tIW4FWK/cXVHA59mFpOKMgyVGBr01H8Rh0U0kSJjYA
         XuEvbnsYilsaIQ/EdeI1AZvdSDoSWZSRr8unGDSbthvUxXP2EupCN2E60zichJJGNBeJ
         Www0XIVEWoll0cidsK3d8gxDZT6WDLFxt1yyjmIQCOiM8zjPafFUHUvLrNQqtdivk3/C
         PY9QL0bPwckdessvTQlQCAz8DHiQZyhUb/lKppEoDyZPMXEkKg6zxFCDiACNoUGjlLDQ
         MTSZhOEiLVXEYC9q2TutARh76z8UP5QqeCjJwXLQljT0MA2moehN8P9FWR69+hNrXNBg
         oygQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of whitebox@nefkom.net designates 212.18.0.9 as permitted sender) smtp.mailfrom=whitebox@nefkom.net
X-Gm-Message-State: AHQUAuaiEFLYYz3IdaSNc5KRZMo+61JgmST7luB02qvSAoPJS9PB3eP6
	Gw7M3v6ns0pn5qID1I/RRsQ0L+csgR7sPGcWOpgOb5UVeBQMPNlkk0bcm51EsjBuA+Eg5rWbi7X
	eVKDngqYrTngclpxMhj9FNRXFzX1oQ7kCPZYtMPHoYnZhaUEr3U+bSs+tp4GsK7M=
X-Received: by 2002:a1c:7fcb:: with SMTP id a194mr10102223wmd.51.1550322922739;
        Sat, 16 Feb 2019 05:15:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ian372+2oDyeGUWiG5LJ+vSMBJNCBaqaRjNtW14ejAXqKsdRf0RrVtxRKi3ryLP3l0/1/cK
X-Received: by 2002:a1c:7fcb:: with SMTP id a194mr10102189wmd.51.1550322921699;
        Sat, 16 Feb 2019 05:15:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550322921; cv=none;
        d=google.com; s=arc-20160816;
        b=ydG+me4ScEbo20s9TMyTUx0PVf02AGcajtyOj/CP3zmMn4vsOjWob6DA+Cn8SwT8Xv
         mKdQ/d3OAjXyHBDOHA6TOT61AwdXSgXOLzrBlsQfWZZtExb+tmJMSVwW+RMmG4+bH8jQ
         5Tj0zIcZ9U55axINS4mh1RjKJ64L0nn/mqca7+dIvnQJYb5ogtHreNkbY05HFp/sKffL
         K4G4sBxgosKExLVei0A8vtMMjSZDupWkoNwO80mgS/aqAuoHs0qoBMlxvonVhewpN9Lb
         9OeC2vmGwaGmboOPo30IR0S+J9ODgeH7n9f/SmdceDdMI7Qn0IaIWel+1gpC36O1dLjt
         /J6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=/aKBnGVtmV9CYgt1ebj1ZRWuKacuYlUC0X/RbXVV5vg=;
        b=Vdibh3oPfAprmZp39Wr3gi0qUH03kvoeAuChHde67rWg8ljdjEXf0g8poV8PK0pfoX
         GW5WQBXNWBVmnuB+0fryFvQXELVMMBe3/oIaDDsrxaJ0M1Q1u8lpR0rjvm0ivjnqt8ue
         r0gMU8YlfXpmh37B8YrgMt3F3eyZWGu0C2EEfWBLYSSc2fqfjtTXgtA4hnwahqc1OQxq
         ulvXfqueo4iYcH3ZOXF/pc88Z90AvHmtzt0Ryp/j2THpiy6qcWYirPbKmKnFIz6c7xGn
         cUP4i7icAy5UrI7MTBwOFjxh64bOqvG0AUfzeB2Ca3e4N1Euz2InLLegocKMGMEarfOp
         c2sQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of whitebox@nefkom.net designates 212.18.0.9 as permitted sender) smtp.mailfrom=whitebox@nefkom.net
Received: from mail-out.m-online.net (mail-out.m-online.net. [212.18.0.9])
        by mx.google.com with ESMTPS id v18si560273wru.20.2019.02.16.05.15.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Feb 2019 05:15:21 -0800 (PST)
Received-SPF: pass (google.com: domain of whitebox@nefkom.net designates 212.18.0.9 as permitted sender) client-ip=212.18.0.9;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of whitebox@nefkom.net designates 212.18.0.9 as permitted sender) smtp.mailfrom=whitebox@nefkom.net
Received: from frontend01.mail.m-online.net (unknown [192.168.8.182])
	by mail-out.m-online.net (Postfix) with ESMTP id 441rGJ38jnz1r01b;
	Sat, 16 Feb 2019 14:15:20 +0100 (CET)
Received: from localhost (dynscan1.mnet-online.de [192.168.6.70])
	by mail.m-online.net (Postfix) with ESMTP id 441rGJ29m3z1qqkS;
	Sat, 16 Feb 2019 14:15:20 +0100 (CET)
X-Virus-Scanned: amavisd-new at mnet-online.de
Received: from mail.mnet-online.de ([192.168.8.182])
	by localhost (dynscan1.mail.m-online.net [192.168.6.70]) (amavisd-new, port 10024)
	with ESMTP id 8E9i_dOXwDyq; Sat, 16 Feb 2019 14:15:19 +0100 (CET)
X-Auth-Info: WAZZ1lxIpLiJaGUL7WPeQCu95RDgYXrEcAgkoSQ4XdXOKg7aXAfiS1bzR4aClOM1
Received: from igel.home (ppp-188-174-150-184.dynamic.mnet-online.de [188.174.150.184])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.mnet-online.de (Postfix) with ESMTPSA;
	Sat, 16 Feb 2019 14:15:19 +0100 (CET)
Received: by igel.home (Postfix, from userid 1000)
	id A50CE2C202B; Sat, 16 Feb 2019 14:15:18 +0100 (CET)
From: Andreas Schwab <schwab@linux-m68k.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@ozlabs.org,  linux-mm@kvack.org,  erhard_f@mailbox.org,  jack@suse.cz,  aneesh.kumar@linux.vnet.ibm.com,  linux-kernel@vger.kernel.org
Subject: Re: [PATCH] powerpc/64s: Fix possible corruption on big endian due to pgd/pud_present()
References: <20190214062339.7139-1-mpe@ellerman.id.au>
X-Yow: I'll take ROAST BEEF if you're out of LAMB!!
Date: Sat, 16 Feb 2019 14:15:18 +0100
In-Reply-To: <20190214062339.7139-1-mpe@ellerman.id.au> (Michael Ellerman's
	message of "Thu, 14 Feb 2019 17:23:39 +1100")
Message-ID: <87pnrran89.fsf@igel.home>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1.91 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000738, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Feb 14 2019, Michael Ellerman <mpe@ellerman.id.au> wrote:

> The fix is simple, we need to convert the result of the bitwise && to
> an int before returning it.

Alternatively, the return type could be changed to bool, so that the
compiler does the right thing by itself.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 7578 EB47 D4E5 4D69 2510  2552 DF73 E780 A9DA AEC1
"And now for something completely different."

