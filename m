Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1A8AC282CE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 07:57:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8695E218A3
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 07:57:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8695E218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C63136B0008; Fri, 12 Apr 2019 03:57:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3A5C6B000A; Fri, 12 Apr 2019 03:57:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B29B16B000C; Fri, 12 Apr 2019 03:57:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 61C696B0008
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 03:57:28 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p88so4422793edd.17
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 00:57:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=U+Zpjb8p+CN6O4Gwgv7pJC0J0gR2Ag/ws27+x6KxrDk=;
        b=c1USntIJkA7SWdxoiBi0K6GEuOy7TpMLml1EBshfx92Bm72/n117mHe8YGg6Z0axLR
         OJEgQ76l6YIi35Iu41ep+j/BdKvar0aBTG1s8GJSeHApxUoMDr4Aacu4gd28mBgy6ZkA
         GwmRPekdQwahaytWc8pCe+H5aqh3VqD+jh5lNPuDZ4bAtefVnV9YDbSOz67VKhenMCt1
         C7G1xuR9lUg6j5SR0jhzf1xN+nftZphXKtNIDiq/RRlQK2CiNfpF1QKJu21p0F624P50
         ELylmQna5ufBN/JYhwzPxH0bC+skchis3n4gE+OHUnWjbg8Pxl3n9CwrHDdCYqiBLXUm
         w0/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAWpHOlrU7GT1cYCvAo628Qz4OWQsZzuN2SKLLgrPiI4dvQklx0I
	MzCMwur1Qf2MPXBzhpQm+nHlJ8UZ1tVEcDRu2s/K/VCYdWmBmm3WqbgXv1e88iy8On0wTx1AbWR
	KFxwJulxEAR1Ci5k2CZLWSTsDnMVaYtnIRM637DhRkIOvcCd+Hlzen4/pHnDhlm3ExQ==
X-Received: by 2002:a17:906:938d:: with SMTP id l13mr29869478ejx.250.1555055847976;
        Fri, 12 Apr 2019 00:57:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzodnVF2egfDeqK2SXDmUQMAUiNbNL0gq4eIwe5Cr4jC+ZR7+4j8nfPvlJSGdJjRpj9hQDq
X-Received: by 2002:a17:906:938d:: with SMTP id l13mr29869446ejx.250.1555055847113;
        Fri, 12 Apr 2019 00:57:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555055847; cv=none;
        d=google.com; s=arc-20160816;
        b=lcBDiw13GkIVpEE+2mfhWjIAudzKYOm4syjszSRLnKrrxd6UjqNues8WJxYXuudZe4
         hdr6WKGpKUHRMvU6MC75poAAnxvKb3nYyu+hWdNw3e2C6tN696TJ4XBRGfEAZ2ph6AL9
         8xtoecTKEMwfrGwzNxoBEFTMUWkBz4dbOiB+fJLpV4BLHaoSgeFlVJbSWSK7kLzRyDe8
         /GHQtHSZXDKbd8iNgOY6rGwOAirGKEWTVIWKI2Sz1WPpF0VdGMnW2JrqkHMZS5yyAijB
         maBGn1rYJgyOmpzHcAs2mnGm1v7wmeKj2upPdKABK/rpiIHjKO4BwaIryEIUCT1i+ZO5
         Irdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=U+Zpjb8p+CN6O4Gwgv7pJC0J0gR2Ag/ws27+x6KxrDk=;
        b=kLkSynXLt4ZBxoO6iI4eU9eESTkb7TcTKI23WFTsty008PUsDJnoMza6jK8+BENaJl
         qHFSoaLZcMDvUGIiun0R0DlYKzDjYZsfopFVHChW0OfQE7Quzte4DREPuDWKYTgRyQVp
         45Qxl+wYM67xKiHCEAKmEwWCTdUV+49qg0yfEl2TQrCnhVP2uvyaJKbc/9Crslvieqbw
         OMH9af9uhaZbkSfB9s3gvVK5fk+L8Bug1q9aS1HyclLDXKeyIhfdzQN0prW2Gveii5B2
         FtIAEwu35YblH5zr2HUdGwyU8Rj4Xql2RMdnQr4FcenSdr7rLoohgvD97JHeZae6BBvp
         O2iA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m18si1728485edr.89.2019.04.12.00.57.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 00:57:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5BF48ADAA;
	Fri, 12 Apr 2019 07:57:26 +0000 (UTC)
Subject: Re: [LSF/MM TOPIC] guarantee natural alignment for kmalloc()?
To: James Bottomley <James.Bottomley@HansenPartnership.com>,
 lsf-pc@lists.linux-foundation.org
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, linux-block@vger.kernel.org,
 Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>,
 David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ming Lei <ming.lei@redhat.com>,
 linux-xfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
 Dave Chinner <david@fromorbit.com>,
 "Darrick J . Wong" <darrick.wong@oracle.com>
References: <790b68b7-3689-0ff6-08ae-936728bc6458@suse.cz>
 <1555053293.3046.4.camel@HansenPartnership.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <68385367-8744-50c3-8a81-be3a4637ea80@suse.cz>
Date: Fri, 12 Apr 2019 09:54:07 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1555053293.3046.4.camel@HansenPartnership.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/12/19 9:14 AM, James Bottomley wrote:
>> In the session I hope to resolve the question whether this is indeed
>> the right thing to do for all kmalloc() users, without an explicit
>> alignment requests, and if it's worth the potentially worse
>> performance/fragmentation it would impose on a hypothetical new slab
>> implementation for which it wouldn't be optimal to split power-of-two
>> sized pages into power-of-two-sized objects (or whether there are any
>> other downsides).
> 
> I think so.  The question is how aligned?  explicit flushing arch's
> definitely need at least cache line alignment when using kmalloc for
> I/O and if allocations cross cache lines they have serious coherency
> problems.   The question of how much more aligned than this is
> interesting ... I've got to say that the power of two allocator implies
> same alignment as size and we seem to keep growing use cases that
> assume this.

Right, by "natural alignment" I meant exactly that - align to size for
power-of-two sizes.

> I'm not so keen on growing a separate API unless there's
> a really useful mm efficiency in breaking the kmalloc alignment
> assumptions.

I'd argue there's not.

> James
> 

