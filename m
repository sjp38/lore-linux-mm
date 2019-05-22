Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA87EC282DD
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 17:40:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75F5921019
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 17:40:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75F5921019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE69D6B0005; Wed, 22 May 2019 13:40:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B714B6B0006; Wed, 22 May 2019 13:40:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5F656B0007; Wed, 22 May 2019 13:40:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 548016B0005
	for <linux-mm@kvack.org>; Wed, 22 May 2019 13:40:25 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t58so4646029edb.22
        for <linux-mm@kvack.org>; Wed, 22 May 2019 10:40:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=r+LbwVtnREL8J4jW0/7rDfOqTAfm41yZBCnR4hEDOY4=;
        b=VF6IyeEEmrVXlLlskXb8xKVkw6twaN+JwLpGbZ9UbFhDEPo4WDBZ+1yUZ5AIOHK03F
         3Srn8P4xnX/xIvRT/GGKSbasGK7Igsc65wZlAQUcvS5C0od2iC3j8aUpJ98bLIm6j+F9
         Do+QEQaokIAEk8rAFWqTVUo9cNK5ddZZxFxEyBXj0/3H++RN21QQ+/uzr2xZ6Pq4KLyG
         U2OAUiiSMg+9GN/2PfBsRwuTZL/Xo2f/7Mp6yjSv1zwW3obmc87+J5BzKYIDFxLbbHD1
         NeehXKy/0NQDiHE3pUE/ldungZ+0PV/cL+961+w3lk2a1Knb87TSl6Iow+V96k94y6Oq
         M8Qg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAVnPtksqDHFBiDDEICG0oYO8HnN2V/jUHYY+bEft7ovOY1DtWcN
	RAJLFUBMKXwW+WdD9YO+NFtXVtFVoSiT89bkEytrWd0F8bTFCJom6ejnwCAg/1lJa3VRfTybEkx
	iPytdnU4WvHbZ9ZGJlDX96Rwg15fAEGejj5RV9ufbkhGH5kchEN1OQuuyERjtUvQ=
X-Received: by 2002:a50:90af:: with SMTP id c44mr89876159eda.206.1558546824922;
        Wed, 22 May 2019 10:40:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzL3IbccgF6IFz755Fg7imr8CEFmGpquk0a77yXhmFQ0rcgDhlvRQzNfZYCVoE2bcLlFvhP
X-Received: by 2002:a50:90af:: with SMTP id c44mr89876065eda.206.1558546823933;
        Wed, 22 May 2019 10:40:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558546823; cv=none;
        d=google.com; s=arc-20160816;
        b=FzA3wjGkzX1quizZYibDPZMtSAhQkarc59pCOimVlLCs8icH/8M7dfgeyTzujBHXNy
         VR7Fi+SI2M9iwnJeUz3Vb1mAa39P4XIb2oLMcX3S7VEL7B6H9g76f84myepHirXf4flh
         zx3AlggpiQIkmJL2zNxZfifz3z8iHLk9wCUAhGXITC9nwbsW3CVlD3BBm8uGv9z80Pny
         /HaVT92GxIOJGcna3KMZm20PQQTwQHj7vMHZ/xu02wz8XCbpp6lKOx8zGlg7SrfO7AEz
         Nj/S26vn6qUsMvoSL58JaNz+hhX0zxNKl5KqXAfcQK+Z81d6lF0JQO3NZGNeLF2no0lX
         n44w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=r+LbwVtnREL8J4jW0/7rDfOqTAfm41yZBCnR4hEDOY4=;
        b=RtDfBdOUY0/wrJAl1RHbC9FNynM7633HRyGlbnub2aI34st8a4tCKiB0yZioapXRgM
         Bm8o1Nf4zkDjd9Any6/nQpVZAJXJHtd5SRY59QDZaAIObXUachGth6vTVT+nffPpdiPH
         Z9TUxK6pd02FBtMIOFoINbd6vaUo6o1Pkw+cGDij34YzoiFYiQlXMJnB9TKwlTgOW8I6
         O9w17hwu/xsVK6wT3LJhdSbjl0UQz0I+VSobPQsvcec6H4fCX6zDNCH8DhjedJ+tyklG
         0d7b4slDAVY/aojVAmrcfc8FkM3MNrKiAZEuRRgDSjPUT6JNTRKfMdeet9jV7LFXm/83
         z47A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id d33si1239194eda.62.2019.05.22.10.40.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 10:40:23 -0700 (PDT)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::3d8])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 39F1515002414;
	Wed, 22 May 2019 10:40:20 -0700 (PDT)
Date: Wed, 22 May 2019 10:40:19 -0700 (PDT)
Message-Id: <20190522.104019.40493905027242516.davem@davemloft.net>
To: rick.p.edgecombe@intel.com
Cc: linux-kernel@vger.kernel.org, peterz@infradead.org, linux-mm@kvack.org,
 mroos@linux.ee, mingo@redhat.com, namit@vmware.com, luto@kernel.org,
 bp@alien8.de, netdev@vger.kernel.org, dave.hansen@intel.com,
 sparclinux@vger.kernel.org
Subject: Re: [PATCH v2] vmalloc: Fix issues with flush flag
From: David Miller <davem@davemloft.net>
In-Reply-To: <339ef85d984f329aa66f29fa80781624e6e4aecc.camel@intel.com>
References: <a43f9224e6b245ade4b587a018c8a21815091f0f.camel@intel.com>
	<20190520.184336.743103388474716249.davem@davemloft.net>
	<339ef85d984f329aa66f29fa80781624e6e4aecc.camel@intel.com>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Wed, 22 May 2019 10:40:20 -0700 (PDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Date: Tue, 21 May 2019 01:59:54 +0000

> On Mon, 2019-05-20 at 18:43 -0700, David Miller wrote:
>> From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
>> Date: Tue, 21 May 2019 01:20:33 +0000
>> 
>> > Should it handle executing an unmapped page gracefully? Because
>> > this
>> > change is causing that to happen much earlier. If something was
>> > relying
>> > on a cached translation to execute something it could find the
>> > mapping
>> > disappear.
>> 
>> Does this work by not mapping any kernel mappings at the beginning,
>> and then filling in the BPF mappings in response to faults?
> No, nothing too fancy. It just flushes the vm mapping immediatly in
> vfree for execute (and RO) mappings. The only thing that happens around
> allocation time is setting of a new flag to tell vmalloc to do the
> flush.
> 
> The problem before was that the pages would be freed before the execute
> mapping was flushed. So then when the pages got recycled, random,
> sometimes coming from userspace, data would be mapped as executable in
> the kernel by the un-flushed tlb entries.

If I am to understand things correctly, there was a case where 'end'
could be smaller than 'start' when doing a range flush.  That would
definitely kill some of the sparc64 TLB flush routines.

