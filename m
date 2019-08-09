Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 989F5C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 13:46:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 325DE21783
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 13:46:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="a4W0NpB7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 325DE21783
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9328B6B0003; Fri,  9 Aug 2019 09:46:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8BB396B0006; Fri,  9 Aug 2019 09:46:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 784256B0007; Fri,  9 Aug 2019 09:46:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 289CE6B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 09:46:28 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b33so60299114edc.17
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 06:46:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LyignUp7I1w3k1JhRB7hSSaZmUScIlvleAzqEtH71gA=;
        b=gVfokerTvunp5DwKtXvoIQj70XM5mctWk2FHSDegg1dSTSHJYC8pyzvX+S1fFNAiUp
         W8IGXlHbvg6j+nQ8kWJL7MwRtJIp1jqfaK7XVt3W/vSnKo8d+V55xWKGKkwr7lm77J47
         nd+LlhOjf6Oh0PmCkTZL7qqMwj06d7vh7ndOM2k1b0X+e9p5+XmhC+H2MSFV7jrzWDmu
         PYrZQIRCjw7f+XkkGB3+pLSFvDUiX1qGTdF93+biH2nVIXwqsxDUMT6Gzqc/JastvBFU
         IX6D46VmI3X+4hsCrJgxVG7F7kVnWwq2fdjFBgCqrWztQuX5fNo1Hii891NgQwecXJHu
         wE8A==
X-Gm-Message-State: APjAAAX8LbZe2TMetwxyMid7N7gvoRZZ88nARJK8HbtaiSRTn6PkbU7m
	+cwSw1nGkRd4XegW65Wv0zQvYY2JbTQaDzLnOqN52lmCmh6S/qgYUWLcrV0K4tLcUEO2dmByvdi
	6VCNC68KUVzfM+rpc2eEn02d35wDbbKwUAZOCZfmsZXhcUCLB2quXH9p5RvvghbJTRw==
X-Received: by 2002:a17:906:4894:: with SMTP id v20mr17833072ejq.120.1565358387544;
        Fri, 09 Aug 2019 06:46:27 -0700 (PDT)
X-Received: by 2002:a17:906:4894:: with SMTP id v20mr17832998ejq.120.1565358386615;
        Fri, 09 Aug 2019 06:46:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565358386; cv=none;
        d=google.com; s=arc-20160816;
        b=B4IIL1KIjrfJLgfZW0/bdBOohyhWyWCtzqcYnTVtjbkl2l9ku0sctICSUvaKqAcZ4k
         71UdL0UVc7VG0fFIokdJovXWXNfWvUilZIO837tLqRyxZxENg8zQsn/C97jnmZ9900XP
         RF+VsftSLriFqhqct+DKWJI19O6R9uuBv3Hd0DjJHdMLjc2sp5Ok4aVdOl6E3+iocJE/
         QhrnB7xXpR+rAzqEVFdwbmzvDqUYVmRDsisvjeN+16pf/dqqLDMGgFV1y+RDjiaAYkjB
         3w7aGkavTT/k34BSsJAO+4WdDobjM+P0FE3ut8UHVxXx6eB5V/mKohdjEN+MbUbWq/g4
         u2dQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=LyignUp7I1w3k1JhRB7hSSaZmUScIlvleAzqEtH71gA=;
        b=MeTPc2nqNiwYejvN5FLd7XM8iweG+aXWApn/kNlxS8GEAfjpkMSmmN2S4U26LAyzPq
         TxWxprBAxoDl9yC6DLNxLnLjq3Pr8eA2HhqwaJYStdgkM6JjYpJGmfxxr2DSQbKYo643
         1kVZZkjROOlIcA4BteeF5+QTuVywcaUuBVLFY8WP7CUvRwe+gMw7nbACH2TnZHG2G+C9
         VgpnfY2FrpKW6B30v3l45+rrb9GTK9KYVNIOkU0suutIQTCF53JWnhTABn+87s+IvctU
         PP5V+pi5QXX2kwO/nge+uCvxhDGAbi1sHYZ4lTJTA0m3b43Dl0qi7CT8lYWbaHoz/oQl
         32ZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=a4W0NpB7;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c4sor81998488edn.29.2019.08.09.06.46.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Aug 2019 06:46:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=a4W0NpB7;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=LyignUp7I1w3k1JhRB7hSSaZmUScIlvleAzqEtH71gA=;
        b=a4W0NpB7Ky7ZNvyTrbh1FeBLRkzD3aPh58RS1Yx4bs/BVTnp45+DINWMGfkbq8hq7Q
         Y3Z4bdj5hgCTeGW+PRshMaXOMxfFs+yMLbXwPTZLqJTcO/dIrpBRkUNMwIYuvyefgxLE
         ghaZnnGxRRWhYKHkI/uJzl52jBCmY6GTaX4J6IMtYXbQlVLgECyZntsud91yKcOGxjq1
         ATUWqTH0gQtzKxNRtGFOYFydwjEzo49N/C0g2sw3KGDcPT84ORGadNZJiyoF1tdgy86l
         pT+EYQrZCc/tezrHEA9IExUAHvjCjPlw9d1k0TydyGhC6W7edZj2zop9pkCTsz+j9sKa
         GMoQ==
X-Google-Smtp-Source: APXvYqxaz13nFHHrpZp/JtkeyPbtXPvJTVD23pHrWjqDjJb17ei5Rg0+DU4QM5tQfP2jLc7hWf/1lw==
X-Received: by 2002:aa7:ccd6:: with SMTP id y22mr21987171edt.274.1565358386098;
        Fri, 09 Aug 2019 06:46:26 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id c15sm16018545ejs.17.2019.08.09.06.46.25
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 09 Aug 2019 06:46:25 -0700 (PDT)
Date: Fri, 9 Aug 2019 13:46:24 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>, akpm@linux-foundation.org,
	osalvador@suse.de, pasha.tatashin@oracle.com, mhocko@suse.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/sparse: use __nr_to_section(section_nr) to get
 mem_section
Message-ID: <20190809134624.htv6jws7hphs4tvz@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190809010242.29797-1-richardw.yang@linux.intel.com>
 <e17278f0-94dc-e0c6-379b-b7694cec3247@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e17278f0-94dc-e0c6-379b-b7694cec3247@arm.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 02:39:59PM +0530, Anshuman Khandual wrote:
>
>
>On 08/09/2019 06:32 AM, Wei Yang wrote:
>> __pfn_to_section is defined as __nr_to_section(pfn_to_section_nr(pfn)).
>
>Right.
>
>> 
>> Since we already get section_nr, it is not necessary to get mem_section
>> from start_pfn. By doing so, we reduce one redundant operation.
>> 
>> Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
>
>Looks right.
>
>With this applied, memory hot add still works on arm64.

Thanks for your test.

>
>Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
>
>> ---
>>  mm/sparse.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/mm/sparse.c b/mm/sparse.c
>> index 72f010d9bff5..95158a148cd1 100644
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -867,7 +867,7 @@ int __meminit sparse_add_section(int nid, unsigned long start_pfn,
>>  	 */
>>  	page_init_poison(pfn_to_page(start_pfn), sizeof(struct page) * nr_pages);
>>  
>> -	ms = __pfn_to_section(start_pfn);
>> +	ms = __nr_to_section(section_nr);
>>  	set_section_nid(section_nr, nid);
>>  	section_mark_present(ms);
>>  
>> 

-- 
Wei Yang
Help you, Help me

