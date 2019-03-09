Return-Path: <SRS0=P3wr=RM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7ADBC43381
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 09:32:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E5792086A
	for <linux-mm@archiver.kernel.org>; Sat,  9 Mar 2019 09:32:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E5792086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BAC508E0003; Sat,  9 Mar 2019 04:32:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B5B7B8E0002; Sat,  9 Mar 2019 04:32:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4C3C8E0003; Sat,  9 Mar 2019 04:32:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4C5DF8E0002
	for <linux-mm@kvack.org>; Sat,  9 Mar 2019 04:32:30 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id f2so10602182edm.18
        for <linux-mm@kvack.org>; Sat, 09 Mar 2019 01:32:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=m3YaWiUDayIzwGWxSNd6zwNG8v0UoTSqgCO8vToSRgE=;
        b=H3cGZmIVu/twevrv1o6kOAAh1DSr6Um+WLGLdpjs8ARMCVtU+QgknRABtt+AZztcr3
         3wbirzkkP3PVDcFo5xh2bhBqlL6BeMMa+Fa+t68+iauT9iSfKaUHqDWYhTtC8xnlatZN
         I6f0ZmwQSUOFzcSHUBt4BOyNXIHLOlHOePoWp45o5MIWqCIWAuH6MIqfxR6cUoAFDgTg
         bgANFcFSxS4i2DapTmyg8L22096HLu8UNpjSBvJCRgpEWtElSaqfdUYMFr4R6q7ajWK+
         Bva5fDYYHM6DW4enKh4YRp3gdVSSOWbzDp7ZIeFRv2CNe2QhO7/hZ/YrPft3g86/+mUZ
         ygkA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWqsIAqjlivl7VyYswq1n4akUvL9bP3CDQ6H2qe3UUx9IXTycbX
	IBXjZDFS/yKqO7l43ttIhAqnXCPFhvzsMA/NmDwNaLWzHxeQ2jaAqEFftrszmKIVtHg5g6t/M8G
	cgAgZ+nwwyWx3JIAWzCQaBeMV4McnyDc21GUk+Kq040J2qxCE3ZSYMT77taizp00=
X-Received: by 2002:a50:94d6:: with SMTP id t22mr36592584eda.232.1552123949755;
        Sat, 09 Mar 2019 01:32:29 -0800 (PST)
X-Google-Smtp-Source: APXvYqxioaEejgpJzv8Vhcq595NiX3W07eGsvOmu+Y9DjxIeRyPZQY/R409zewTKRuDzLCB8vso7
X-Received: by 2002:a50:94d6:: with SMTP id t22mr36592558eda.232.1552123948985;
        Sat, 09 Mar 2019 01:32:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552123948; cv=none;
        d=google.com; s=arc-20160816;
        b=jdgTUrYaCfs/cDbc36iiLbadBdc6IazdWmlC0D5izaZZcwcNpjnRa49KMnZ0zE+4VV
         ZAUCRiLYA7aMdsq9Xqp7f03XOwTrK2y8GrNeQb1onYyNpRbTCY2qfXq3PW07fFNaY6NO
         qhQMa8kHVeuk5aB5o/M25+p0fsGZrwOokTB+vJsztPhcut0nujnV6E6QRiWEMu7AuPgf
         hqmOmSJp5wYFJX+GTBokRPI32cqeZxtmgCPa9QyIQfAhGZg7kf9OXJYe9VXMRwKXSq5q
         oD2u3zWhzNdqCxLBkp5sCwDhIUhoZCctqeK4XcBn3F0C288jrhXkbZUWT3RoxzzLFcLS
         AEqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:references:subject:cc:to:from;
        bh=m3YaWiUDayIzwGWxSNd6zwNG8v0UoTSqgCO8vToSRgE=;
        b=ky8DYpDqGUtI3zAFsjYq6Wcj9egBHJRi4gOj6LhgfuEBecXBawRWi7mjQ9jxR2J67w
         vDCNAs488XUIMffLBfcE13iMI8LlpiFig6JbmIfM2PTOb7pvktnOM605890nNf1SFyVx
         +NZjywIpD/VCVx/nzc0Odt1AyTIR/LpYKIRInYgN8SvpTLwJcks9cy0zwC7utyih+fGN
         K7S55lIWXhjECLLbP8ETHMF4k0pOmXGUhz7vVNYCtP4CXhFMvG2HCTs+F56rJ98UrPXh
         yjm71Dj8gR+8oF/ZNMwPUsejRhxaWWYbC1VBHL4FQIC9k+KsYb4PNq7jje/v+EZv32mq
         sRPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id m13si42091ejr.109.2019.03.09.01.32.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 09 Mar 2019 01:32:28 -0800 (PST)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.11] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 3E27B1C0005;
	Sat,  9 Mar 2019 09:32:06 +0000 (UTC)
From: Alex Ghiti <alex@ghiti.fr>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Vlastimil Babka <vbabka@suse.cz>, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S . Miller" <davem@davemloft.net>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v6 4/4] hugetlb: allow to free gigantic pages regardless
 of the configuration
References: <20190307132015.26970-1-alex@ghiti.fr>
 <20190307132015.26970-5-alex@ghiti.fr>
 <ee22103c-5060-e39e-7085-87c07d674cd8@oracle.com>
Message-ID: <416b046e-b1c0-00e1-0773-1dd869f7e121@ghiti.fr>
Date: Sat, 9 Mar 2019 04:32:05 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <ee22103c-5060-e39e-7085-87c07d674cd8@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/8/19 2:05 PM, Mike Kravetz wrote:
> On 3/7/19 5:20 AM, Alexandre Ghiti wrote:
>> On systems without CONTIG_ALLOC activated but that support gigantic pages,
>> boottime reserved gigantic pages can not be freed at all. This patch
>> simply enables the possibility to hand back those pages to memory
>> allocator.
>>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
>> Acked-by: David S. Miller <davem@davemloft.net> [sparc]
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
Thanks Mike,

Alex

