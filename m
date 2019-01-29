Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47AC8C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 09:58:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E03B20881
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 09:58:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E03B20881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1D6B8E0002; Tue, 29 Jan 2019 04:58:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CC3F8E0001; Tue, 29 Jan 2019 04:58:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8949E8E0002; Tue, 29 Jan 2019 04:58:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4558C8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 04:58:20 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id m3so16468931pfj.14
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 01:58:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=0NRfL9GOIyoxY+GY1nSLganS+2HOjHuRBaQ5XaL3c7A=;
        b=OgZ6Qvb1N/loaPBklLfXIQm5iPQtP2hm7JiLauGiFmxaIgyVWeAOcoIDDyIcutndxM
         HyAEnZTJ7Ha14upf1sq0wQBxqNiPZNzPH65oLgdB0HfS/trJRdDcv3vFAfpO0hoRlVwg
         D7K33qTgYf1hZJLIKt4XEQYX/Lk5nU4oIiEQczUfadePIc/zk0FPxijom5rXHhqmWzsB
         lqOEa3k+N01wom0vLNyl756B606fYcrm0flNWLLBTPwv2bEWJrS75PKmRVs24pfLh1UH
         76yHKGhtiVu6SYDCqrp8Ygh6xCW1hYLXNToPZ+1NmWEIZ+XEpZJYkCUrPEQazoeHV7+R
         R8Gg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AJcUukdSRpfF2iKdiCfeQRFsDerTlpez+38pIgeLBwfqh0Mb9Pv7fPyT
	3LlJZzlN4gSb5ROdPW206nIRhnkRX/bL9iVtgA9bwh5s373sFtSZcQdTn+VoOBOYl28YJOnOmoo
	6vkhdju2/lVUX6vY8ZWalI4CqoKjUD93iYod0wmfcsgeyf7mB8sccvQxp2Jz+HTw=
X-Received: by 2002:a63:7c6:: with SMTP id 189mr23460576pgh.129.1548755899984;
        Tue, 29 Jan 2019 01:58:19 -0800 (PST)
X-Google-Smtp-Source: ALg8bN69/woT3pJuSnywT62Npl73BJwrG8+3iHpIa3CFVfc0X5C1hK3n8q03aeccAmcLsqDZkhXk
X-Received: by 2002:a63:7c6:: with SMTP id 189mr23460555pgh.129.1548755899486;
        Tue, 29 Jan 2019 01:58:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548755899; cv=none;
        d=google.com; s=arc-20160816;
        b=lhZ0NNzpvSu72f6qPwucChAb/xyjoJpmO4vpPLz0PBP7DkMTAv1SlWi4pEHwgkm7UP
         u+qw8q7kDbGaV6TQS+Lck5RhFK6hgdC1/zF4zQyHodNr0MgQqaCC0gLatKZjM5vepFPi
         F4zySU5e8pMTNS9C8qCf+TZ8MveePyqclXEjSpYQV3eUuTFpYGVzCn+GaxNPpnyV7cAq
         TAOM8aYnsk8tyYYnt8NeeENtwed21eneJbj6L5NotHtoaFM5bCvkmMSh7PdHyWnoQQE3
         GdctpAX+2IJUJrKIfEyHievsNdEWbt87t/EWN/7z2oblYoxmL24VPUT6chKFnTHUXDE7
         TEDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=0NRfL9GOIyoxY+GY1nSLganS+2HOjHuRBaQ5XaL3c7A=;
        b=U6g4sY1bfKr+0gOfR7R/HwVOoUFiMOz76jlhqNLQEyIdXVl9jZc35DALuraN2aMPAr
         kFGC+Tp4k55HjiEnxwN6JwYTPTbE4uPgyCx0o7IMKShjKaOOiba6IA4eqwNTI5aSPypN
         Xqiix3+i8ZQg+RFVZdzO9odxEfdN1p+a0d6mW2dKpdbr+zv2e9YdZOrPpF8gTU0sfmYn
         Md00+MF6pttO4d2aLrlp0T/ZlYh/NylxCZIEOdFSlldzYgJ6o7pbPF7OQssjTJG2xKJT
         MZms7I9iaFkfbKo38d6WT2/XkfQQbx8UzULJVqYSWC5PP9W0OFUjy5tK5Ht6cwUWe8kE
         8N7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id b63si6437919pfa.250.2019.01.29.01.58.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 01:58:19 -0800 (PST)
Received-SPF: neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43phlB1Pcgz9sMM;
	Tue, 29 Jan 2019 20:58:14 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, "David S.
 Miller" <davem@davemloft.net>, Dennis Zhou <dennis@kernel.org>, Geert
 Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao
 <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>, Heiko Carstens
 <heiko.carstens@de.ibm.com>, Mark Salter <msalter@redhat.com>, Matt Turner
 <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Michal Simek
 <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Petr Mladek
 <pmladek@suse.com>, Rich Felker <dalias@libc.org>, Richard Weinberger
 <richard@nod.at>, Rob Herring <robh+dt@kernel.org>, Russell King
 <linux@armlinux.org.uk>, Stafford Horne <shorne@gmail.com>, Tony Luck
 <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato
 <ysato@users.sourceforge.jp>, devicetree@vger.kernel.org,
 kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org,
 linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org,
 linux-usb@vger.kernel.org, linux-xtensa@linux-xtensa.org,
 linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org,
 sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp,
 x86@kernel.org, xen-devel@lists.xenproject.org, Mike Rapoport
 <rppt@linux.ibm.com>
Subject: Re: [PATCH v2 06/21] memblock: memblock_phys_alloc_try_nid(): don't panic
In-Reply-To: <87y373rdll.fsf@concordia.ellerman.id.au>
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com> <1548057848-15136-7-git-send-email-rppt@linux.ibm.com> <87y373rdll.fsf@concordia.ellerman.id.au>
Date: Tue, 29 Jan 2019 20:58:13 +1100
Message-ID: <87va27rdje.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Michael Ellerman <mpe@ellerman.id.au> writes:

> Mike Rapoport <rppt@linux.ibm.com> writes:
>
>> diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
>> index ae34e3a..2c61ea4 100644
>> --- a/arch/arm64/mm/numa.c
>> +++ b/arch/arm64/mm/numa.c
>> @@ -237,6 +237,10 @@ static void __init setup_node_data(int nid, u64 start_pfn, u64 end_pfn)
>>  		pr_info("Initmem setup node %d [<memory-less node>]\n", nid);
>>  
>>  	nd_pa = memblock_phys_alloc_try_nid(nd_size, SMP_CACHE_BYTES, nid);
>> +	if (!nd_pa)
>> +		panic("Cannot allocate %zu bytes for node %d data\n",
>> +		      nd_size, nid);
>> +
>>  	nd = __va(nd_pa);

Wrong hunk, O_o

> Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

You know what I mean though :)

cheers

