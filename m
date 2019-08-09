Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CB21C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:45:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44B682171F
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:45:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="r+rAYd5A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44B682171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E56F56B0007; Fri,  9 Aug 2019 05:45:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E06E66B0008; Fri,  9 Aug 2019 05:45:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF6256B000A; Fri,  9 Aug 2019 05:45:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 986BE6B0007
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 05:45:03 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id q9so59394191pgv.17
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 02:45:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Ge9zDnKeP5Zu0nmntU1cSXLgT4EnpnKS+7IQa6koc8o=;
        b=qPHK1yar4WXl0R3Oeo7JOR13NFOT88A+/tyHS3KuaJxzWFDNlviFLqlZ/XOjmWNWC8
         AMBRro/b2L2nsYzM4q109dSMV2fQt4z12H9W4CyhiuDUoXptQQGJPWE2+woSb7o+tpcX
         fZJsfmbwBb4vFGEhJUQFwnC6c5xGAUoqt6Fi5WDSdRFosR2+8y5wGw3BNiNksKg5peIe
         1G9T9ZtTW449gKcUw1l2185pKJOMVpnJm4iQx+ERsJpscx0o5Dxt+fM9PzbTYV30fmLS
         exuJMq9ALk+sF54828FTEZYknqidJc7WEYEQAEjMTO6QXsgRF9htl9QI4R5FVNBp0/tz
         V7mw==
X-Gm-Message-State: APjAAAXSLpFDSF1vNqfzEYKu0211ssPCgE7oRaq55hHzYH5hpDcI9/iH
	+f/OIejiO/WHCH72dtqEw6IUqC7aBI3SN6IvBEebBn8WXkE/qVVoJEDnEboICy7vR7Z7rMgF+w5
	0SJpsNhccHbRy0QdrfD3OF3sZJXe3jn99hcRoxa7b0inL2kH6r5Kyu8gcuZXyhtTycA==
X-Received: by 2002:a17:90b:8cd:: with SMTP id ds13mr8104302pjb.141.1565343903121;
        Fri, 09 Aug 2019 02:45:03 -0700 (PDT)
X-Received: by 2002:a17:90b:8cd:: with SMTP id ds13mr8104260pjb.141.1565343902493;
        Fri, 09 Aug 2019 02:45:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565343902; cv=none;
        d=google.com; s=arc-20160816;
        b=nGiut9dLdN+76iHb4aUgiFBsem1xvdWIQsjt2lIrra5qVR0zHSZVzVyTSDACpcfnGW
         T73EfILEfztuNOdBg2NcjSs/q6C3rEtls+jnbVzH0Lstz30Z/i2mMUejpnwxEQGwbCVX
         7zMXnL4762dCI/EwMqHxijsxC4AvQsNLzh8bZSPVgzVcinln3nEDrIEyveQqQyk9oSED
         S4ytJk1K7o/+X8zdySJB2ZDa7um2826O5uAffYZdTEKspxFW5629Qm2z6LJhO5YTe8GX
         YKbJJ2tYAiAYZZ1GCVrHsK3BXwkHPsTZRSFjh10PaLSy7sLRGCn7xYrYC7Jc7dy/PMl8
         IXwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Ge9zDnKeP5Zu0nmntU1cSXLgT4EnpnKS+7IQa6koc8o=;
        b=u14F5ZYAM79qr9ODFOwcPYVB8syQmzhfHfPYfFLUABsSKDccmbjlMKZnUOTIxVWo8E
         +kYK1Mj3AlGSlA9/3xwmnzGJbi2L2CGS37134zA7BJNsMEAdbqj99oZGVSUdQeqNGIx9
         RTpef85imBYvIULphZ5yXXo1aFfjsVsBlx/anNUkEi11TTUDy0lhFkRIeKVa/fr2NV1j
         IRZP2jBUOyvgmzhvQTErYqE1LpzGDjXp6Entj9dmHP5JT/lOS8+kR99ovc7DhIzh5T7u
         4KxzA76Jt8oxuxJPSk0l4uWSWldJ6vizvZm4Qo2i88pAo66dyb7qvIIKo0A9dkUVGncq
         VEMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=r+rAYd5A;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f7sor78546968pfb.22.2019.08.09.02.45.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Aug 2019 02:45:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=r+rAYd5A;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Ge9zDnKeP5Zu0nmntU1cSXLgT4EnpnKS+7IQa6koc8o=;
        b=r+rAYd5AMY5icdk4MZb2mTfCNXTc5DxqZTHJiYkRCv6khogb6xombKcpNQLr8sZkxS
         rIABZfWtmM3nuRZm9qPBOmb6LzDdi86ahUCXSA1JjScEYA638D1V2QOp4xPXZDgXZQFK
         vHiE36+IR97fV1aAfPm9vTE8VI5zWkxFalMtMoj3ZToR4qRCL4Jq/yBNzmysUyY6ovT5
         Rxy3V21jraMU24Oq/8rdc3KMP92DnWLMysM1N5RjEoDNiB0A1UNa3HBTZph2Ah4MAdSN
         wwM3NAmIR3Zr9vKpGHgBiq2W2sCerpYlL0Sq1dqBmN720+/ku3xrD8LvtFQ7NMEnIU5Z
         kqhA==
X-Google-Smtp-Source: APXvYqxT1PLVMyiCnMcyJVwKgIa9oFlTOOytPuC0Zu8U6Kfk//cGcEpNvnMrzMvBp3DQturQVby8YA==
X-Received: by 2002:a62:e308:: with SMTP id g8mr21369420pfh.162.1565343902160;
        Fri, 09 Aug 2019 02:45:02 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.33])
        by smtp.gmail.com with ESMTPSA id 64sm98698155pfe.128.2019.08.09.02.44.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 02:45:01 -0700 (PDT)
Date: Fri, 9 Aug 2019 15:14:51 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: arnd@arndb.de, gregkh@linuxfoundation.org, sivanich@sgi.com,
	ira.weiny@intel.com, jglisse@redhat.com,
	william.kucharski@oracle.com, hch@lst.de,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org
Subject: Re: [Linux-kernel-mentees][PATCH v4 1/1] sgi-gru: Remove *pte_lookup
 functions
Message-ID: <20190809094451.GB22457@bharath12345-Inspiron-5559>
References: <1565290555-14126-1-git-send-email-linux.bhar@gmail.com>
 <1565290555-14126-2-git-send-email-linux.bhar@gmail.com>
 <b659042a-f2c3-df3c-4182-bb7dd5156bc1@nvidia.com>
 <97a93739-783a-cf26-8384-a87c7d8bf75e@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <97a93739-783a-cf26-8384-a87c7d8bf75e@nvidia.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 04:30:48PM -0700, John Hubbard wrote:
> On 8/8/19 4:21 PM, John Hubbard wrote:
> > On 8/8/19 11:55 AM, Bharath Vedartham wrote:
> > ...
> >>  	if (is_gru_paddr(paddr))
> >>  		goto inval;
> >> -	paddr = paddr & ~((1UL << ps) - 1);
> >> +	paddr = paddr & ~((1UL << *pageshift) - 1);
> >>  	*gpa = uv_soc_phys_ram_to_gpa(paddr);
> >> -	*pageshift = ps;
> > 
> > Why are you no longer setting *pageshift? There are a couple of callers
> > that both use this variable.
> > 
> > 
> 
> ...and once that's figured out, I can fix it up here and send it up with 
> the next misc callsites series. I'm also inclined to make the commit
> log read more like this:
> 
> sgi-gru: Remove *pte_lookup functions, convert to put_user_page*()
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> 
> As part of this conversion, the *pte_lookup functions can be removed and
> be easily replaced with get_user_pages_fast() functions. In the case of
> atomic lookup, __get_user_pages_fast() is used, because it does not fall
> back to the slow path: get_user_pages(). get_user_pages_fast(), on the other
> hand, first calls __get_user_pages_fast(), but then falls back to the
> slow path if __get_user_pages_fast() fails.
> 
> Also: remove unnecessary CONFIG_HUGETLB ifdefs.
Sounds great! I will send the next version with an updated changelog!

Thank you
Bharath
> 
> thanks,
> -- 
> John Hubbard
> NVIDIA

