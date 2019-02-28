Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81F28C10F06
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 19:11:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52885218D8
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 19:11:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52885218D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB31B8E0003; Thu, 28 Feb 2019 14:11:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C621D8E0001; Thu, 28 Feb 2019 14:11:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B50DC8E0003; Thu, 28 Feb 2019 14:11:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 722258E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 14:11:13 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 59so15718217plc.13
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:11:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sRkWVXQmUxMvFG+RDgTGvVK2nK5SU1geAcP/sYeiDCo=;
        b=fQpcUUjw+JTKZ8hHhoJARUDBitx9u8+lGdUYxMgoYafYdMFWFTvq9QGTKpJDUDqer8
         f5ecYK5yDESIYsiJaOi1XY/jKjW6KOIViR8gVGPF+7lJlymKWtVIWpw3hAIg9t6OEN+S
         jvC0Cgdsi+UPfHBrGLdkl5q48E6SJmgX3hkI82+aLkXpwv7XVYCyT9MYJX/QpSlNVcqp
         oZ2ptVkG7OvxluCM6GBmGmHTXxtDEa1Aa0iYnfh0TmS8usvu4ig+oqH4W6hUJjkEhp5p
         XFT3jQm5vYSYGQU2vpkLadQbotLa4kBVJ0eLYAuR/JZhZB8FNqWdu3k8u/qiL8SJv1/H
         kw3w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAVtdjfqX8yYnlTDD5996OkN2hJZPb/MXTXGSOCdV5FuqzPGS+bw
	prDQ6c49tDJPcY9BRdve5fCNL4bFmOdOkb9tLP4T15jkmTU19Akb8GQ6lscvmIvAWKWWynHn4sk
	VoVOce1Irk7S/VnXkWCSrbaCtEBMmLomym1jwykJmURm7rVCC4p+MxODDRSH1SNT1ug==
X-Received: by 2002:a17:902:166:: with SMTP id 93mr1002293plb.20.1551381073099;
        Thu, 28 Feb 2019 11:11:13 -0800 (PST)
X-Google-Smtp-Source: APXvYqy8RWCOtOXkjikTGqf2FLIiKuQE9dOTyVHX+Hp11Psc3qB+nwLUVzy+zkNDfQGxsDkYNNiH
X-Received: by 2002:a17:902:166:: with SMTP id 93mr1002218plb.20.1551381072121;
        Thu, 28 Feb 2019 11:11:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551381072; cv=none;
        d=google.com; s=arc-20160816;
        b=qLl8Eo/TqA1c/eroy3dIs5gf2+Lc+cc4TTfivZv+RNABT/ZGtZvbWdQh0WbQZcgCcy
         37HP0x56jnVNZfePS+CmEZs2IreAKUzhAAvriW8iwkJWZy+pqFdWGDVyy1GjllccV6LX
         H9qhoatIyNVyxQEdjN2fuWLMa6WWPyokWzngYZ6o8JPGkAXun17XupHd7qn84gdkK0dm
         PcWMIWCoZtC2aTgXG53vO3AxKtSNN1tzMsuACQ7p2OnKIvjJjEfxLCjxNfWimRRAGxBc
         TVh+lgWYenltUU2ODifdEwVVFHnCku61PDMfiQpz4vz8SrXWSR5+erQQWe+YdpnolAmO
         AqEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=sRkWVXQmUxMvFG+RDgTGvVK2nK5SU1geAcP/sYeiDCo=;
        b=lb16auerJxS0mzKS0STgJz/kfiVG5BgzWV/JIFHrfLTDtbwq3uI3RteMt3yKihDpL6
         WcWi8DO/be4Rvz1bgcF5ljIvMeyoyJlpqf3r+B03gLLh9XiRfC27UVwnTQwRj1/G5zxU
         2Vqktky9f283deUA2eJtCp2wuLmG1Ot8LjA/GKxU3SNQK5V1O0x4Nb8A/33AS3xqL2OX
         6qM7FYN5xXaYs9dOutuO6Iwsq1I8S5xABi0Zce6sZ/4qDGDI2K/46EQrbkL/EmsaEqzS
         iNAEUolLymo14DOg3NsxGrHDAxINGhyliWHxSRUuLsU1RJKL5C13DgLpvV6CfxDI3Tj0
         57pA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bi11si6912580plb.164.2019.02.28.11.11.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 11:11:12 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 3505BAFD2;
	Thu, 28 Feb 2019 19:11:11 +0000 (UTC)
Date: Thu, 28 Feb 2019 11:11:10 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: rcampbell@nvidia.com, linux-mm@kvack.org, Waiman Long
 <longman@redhat.com>, Linux API <linux-api@vger.kernel.org>, Alexander
 Duyck <alexander.duyck@gmail.com>, Andi Kleen <ak@linux.intel.com>, Florian
 Weimer <fweimer@redhat.com>, Linus Torvalds
 <torvalds@linux-foundation.org>, "stable@vger.kernel.org"
 <stable@vger.kernel.org>
Subject: Re: [PATCH] numa: Change get_mempolicy() to use nr_node_ids instead
 of MAX_NUMNODES
Message-Id: <20190228111110.564d84f62a1b294ca5b1f9df@linux-foundation.org>
In-Reply-To: <32575d26-b141-6985-833a-12d48c0dce6a@suse.cz>
References: <20190211180245.22295-1-rcampbell@nvidia.com>
	<20190211112759.a7441b3486ea0b26dec40786@linux-foundation.org>
	<32575d26-b141-6985-833a-12d48c0dce6a@suse.cz>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Feb 2019 19:38:47 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:

> On 2/11/19 8:27 PM, Andrew Morton wrote:
> > On Mon, 11 Feb 2019 10:02:45 -0800 <rcampbell@nvidia.com> wrote:
> > 
> >> From: Ralph Campbell <rcampbell@nvidia.com>
> >> 
> >> The system call, get_mempolicy() [1], passes an unsigned long *nodemask
> >> pointer and an unsigned long maxnode argument which specifies the
> >> length of the user's nodemask array in bits (which is rounded up).
> >> The manual page says that if the maxnode value is too small,
> >> get_mempolicy will return EINVAL but there is no system call to return
> >> this minimum value. To determine this value, some programs search
> >> /proc/<pid>/status for a line starting with "Mems_allowed:" and use
> >> the number of digits in the mask to determine the minimum value.
> >> A recent change to the way this line is formatted [2] causes these
> >> programs to compute a value less than MAX_NUMNODES so get_mempolicy()
> >> returns EINVAL.
> >> 
> >> Change get_mempolicy(), the older compat version of get_mempolicy(), and
> >> the copy_nodes_to_user() function to use nr_node_ids instead of
> >> MAX_NUMNODES, thus preserving the defacto method of computing the
> >> minimum size for the nodemask array and the maxnode argument.
> >> 
> >> [1] http://man7.org/linux/man-pages/man2/get_mempolicy.2.html
> >> [2] https://lore.kernel.org/lkml/1545405631-6808-1-git-send-email-longman@redhat.com
> 
> Please, the next time include linux-api and people involved in the previous
> thread [1] into the CC list. Likely there should have been a Suggested-by: for
> Alexander as well.
> 
> >> 
> > 
> > Ugh, what a mess.
> 
> I'm afraid it's even somewhat worse mess now.
> 
> > For a start, that's a crazy interface.  I wish that had been brought to
> > our attention so we could have provided a sane way for userspace to
> > determine MAX_NUMNODES.
> > 
> > Secondly, 4fb8e5b89bcbbb ("include/linux/nodemask.h: use nr_node_ids
> > (not MAX_NUMNODES) in __nodemask_pr_numnodes()") introduced a
> 
> There's no such commit, that sha was probably from linux-next. The patch is
> still in mmotm [1]. Luckily, I would say. Maybe Linus or some automation could
> run some script to check for bogus Fixes tags before accepting patches?

Ah, that's a relief.

How about we just drop "include/linux/nodemask.h: use nr_node_ids (not
MAX_NUMNODES) in __nodemask_pr_numnodes()"
(https://ozlabs.org/~akpm/mmotm/broken-out/include-linux-nodemaskh-use-nr_node_ids-not-max_numnodes-in-__nodemask_pr_numnodes.patch)?
It's just a cosmetic thing, really.


