Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B187FC43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 13:59:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F5A020850
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 13:59:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F5A020850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE4388E0003; Fri,  1 Mar 2019 08:58:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E92FE8E0001; Fri,  1 Mar 2019 08:58:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D849F8E0003; Fri,  1 Mar 2019 08:58:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 823358E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 08:58:59 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id i64so4843531wmg.3
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 05:58:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=LupN2ljiH4f91NrMr3+ld65I3bN9aXbjwrHcAMPt/JQ=;
        b=EPP3fyzvj7HmSfaTIv0FtzGUMHV8R8GuVSF6MylYxtyhz17gsHpoeyYM8b+d7HzdoL
         2w0iXS3u3kiHB8KmEZUN/7Zu1jDB/7XdssBcjRL0+BOWjBKYCyxUY7jJ8rAEEkp236n/
         3H2Fa9HXzL0syHJTW6XCgrJeV/eeCxh+jCpjR9IYi9Tu/2d/5QMVdtPL185mLDYcAjUS
         CVOwatj9f3cfaZ44LtVnohP2wIOhn1+D3IkfdttIt2WJyFaQpr5EwubUR/k2ExX452p+
         WiFf9XTq9NOzW7xdW8c+3tvXmUTIW0fjzCAmfYLZ2YVWd1q/nfLJiVShpTeXSRwnXDmi
         Dfbg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUQkUe3yYFwsjFkqDCRdZNPWQpWLPio9mFO5DPRcTcMq3JIm8KI
	ZYRNeGPvXGuv/J0PIHa/jNYkX45aXAT2zl16E8IQxkJaQ9Q7u5MCEq7r46y5n7NcUkjZK0pu+op
	3BlzDe73uPCUXSDFIeFQkUlGv7BTLDjc/sXRdM3fl63zw4BWFfleOOejlOTfOIUc=
X-Received: by 2002:adf:c704:: with SMTP id k4mr3747650wrg.142.1551448739015;
        Fri, 01 Mar 2019 05:58:59 -0800 (PST)
X-Google-Smtp-Source: APXvYqz+4Ql/ugTSigxqibW/LuRMKbltcaY0yuKNLAD3EAjv23U+Bzukacvt0+UJhgiKlyb+6Fvb
X-Received: by 2002:adf:c704:: with SMTP id k4mr3747605wrg.142.1551448738111;
        Fri, 01 Mar 2019 05:58:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551448738; cv=none;
        d=google.com; s=arc-20160816;
        b=tx+0x28qDMbWCKDW0IGanArKDEV1Cm7yi+1o/21DV/OtFEChE0FsjXVcWWVW7PV2NM
         1HaDCx0a/eQFHrBjaBQx/ShVSTfKp94iPOUJnOSYZz4pGikCpqRkwx0pBh0sQR+mjFnn
         XUAM88L3cq+JjwK0iGjelwIiuPDs9cvWNucOhGbSAECGsWTRyBVYqvkwqhgh8VW0s0eJ
         5z2xPMmqLR9FliNg0zdXPIeQOEhOABMzoXxbrOBA61Ova3snSZBYMgqzka4oSBP6rBlh
         xHA2J91bZiyc2qYl24zkQaNlHVRVg2n7S7FYeuo8FpMyvOemP9zOAvzhOaOKWn4OLvYP
         zFVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=LupN2ljiH4f91NrMr3+ld65I3bN9aXbjwrHcAMPt/JQ=;
        b=qEgkxlZbpoar2AePWBE96f8gv/B4yGDZIHpDaG/gVPG+66VF/M1lioQYHPmJcIhqnC
         Gao9sCsdw9jtZhhsI/hupWIMkZTgu4Jy5LzvRWAjmFwZS6NKrJ+4ZDCOBVKqYBgCqGrt
         4G2L4U+bXlVW/7LlsEeLkNNrZdh15kHfcwIBkk7Z2XPos2uDvfcplf5GGjbeJJDqDJ2K
         KojNnrtyNQZBhmMQ22Ksi2U5hkGNHMfABkRb38fjBTcIDOI8mnUIQtpQxph9NYeiVd0X
         1s2KoccDb/Pa/xUTO89lxQcnqJ1S7GHXeZdL88M1fCZPDqFhcKqTqd9Dl7DbQLga6nLk
         dyWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id m16si15591116wrg.80.2019.03.01.05.58.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 05:58:58 -0800 (PST)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 81.250.144.103
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id DFAE9FF80D;
	Fri,  1 Mar 2019 13:58:49 +0000 (UTC)
Subject: Re: [PATCH v4 4/4] hugetlb: allow to free gigantic pages regardless
 of the configuration
To: Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Dave Hansen <dave.hansen@intel.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S . Miller" <davem@davemloft.net>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 sparclinux@vger.kernel.org, linux-mm@kvack.org
References: <20190228063604.15298-1-alex@ghiti.fr>
 <20190228063604.15298-5-alex@ghiti.fr>
 <9a385cc8-581c-55cf-4a85-10b5c4dd178c@intel.com>
 <31212559-d397-88fb-eaec-60f6417436c8@oracle.com>
 <6c842251-1bed-4d79-bf6d-997006ec72e2@intel.com>
 <6ea4119a-0ecb-511d-3aab-269004245a08@oracle.com>
 <1cfaca88-a219-d057-3ab8-37fb1c1687d6@ghiti.fr>
 <f7c94eb5-d496-7e24-d44f-17eaff287012@ghiti.fr>
 <027de1e2-a9cd-8ba7-859b-ee803937340a@suse.cz>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <4bff265e-e03c-6d74-c09f-a89b74009feb@ghiti.fr>
Date: Fri, 1 Mar 2019 14:58:49 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.5.2
MIME-Version: 1.0
In-Reply-To: <027de1e2-a9cd-8ba7-859b-ee803937340a@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/01/2019 02:33 PM, Vlastimil Babka wrote:
> On 3/1/19 2:21 PM, Alexandre Ghiti wrote:
>> I collected mistakes here: domain name expired and no mailing list added :)
>> Really sorry about that, I missed the whole discussion (if any).
>> Could someone forward it to me (if any) ? Thanks !
> Bounced you David and Mike's discussion (4 messages total). AFAICS that
> was all.

Thank you Vlastimil, I got them.

Thanks,

