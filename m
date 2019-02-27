Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11DE2C00319
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 18:38:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF2732183F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 18:38:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF2732183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A777B8E0006; Wed, 27 Feb 2019 13:38:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FD5B8E0001; Wed, 27 Feb 2019 13:38:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C5B88E0006; Wed, 27 Feb 2019 13:38:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 339A58E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 13:38:50 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o27so7354675edc.14
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 10:38:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=kKg5KizBgfVIROv2I7VYWP07t6CDGNiI5BeBJ9On5/Y=;
        b=IbcHv98W6Khekd8NnyWKxe7FqVEFeXEHqPvK1MK/AM43wlm+OpbhkKrRiypPrAAXZS
         EtkXt0+BzTFfuZSp7boufzgC7rCi5dS40QNG68eDLHdEu4xk8jXjWGUdY6oEDllHncj7
         6pYvCV3+szMmDHt4mNJ0uWHlI6I3FZA6eanOxootvLcespMwH1QlVs8F0pnAmYuh9JC0
         lG9NraGP2fKq+1EBp0LdlLH8LeEZTXnCvESpYTR1Csi9DD3DRCzgx7OvpJuyG8fPI7fE
         sf4aj9Hz1eqE008p30kFrps5sSB9lCqiS1jKMZjGeg/KpjibSxwBx8XyZcHXrO2yKxUS
         9Uqg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAubRl5QQe5K4DIPCKQJWfdHye46hTvslqrIsJX0/qlDomEQzimH8
	fjkwd9kNOoJRcendwgfYf+cKt/6Fs+H6MUGym/lp79SKJNjEh1Z8CAXX/H+yNDtkmLQMvML6/Za
	TiMfb2xUC/druFTB8DEoi6ulE46xLt6p3kbQc0jfEWoBCl+KVzkxJhAwag0PgKmcqvg==
X-Received: by 2002:a50:d508:: with SMTP id u8mr1723909edi.51.1551292729761;
        Wed, 27 Feb 2019 10:38:49 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaC+0CIAgQHYZGGc4WHay/6RORGFp3E4xNy/WDV7a5mPCQg7FOFvtVtN5XJXDw7/FOrRP8N
X-Received: by 2002:a50:d508:: with SMTP id u8mr1723842edi.51.1551292728543;
        Wed, 27 Feb 2019 10:38:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551292728; cv=none;
        d=google.com; s=arc-20160816;
        b=lkDWwbLzqhb6OmWYBPk835cBDi/AT2WpMdmqDYYpyk0t6kxzAD5E2urbzDtB/Hd1Fu
         oC2JmR7/uhUTpepMlkfpNpQRQJ5RMUtoTXZkuIxDRKgYISH114V7/k+lr6YA7yFGx2Zx
         vw5nOp5PUArFifgW+WuNUwyKXkQR8U952RgE7EwrDdGbKsqfYDQsQAHKLShqXeEwXVNz
         uS2F6ejJgNZACwnUDrSMnTeiLcAn+T/jVH4s802iM8FPDLZUHdMbe1dOq2vuWVS/pZ+f
         dNfSihUI65MD8h3zX02NSyOCEKDYBhXRd+J3xNq13vouNfPkGeJ6iGcLbUlz6LMdb/qg
         7Nng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=kKg5KizBgfVIROv2I7VYWP07t6CDGNiI5BeBJ9On5/Y=;
        b=vQYA1JqbRooeymkG7AEoCsO023YZNBQaFW9kYNfayfH6k84gYVhPKfpGH0BNDtA6vX
         9MA5z/kc8DVclfNkd7NU8sefjdIRwmnT0TQqg8IFqI9YM7H3Sejs8Hj9uFA5vvaYmWii
         ttbuJzsJb6nkET5ZfltMW0H1lugVaCRV24k9zPn2+IiMVPt2DUb1eaBVEq54u2J5xqCR
         ExUOxfr06TuG5VJhXOJ/dkBV7OgM1BAXKFiGfcoCXqhRMmzf/pVx+NPTQWvpxC+nxv5x
         tuhYoTKN7o0WQ50ps06rPK4PI/iGV6XzKZb8mCb2hxQLS0lO9fn/gv9ufVXJjLzEtDyV
         0KoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gy3si1893095ejb.312.2019.02.27.10.38.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 10:38:48 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E3FCAAC5F;
	Wed, 27 Feb 2019 18:38:47 +0000 (UTC)
Subject: Re: [PATCH] numa: Change get_mempolicy() to use nr_node_ids instead
 of MAX_NUMNODES
To: Andrew Morton <akpm@linux-foundation.org>, rcampbell@nvidia.com
Cc: linux-mm@kvack.org, Waiman Long <longman@redhat.com>,
 Linux API <linux-api@vger.kernel.org>,
 Alexander Duyck <alexander.duyck@gmail.com>, Andi Kleen
 <ak@linux.intel.com>, Florian Weimer <fweimer@redhat.com>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 "stable@vger.kernel.org" <stable@vger.kernel.org>
References: <20190211180245.22295-1-rcampbell@nvidia.com>
 <20190211112759.a7441b3486ea0b26dec40786@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <32575d26-b141-6985-833a-12d48c0dce6a@suse.cz>
Date: Wed, 27 Feb 2019 19:38:47 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190211112759.a7441b3486ea0b26dec40786@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/11/19 8:27 PM, Andrew Morton wrote:
> On Mon, 11 Feb 2019 10:02:45 -0800 <rcampbell@nvidia.com> wrote:
> 
>> From: Ralph Campbell <rcampbell@nvidia.com>
>> 
>> The system call, get_mempolicy() [1], passes an unsigned long *nodemask
>> pointer and an unsigned long maxnode argument which specifies the
>> length of the user's nodemask array in bits (which is rounded up).
>> The manual page says that if the maxnode value is too small,
>> get_mempolicy will return EINVAL but there is no system call to return
>> this minimum value. To determine this value, some programs search
>> /proc/<pid>/status for a line starting with "Mems_allowed:" and use
>> the number of digits in the mask to determine the minimum value.
>> A recent change to the way this line is formatted [2] causes these
>> programs to compute a value less than MAX_NUMNODES so get_mempolicy()
>> returns EINVAL.
>> 
>> Change get_mempolicy(), the older compat version of get_mempolicy(), and
>> the copy_nodes_to_user() function to use nr_node_ids instead of
>> MAX_NUMNODES, thus preserving the defacto method of computing the
>> minimum size for the nodemask array and the maxnode argument.
>> 
>> [1] http://man7.org/linux/man-pages/man2/get_mempolicy.2.html
>> [2] https://lore.kernel.org/lkml/1545405631-6808-1-git-send-email-longman@redhat.com

Please, the next time include linux-api and people involved in the previous
thread [1] into the CC list. Likely there should have been a Suggested-by: for
Alexander as well.

>> 
> 
> Ugh, what a mess.

I'm afraid it's even somewhat worse mess now.

> For a start, that's a crazy interface.  I wish that had been brought to
> our attention so we could have provided a sane way for userspace to
> determine MAX_NUMNODES.
> 
> Secondly, 4fb8e5b89bcbbb ("include/linux/nodemask.h: use nr_node_ids
> (not MAX_NUMNODES) in __nodemask_pr_numnodes()") introduced a

There's no such commit, that sha was probably from linux-next. The patch is
still in mmotm [1]. Luckily, I would say. Maybe Linus or some automation could
run some script to check for bogus Fixes tags before accepting patches?

> regession.  The proposed get_mempolicy() change appears to be a good
> one, but is a strange way of addressing the regression.  I suppose it's
> acceptable, as long as this change is backported into kernels which
> have 4fb8e5b89bcbbb.

Based on the non-existing sha, hopefully it wasn't backported anywhere, but
maybe some AI did anyway. Ah, seems like it indeed made it as far as 4.9, as a
fix for non-existing commit and without proper linux-api consideration :(
I guess it's too late to revert it for 5.0. Hopefully the change is really safe
and won't break anything, i.e. hopefully nobody was determining MAX_NUMNODES by
increasing buffer size until get_mempolicy() stopped returning EINVAL. Or other
problem in e.g. CRIU context.

What about the manpage? It says "The  value specified by maxnode is less than
the number of node IDs supported by the system." which could be perhaps applied
both to nr_node_ids or MAX_NUMNODES. Or should we update it?

[1]
https://lore.kernel.org/linux-mm/631c44cc-df2d-40d4-a537-d24864df0679@nvidia.com/T/#u
[2]
https://www.ozlabs.org/~akpm/mmotm/broken-out/include-linux-nodemaskh-use-nr_node_ids-not-max_numnodes-in-__nodemask_pr_numnodes.patch

