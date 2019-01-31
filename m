Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96BF2C282DA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 12:07:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62414218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 12:07:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62414218AC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA9018E0002; Thu, 31 Jan 2019 07:07:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B58EA8E0001; Thu, 31 Jan 2019 07:07:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A48768E0002; Thu, 31 Jan 2019 07:07:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0428E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 07:07:01 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id t2so1218874edb.22
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 04:07:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=u+FaHBTN9Rvp/rKKC4326DtKNKbqEn/u9aBjqOorK1Y=;
        b=EAqgIfHfKt+Iad4LoHv4qaUhbqGAfYGA3oxN1R13cPznWNjfF/9zwO3QhcF+dkb5Po
         COyJ8MMdljhglcXgofkFXd4S/vZWbY8EKIf0oJTaqGdhZsTk+5e+ay5EZ4hhvyBEDVzJ
         mOCTqbj8ZqhFSCSDm50rNEme39VdZwdAQz9TVg4qnqNBHTdoDM5rvRQ84U+8wvi59MVS
         Ng3mjFhudgjbBy2uke+HInj0XexqXUDmW3+JNBFwqwV8t2kac+9RBxpPZKE+Wn5YwS3r
         1cnVwRZpWblsPYe0r9nEJ+Qp9vlMy7p0D1tU2sfuodsvRIPDzmszsVI+gsUwTNSBvuco
         dSxQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AJcUukdSM2pR7tUK65c9yO7BaW4NFry7lBnJclM+MZxX5sC2mqEMvEpX
	hNf9KniGHWL5Lw5Uqsmy2TdOpslaDzVq9lZELWVAU7IPl1CHCqTM8p0+NQVlzTW18zymq4zY5sb
	/zWo7qdSfI7aRPBFrDlMmcJGHE5QLG2MMR6ZZt4e6dEVJrAmXvwnTC4nx53TDN/G/rg==
X-Received: by 2002:a50:ec19:: with SMTP id g25mr33467212edr.38.1548936420770;
        Thu, 31 Jan 2019 04:07:00 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7j1KrLEDie2pUWsj7+dVBo5wIRIyUD/N6sDunShdtZxdjrkn+SMCfv1gxVeeDUsRYeCnp+
X-Received: by 2002:a50:ec19:: with SMTP id g25mr33467164edr.38.1548936419986;
        Thu, 31 Jan 2019 04:06:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548936419; cv=none;
        d=google.com; s=arc-20160816;
        b=T1Cos5RjXJvEa831EefgRkFo8lWDo7GSS2291acKZHfxh4q4SgBsTxxvPWAqsWx8Xg
         z4oJPA1PgDGkpltL/2UcRqZ2Wo/NWEsSWDaQgTbtctTjaOUz6UJo7s2rVONTTPQ7jSas
         DoqIsM91tOM/b7834sVqo+/keLMiblauUbyYsAcgATq8xgxknwdjw/QinqlKzcm4QDsf
         zSSwPoYXB2MFtp7k9Y7HZwMU5OhjbpMCp38RoFtG9Pqr8EhIV9be30O071k6iNA1WoqX
         W+166oih7VSNfwK5Ylj4NuUT1CwxsU54iBO5mqyOrZjsb//Hj0QFwvhvn6trWhvoBMsX
         B2BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:openpgp:from:references:cc:to:subject;
        bh=u+FaHBTN9Rvp/rKKC4326DtKNKbqEn/u9aBjqOorK1Y=;
        b=AapD5I8ui75CKuKeYZmuG68gzkJyCpRodKLxCm7x9O1zRYWFhnpUbso4wH348Qbm2r
         sf2RqALvFFHY0yp7PCihuDtnE4SpW3PPBURfQXUiP22ipt1w2pGNXLVuKrP3Zl2y1J6P
         Ta4tbDx0ths6acYl85LQsWeG3c6PxD4SeRsa3q+FnjuxllkqlDXfJPunX/azIaRQs/uS
         qmK+/szQmrdd9TXHLXwuKuvA4gfIS2KEvki43EMas3SAFOlne8QBKU6Dz3MYEO4ZRD4r
         9ENS6+QNBRZu9yndm5kYZoPxsX3xvWxbAylrauzPvWloqLXzN9tBdHS65HCjFL5U4Wky
         xCsw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k6si2364654edd.269.2019.01.31.04.06.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 04:06:59 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 327A4AC4B;
	Thu, 31 Jan 2019 12:06:59 +0000 (UTC)
Subject: Re: [PATCH 2/3] mm/filemap: initiate readahead even if IOCB_NOWAIT is
 set for the I/O
To: Daniel Gruss <daniel@gruss.cc>, Andrew Morton
 <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
 Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>,
 Jiri Kosina <jkosina@suse.cz>, Dominique Martinet <asmadeus@codewreck.org>,
 Andy Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>,
 Kevin Easton <kevin@guarana.org>, Matthew Wilcox <willy@infradead.org>,
 Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>,
 "Kirill A . Shutemov" <kirill@shutemov.name>, Jiri Kosina <jikos@kernel.org>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-3-vbabka@suse.cz>
 <aea9a09a-9d01-fd08-d210-96b94162aba6@gruss.cc>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Message-ID: <fb914afa-a76c-5678-81e8-ce5736f772be@suse.cz>
Date: Thu, 31 Jan 2019 13:06:58 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <aea9a09a-9d01-fd08-d210-96b94162aba6@gruss.cc>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/31/19 1:04 PM, Daniel Gruss wrote:
> On 1/30/19 1:44 PM, Vlastimil Babka wrote:
>> Close that sidechannel by always initiating readahead on the cache if we
>> encounter a cache miss for preadv2(RWF_NOWAIT); with that in place, probing
>> the pagecache residency itself will actually populate the cache, making the
>> sidechannel useless.
> 
> I fear this does not really close the side channel. You can time the
> preadv2 function and infer which path it took, so you just bring it down
> to the same as using mmap and timing accesses.
> If I understood it correctly, this patch just removes the advantages of
> preadv2 over mmmap+access for the attacker.

But isn't that the same with mincore()? We can't simply remove the
possibility of mmap+access, but we are closing the simpler methods?

Vlastimil


> Cheers,
> Daniel
> 

