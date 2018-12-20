Return-Path: <SRS0=PcJq=O5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 441B1C43444
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 15:32:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0186A217D8
	for <linux-mm@archiver.kernel.org>; Thu, 20 Dec 2018 15:32:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tVSeAEbR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0186A217D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A79D8E0009; Thu, 20 Dec 2018 10:32:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82E848E0002; Thu, 20 Dec 2018 10:32:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F7E28E0009; Thu, 20 Dec 2018 10:32:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1581C8E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 10:32:41 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id z10so2695177edz.15
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 07:32:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yZ2aiobkLaX1mj7/iX/Gog/lPO+/IY+yMX/S2ugNC9k=;
        b=VQxdOA1Isag5370BvPHApiQV2b70+XyV2xqJtSPEsIxt9s2wKuk4wzRyX6/4LyjNfb
         FfBcqnfBs129dPCULJkuj4Fl9J1t5/g/31s1skPeiM24GhlAsOu+NEHOC69aziBgL6A7
         R+hGcdjtGqvUNqJCR+tj6FD/5nmJ3FaBL3DBSOVAsZV1N2rlBaDJGxboyou8zQ2ecBGy
         ZWD+3rqTmLPcM+07d7FcjQ8X+eRkNJvfbMIf7wVQKEUuUGk2dkFl3Vh1tbQZFd9g68w3
         bp1RElMzmSo+Ct3d9QOUEyfIFNxnHw6xS0qZrSW5VK0Q9b2eNmVLD1UJP/HFPLPpnroa
         nyxg==
X-Gm-Message-State: AA+aEWasC6xhFUPiJmd+lEAaT8gxK+fudH5xaJnZgXPalm/LJHI3v3kf
	A667iVHXCfPoCLhOKAm74lr/ikaYdVtB7hGaOIRS8PQ3Pxn52WuYncU1htjtrG24yn3UYmKDRUN
	MWWLJUsgVKiXjBgK5Thy1zwuxqiWZ/PlgQwJtyKcfTDl+EsD+TPSoX/qDhyyje0C1/USn1ptAX4
	wXqUj2ZMtUjtvjvm3g+Xw/ZoiJFTTvsxK5mxLZLdxX44DGvwpGoM5K4qHVehYTTdZWASh2AyMqZ
	o6AtLZu09wJbRGiVVGyjkTOVgEYX9rfGBWLuNUlBgoj58sqpu3dA7uY4KyundgNk6aCjTBmuiWy
	j+k88r+es5l6UkVzBZtVRJhaVS2ixa5A2tW+CwsAhgKH6rcpidkD6srlFaE0rK4kcXkMp517fN2
	X
X-Received: by 2002:a17:906:d507:: with SMTP id ge7-v6mr19597822ejb.78.1545319960551;
        Thu, 20 Dec 2018 07:32:40 -0800 (PST)
X-Received: by 2002:a17:906:d507:: with SMTP id ge7-v6mr19597761ejb.78.1545319959321;
        Thu, 20 Dec 2018 07:32:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545319959; cv=none;
        d=google.com; s=arc-20160816;
        b=hJX3A1uULfXqcG45iTYbiFMuvvIwk9lXvHd46yL7rnHgf3MoAA3szjpoVmmUNGVgi7
         Lqz7rgzLtOmU3hQ45oRrCynlOw3YWBqDmFSBiVACz4n5M1kVKlBTX3cVqQ4pG92RKNjK
         /bfwh3ueWK0j+XrPL+RqlzCqI/P3zZbE7Te1F5dK8nZJ/48yjxF48XmYEKvHXE7g8i0T
         j7flTDigoHGZu/OVZy5wntKrbCJsaLzr9aoH3iARxo49iBYQlI+bDAp2jDxvNA5m11rm
         oh5WFmVM9jll1KyDB/5H6mNfyZqDiVPhlmgXkKVUa3ApoobwegONjZl9sVdKAGdHbufy
         IIaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=yZ2aiobkLaX1mj7/iX/Gog/lPO+/IY+yMX/S2ugNC9k=;
        b=fXWkFD3GNJy2KxMAffUMfLzUj54lIsYrRPIGPcg8XNFlQShkuugnOsgBv5xMOiCTnp
         VMib99WBJ8FYk1T17THAq3XKvTNX6bDR0E9ej53+/4qDpOAdnqIdSKXsUmW1y6L4lDQ2
         li6Rq0Qhv3ckXn9MZSsAxSsBU1+7C3qFemGipMRJJRAXLiEM69JBIi6M7UoEhAeCbZiR
         X2sQUbfdZeBg6RJAk1PeF+S2yxSZlnKXmnSB/OVXb0kzD7cMiO/0cCZ3HXl5FKfQPOXx
         awHqJE8tcD10IFOaYhf8O3WsUGP7KuN7+bqVcsGhMCay7LEHjvnfGQPHPSc+lGe5xY4h
         45tA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tVSeAEbR;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l52sor13175143edc.17.2018.12.20.07.32.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 07:32:39 -0800 (PST)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tVSeAEbR;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=yZ2aiobkLaX1mj7/iX/Gog/lPO+/IY+yMX/S2ugNC9k=;
        b=tVSeAEbR6wdF6eXzUZjOktzwYsSBXMTdg11DaYOZYq3nb4vHWnUwbt73LstDAnlPw6
         xK4m+4TgRM59kSQz7akyoirOcHpEcsUHLmP66v8lx/2MVps+aS/Cfuk1/1wHYFg2H7Rg
         2SO4xaJzXDzxynY20Q23n+LKYGTQVMdq8J5qjKz/cTPWnG+NLWC+xkcy7b7T2ea9Aq54
         Z9IEPclP3ZZ/SCfEW8xqzDhoAqIOHLJ9y8J8572E18XIlY+pN91CWaIO/LJzVVjcCa2v
         XA2bN7ZnqTX7XUtKMwxUTbI51LEOlDC5TrKjIEGPDoboaa+gqfeO6P2uNb51mb8pXJrl
         RcOA==
X-Google-Smtp-Source: AFSGD/WLLklun1d9aghpKwSfLr9Gz+dO8aM+97QJvy3AJnYcZHagAFnVRLbugZ5hv61/v65aESaubg==
X-Received: by 2002:a50:880d:: with SMTP id b13mr23562775edb.68.1545319958930;
        Thu, 20 Dec 2018 07:32:38 -0800 (PST)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id i46sm6148860ede.62.2018.12.20.07.32.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 20 Dec 2018 07:32:38 -0800 (PST)
Date: Thu, 20 Dec 2018 15:32:37 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@kernel.org>, Wei Yang <richard.weiyang@gmail.com>,
	akpm@linux-foundation.org, vbabka@suse.cz,
	pavel.tatashin@microsoft.com, rppt@linux.vnet.ibm.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm, page_alloc: Fix has_unmovable_pages for HugePages
Message-ID: <20181220153237.bhepsqw27mjmc4g5@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181217225113.17864-1-osalvador@suse.de>
 <20181219142528.yx6ravdyzcqp5wtd@master>
 <20181219233914.2fxe26pih26ifvmt@d104.suse.de>
 <20181220091228.GB14234@dhcp22.suse.cz>
 <20181220124925.itwuuacgztpgsk7s@d104.suse.de>
 <20181220130606.GG9104@dhcp22.suse.cz>
 <20181220134132.6ynretwlndmyupml@d104.suse.de>
 <20181220142124.r34fnuv6b33luj5a@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
In-Reply-To: <20181220142124.r34fnuv6b33luj5a@d104.suse.de>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181220153237.TEeKAfK4O3XEb-7pIRzU_moZgABHHTL_NRnRSxhK-ks@z>

On Thu, Dec 20, 2018 at 03:21:27PM +0100, Oscar Salvador wrote:
>On Thu, Dec 20, 2018 at 02:41:32PM +0100, Oscar Salvador wrote:
>> On Thu, Dec 20, 2018 at 02:06:06PM +0100, Michal Hocko wrote:
>> > You did want iter += skip_pages - 1 here right?
>> 
>> Bleh, yeah.
>> I am taking vacation today so my brain has left me hours ago, sorry.
>> Should be:
>> 
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 4812287e56a0..0634fbdef078 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -8094,7 +8094,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>>                                 goto unmovable;
>>  
>>                         skip_pages = (1 << compound_order(head)) - (page - head);
>> -                       iter = round_up(iter + 1, skip_pages) - 1;
>> +                       iter += skip_pages - 1;
>>                         continue;
>>                 }
>
>On a second thought, I think it should not really matter.
>
>AFAICS, we can have these scenarios:
>
>1) the head page is the first page in the pabeblock
>2) first page in the pageblock is not a head but part of a hugepage
>3) the head is somewhere within the pageblock
>
>For cases 1) and 3), iter will just get the right value and we will
>break the loop afterwards.
>
>In case 2), iter will be set to a value to skip over the remaining pages.
>
>I am assuming that hugepages are allocated and packed together.
>
>Note that I am not against the change, but I just wanted to see if there is
>something I am missing.

I have another way of classification.

First is three cases of expected new_iter.

             1          2                        3
             v          v                        v
 HugePage    +-----------------------------------+
                                                  ^
                                                  |
                                               new_iter

From this char, we may have three cases:

  1) iter is the head page 
  2) iter is the middle page
  2) iter is the tail page

No matter which case iter starts, new_iter should be point to tail + 1.

Second is the relationship between the new_iter and the pageblock, only
two cases:

  1) new_iter is still in current pageblock
  2) new_iter is out of current pageblock

For both cases, current loop handles it well.

Now let's go back to see how to calculate new_iter. From the chart
above, we can see this formula stands for all three cases:

    new_iter = round_up(iter + 1, page_size(HugePage))

So it looks the first version is correct.

>-- 
>Oscar Salvador
>SUSE L3

-- 
Wei Yang
Help you, Help me

