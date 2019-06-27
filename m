Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32610C48BD9
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 03:57:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE71621897
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 03:57:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="2UONyGGM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE71621897
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6074C8E0003; Wed, 26 Jun 2019 23:57:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B8118E0002; Wed, 26 Jun 2019 23:57:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A65F8E0003; Wed, 26 Jun 2019 23:57:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 12AF38E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 23:57:14 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x3so554600pgp.8
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 20:57:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=G3T8BL0u+eRPhkuun5VQvVbguhLuguht1Lk1OKXOtfY=;
        b=JgJM4SpDC4N0nFywiKExEmPN/Cp2fqpVd6r6l+/Co96tEONsChbxSXZnnm7/0tSaly
         +hyQ2ziNeXmrG4VyL1SYUNmNoZVLWBaZOm+biH8v7n9MKK5EkcFrf2dv3H2WSMlYZQiZ
         FkwR5lyUfPIPrTrRPZFfxC5MeC4S64SIunCrbyRn8WXC6i3H54lZrSpUbcOhDZ3+H5Nb
         prZ64ZAIZRwtQcx9Ieu2R8nseSx48IbyO2xIBTmx56xocKEZO3bNMeofHQm5/pCyUwd1
         FHtXIEAd/JTIHtI3WRp2eesrYDMQvWJWoT4lJUjMJqZ2s9Mxn1M9Jiep0Vt5hXQTFU3r
         BIKA==
X-Gm-Message-State: APjAAAXJcv9kq7dGt4e4kyjx0JHsQOtt+l6qPZXvJpT4E3kn4Uc4g0+3
	2H6Q9Yn7IR62T9M2ORmx8PTerxyu5MsIitT/vgVSroIJzloLjuO8zOHZ/5GH+jJODvnJemtIjq+
	6puFvN2PI4NDGma9dfIygTbU+3adA4LIMQmJiNXBLerVnyHYwYR86F2RlZCqflyo/8A==
X-Received: by 2002:a17:90a:19d:: with SMTP id 29mr3372042pjc.71.1561607833604;
        Wed, 26 Jun 2019 20:57:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLKzsn/jCsBYiwEHwbU/qaDu7LM8OHqw/vOW75KklZsKhn2cMrHusMqGpQ9jXXLY7J2onb
X-Received: by 2002:a17:90a:19d:: with SMTP id 29mr3371988pjc.71.1561607832782;
        Wed, 26 Jun 2019 20:57:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561607832; cv=none;
        d=google.com; s=arc-20160816;
        b=b6Y+ZYzwiIEFprtXt8YQIkI9PA9yZVUt7VzC8Bf2YMmbm58T9/AAqcQ43JbKxcUkLv
         Vcb5u2T9Ihw3po8U2x2Ezrd1R3bVKJ0UqkTQg/CZPWlrCUyMI1fwJm8idi8E059yjJ9g
         a7av3OQrG45l5b34C4tWBAx2U/ToP2nNISExhxaBFfjcQTblND0KeOeuW5gn7xhSC1JJ
         HSh1zb/6b4YufX+Hc5f6IRWCp22diim4X4GmEeDGTC1uBBlaj+DQGnBOpQvGjjJKmQPH
         knP/UGABk7wBSU3/hsx7ZceGT7LU2TYHaMBwFGZ4jN0d+/b+dEvNy3T3/jncdJyLFolZ
         yauw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=G3T8BL0u+eRPhkuun5VQvVbguhLuguht1Lk1OKXOtfY=;
        b=Owal4nPqYQnDVdEj5h3qC9BNMynlAA4are91FJetHUJsFxQmYVKtLM4uQ/qGOyu40t
         vu0+uepwHsjrwnKCgIsS/vmV+mfbpdVqEbFIWud/s03phFHUx26cczpxjO6CXA4HhBW6
         YzSOo+ZuCeFOFm01VkWIz2Q6KBQ801K/Jdyw9xo3KIkFTTTh6zf5+JHEJQviBBfCTHkV
         mKM+k9D+PFxKJJkg1LXwo1OiftgA8JO8fRKa0rKLUg/pR4H6i0swZss/0JwpeZGpVmT6
         0U+xwDqL+KmgapNjAsucRGw62ZAKiTYb+Im1OHE8me3GN9F0+gs0s0jCNw+aovW50pc7
         9tyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2UONyGGM;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s12si952160pgp.572.2019.06.26.20.57.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 20:57:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=2UONyGGM;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CCE9C21841;
	Thu, 27 Jun 2019 03:57:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561607832;
	bh=/ADTO1E4aEzzEHDIMo3CfYNwAeZmCkOo4BbM1VeAIWE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=2UONyGGMTtlEsb/66mZHRuM9LWiMvATVylVUq0a4E0J3dMQcf4r1Q4+fAPrLrcnUf
	 ZrADGVLjSa8IAAONkU1uxWYm3XwMo09Neg7Q9TmaCjtjIKSPXCGTqqxd0FN+hqnwbT
	 6AOYBpnTaoEbPcHcmpEl/vWs2hKlCkAbcabdv438=
Date: Wed, 26 Jun 2019 20:57:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, <osalvador@suse.de>,
 <khandual@linux.vnet.ibm.com>, <mhocko@suse.com>,
 <mgorman@techsingularity.net>, <aarcange@redhat.com>,
 <rcampbell@nvidia.com>, <linux-mm@kvack.org>,
 <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] mm/mempolicy: Fix an incorrect rebind node in
 mpol_rebind_nodemask
Message-Id: <20190626205711.379c61b9cdfb9f43ae71c844@linux-foundation.org>
In-Reply-To: <5CEBECF9.2060500@huawei.com>
References: <1558768043-23184-1-git-send-email-zhongjiang@huawei.com>
	<20190525112851.ee196bcbbc33bf9e0d869236@linux-foundation.org>
	<2ff829ea-1d74-9d4b-8501-e9c2ebdc36ef@suse.cz>
	<5CEBECF9.2060500@huawei.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 May 2019 21:58:17 +0800 zhong jiang <zhongjiang@huawei.com> wrote:

> On 2019/5/27 20:23, Vlastimil Babka wrote:
> > On 5/25/19 8:28 PM, Andrew Morton wrote:
> >> (Cc Vlastimil)
> > Oh dear, 2 years and I forgot all the details about how this works.
> >
> >> On Sat, 25 May 2019 15:07:23 +0800 zhong jiang <zhongjiang@huawei.com> wrote:
> >>
> >>> We bind an different node to different vma, Unluckily,
> >>> it will bind different vma to same node by checking the /proc/pid/numa_maps.   
> >>> Commit 213980c0f23b ("mm, mempolicy: simplify rebinding mempolicies when updating cpusets")
> >>> has introduced the issue.  when we change memory policy by seting cpuset.mems,
> >>> A process will rebind the specified policy more than one times. 
> >>> if the cpuset_mems_allowed is not equal to user specified nodes. hence the issue will trigger.
> >>> Maybe result in the out of memory which allocating memory from same node.
> > I have a hard time understanding what the problem is. Could you please
> > write it as a (pseudo) reproducer? I.e. an example of the process/admin
> > mempolicy/cpuset actions that have some wrong observed results vs the
> > correct expected result.
> Sorry, I havn't an testcase to reproduce the issue. At first, It was disappeared by
> my colleague to configure the xml to start an vm.  To his suprise, The bind mempolicy
> doesn't work.

So... what do we do with this patch?

> Thanks,
> zhong jiang
> >>> --- a/mm/mempolicy.c
> >>> +++ b/mm/mempolicy.c
> >>> @@ -345,7 +345,7 @@ static void mpol_rebind_nodemask(struct mempolicy *pol, const nodemask_t *nodes)
> >>>  	else {
> >>>  		nodes_remap(tmp, pol->v.nodes,pol->w.cpuset_mems_allowed,
> >>>  								*nodes);
> >>> -		pol->w.cpuset_mems_allowed = tmp;
> >>> +		pol->w.cpuset_mems_allowed = *nodes;
> > Looks like a mechanical error on my side when removing the code for
> > step1+step2 rebinding. Before my commit there was
> >
> > pol->w.cpuset_mems_allowed = step ? tmp : *nodes;
> >
> > Since 'step' was removed and thus 0, I should have used *nodes indeed.
> > Thanks for catching that.

Was that an ack?

> >>>  	}
> >>>  
> >>>  	if (nodes_empty(tmp))
> >> hm, I'm not surprised the code broke.  What the heck is going on in
> >> there?  It used to have a perfunctory comment, but Vlastimil deleted
> >> it.
> > Yeah the comment was specific for the case that was being removed.
> >
> >> Could someone please propose a comment for the above code block
> >> explaining why we're doing what we do?
> > I'll have to relearn this first...
> >
> >
> 

