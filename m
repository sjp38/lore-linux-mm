Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B726C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 16:18:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1818222B6
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 16:18:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1818222B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A43D08E0002; Wed, 13 Feb 2019 11:18:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F2EF8E0001; Wed, 13 Feb 2019 11:18:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E4ED8E0002; Wed, 13 Feb 2019 11:18:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E53B8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 11:18:37 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id w17so2003568plp.23
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:18:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=TajlqAH5PnowJhsyXLmgp/vtr5uso6qFAhVN5NvtyOQ=;
        b=VNoS2OehQ4m9mpP/9HRDM43pwnPy+DBJDobk83W0ZKbxW13ynn4KUDl1WrBUGzfyG7
         IwubvUo+oMzYWdc8oMHreyMFMVx83FOJkXkNVLdGZ6C583UQ7DZuJNFenCYm569CISOL
         KQEQY++g7vG63063n7qt/90AFr60oe8rBJnsbGduHBNBRlV8qO1YWURACVHgU7LTe0Ym
         MTGBFKm1mCRDId4qUir/2M6M4M+1B9Wge0VhCHnXXrw9c5qaFkDp/iXr2ENAzI74wfJZ
         s4+cLfC5izE4rm0MzKx8nn8/N8GFlqGsDVOW0J/ZfqdgRxO4I+D3g5dLGHQ8sQYgJxuA
         a4yw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYzm72f7DbyEkMYKUrcv6gyGS66wStgmzZfKLR51IcD1MBZB4ok
	jSS5He51t9ZFzD53AAGAv/DPR+/vGsZDrt88QxT17bRBUOmoAdZFFzArMz02MkvyG+fI61jBGYC
	hUlmeNaBiMl2skld3MUJTZ71GRMj4AuXJcQZRc35K5QZUcAwg//57VrRJTuz34Ek=
X-Received: by 2002:a62:e005:: with SMTP id f5mr1311117pfh.64.1550074717014;
        Wed, 13 Feb 2019 08:18:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZhGWCUP0zH2hXMmoJASAcOw84J8A6eTnJufoG/q7cEMjQ9b7jBP89rOVgBWdBW2H/XaC79
X-Received: by 2002:a62:e005:: with SMTP id f5mr1311045pfh.64.1550074716117;
        Wed, 13 Feb 2019 08:18:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550074716; cv=none;
        d=google.com; s=arc-20160816;
        b=ftqUBl0/Jqu2UGCJjnqIO//SVjkWkHFGw3HYMUjVG2I1vs7gKXXMlEsuvshNEOGrBg
         3GYD5LLyUZ7J14MxDPEeIwE6NvG2y28pWGwvzRnUoDxpxBAhnU8a1IUdJbuSA50YzK7y
         /g4I0XMeHIJxuErFe4+ouMFD3mTnPKI2uvlwQLuKh3TXsKGKUzp+npMrUiegcXkqL7My
         U1xxc1OGFNCWzTA7xG5W+OX79NNkiOjt+cRQSpZktWYAzQxV8m3FwNqi4LQZWINQlCVK
         B88B4cnRWk2X60f7a0z0+o5v16yBm93LZHktZK2pBD7uaKFssdiv3cz5Ah6fx3VPja0A
         kflw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=TajlqAH5PnowJhsyXLmgp/vtr5uso6qFAhVN5NvtyOQ=;
        b=oaO+q3KtmT+h/JbwtsVlxRmT0QjFs7P6VglrqV5wYmFATPmn9WlE9qvGOkVVcDbUrE
         fv00x7B6JL4W0/9RNcI46/jeWm3JFsxdG3hzzfF4viEdBK1rjA8Mdb/FYKSFtOywodPi
         9kNw9avxqFs5o9OUOYjLIpDBUl54vLTqYdqCaoMy3WC4r10QNchccycTA48pOCiSy7cL
         OmdQ9Qm90vxlMMhx9daZSaEI8mm08DEYY9quKsAnZEnJaXFkGB+52zVyb+2MXtbBJmYf
         Mn9o6YJNRBZVIUm1rtypIlYsYS2IYJYM8BSUsnunLfqBs5cn8hoEtdpvuvTtSa5gVVPI
         BFjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e17si192406pgd.109.2019.02.13.08.18.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 08:18:36 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 85ED4AD74;
	Wed, 13 Feb 2019 16:18:34 +0000 (UTC)
Date: Wed, 13 Feb 2019 17:18:32 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, Pingfan Liu <kernelfans@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org,
	linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v3 2/2] mm: be more verbose about zonelist initialization
Message-ID: <20190213161832.GT4525@dhcp22.suse.cz>
References: <20190212095343.23315-3-mhocko@kernel.org>
 <20190213094315.3504-1-mhocko@kernel.org>
 <1433a7e9-87b2-7e8d-a87d-dcffe486635c@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433a7e9-87b2-7e8d-a87d-dcffe486635c@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-02-19 08:14:50, Dave Hansen wrote:
> On 2/13/19 1:43 AM, Michal Hocko wrote:
> > 
> > We have seen several bugs where zonelists have not been initialized
> > properly and it is not really straightforward to track those bugs down.
> > One way to help a bit at least is to dump zonelists of each node when
> > they are (re)initialized.
> 
> Were you thinking of boot-time bugs and crashes, or just stuff going
> wonky after boot?

Mostly boot time. I haven't seen hotplug related bugs in this direction.
All the issues I have seen so far is that we forget a node altogether
and it ends up with no zonelists at all. But who knows maybe we have
some hidden bugs where zonelists is initialized only partially for some
reason and there is no real way to find out.

> We don't have the zonelists dumped in /proc anywhere, do we?  Would that
> help?

I would prefer to not export such an implementation detail into proc

-- 
Michal Hocko
SUSE Labs

