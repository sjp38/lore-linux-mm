Return-Path: <SRS0=s2+Z=O6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAB1DC43387
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 21:58:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82D8F2190A
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 21:58:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="M67B5Mqm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82D8F2190A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23A448E0012; Fri, 21 Dec 2018 16:58:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1EA2E8E0001; Fri, 21 Dec 2018 16:58:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DADF8E0012; Fri, 21 Dec 2018 16:58:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE5EE8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 16:58:42 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id ay11so4995744plb.20
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 13:58:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=tPIyQKEhD8jSuYym3JA98vimnD2uHKo0PyBvCttAp70=;
        b=QllDHzdMDJRcqvkwoTyxXyI8iMeintx6GEUAXYJ/GNxvublWDDxSzlQLgcZUPBvZk8
         9x0y7fH+Aw4nZiG8YQIvMMwefwB7CdWyTEXCkoNS2RW9nUzXZRx/cahPVMcim1O5IkRj
         gPch3sM4tggiEjFGo1w20YRPWWfER5XBWZ355YW/mscMEROx7msS3qQcSfyTQb4OS4pB
         5zVxD2FmB9VjjU9n0ALgFJvvlUMU+JX63l9tMTVwJfDUb0oHtGoBuFI/WwBSnM50e2HE
         cYT2awnBA0odKKVjP9C7OMPkVIvdjVihR5IHfWonfJWFEeA0N+6s4/9zOa2tRBQyhpXh
         vdlw==
X-Gm-Message-State: AJcUukdp4iOGQoIYqDJcJkQmB+2g7PUoLm++AXpnSriNNUK2aCrpp1GD
	epxdI8A+Vf9xFTklcTzz+WThYqf1+yEudNM3WxPWWvJjUt85VhP45+qV6xRZ489q+BO11qCMHjd
	OxRwjSAtEH8Z0fEDun4iRSSfrS0u+xzJu/78n8fiXvkT5JOBR2Oir4C/8YA54488SqEccmbvfS9
	c/dkaYv6ya0oGW+P6KPU2XYKyB8q9NnnBFSLSk4W5TORuN4j7+1URm+i4AuVC1oGd8mPzWXCUc0
	9FIWs6V3OfDQoOe2xjZoR1nY4AMGztltzZ1pIRGwtagQoGVJ++9QLu7TtjPqtSlTJPHyBBqkXwu
	rNrtK/yOuuiSp53EYBm3UNz4+NhOXsaAQbJOxwClewMzBWEQIbXDSLT5xThmDh15PcY2rhLePtG
	d
X-Received: by 2002:a63:504d:: with SMTP id q13mr4071046pgl.319.1545429522388;
        Fri, 21 Dec 2018 13:58:42 -0800 (PST)
X-Received: by 2002:a63:504d:: with SMTP id q13mr4071015pgl.319.1545429521682;
        Fri, 21 Dec 2018 13:58:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545429521; cv=none;
        d=google.com; s=arc-20160816;
        b=EBy+fWewcCxnI3SO339uIKthEjiTVwmDDM7jOmBdungBa3Y2SSUoazJCxNNBBsGjsv
         VMPVe5+G2QrZgQTVIos4g8je93l60q5wdSjLhYrMvD4Lp0xXhyKgLtEjIsR2hLAzNDq7
         RXMRFd0JNt+RjS3bR47tMxHh6aNuwThYUsP8eKo/nsO0c6OdYaociQFlkiAtGRnN52L+
         1At2xT8BpMsGImSud6luBR+1CAFKfUnpA+HJlBCScJmsRcl6QOsXtrj/5Lu6OEPPfYUO
         VycqUffkJOMH/+RlbS0PeziLjNCcuO13EENcnbj/Ka57nS8SVqvaZfHHE6qyorsAfeU6
         zh8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=tPIyQKEhD8jSuYym3JA98vimnD2uHKo0PyBvCttAp70=;
        b=Q5qm/Nqiv/idaj4wCc1rdKy9ZokCDN/9i666+C92upZHVpqS5sUHk9jOK26qq6dAdc
         1YYQ/pCGeIj7yzn7mzbvH+uOWidghe4FDtYr16Vcm+R55+lpf9zuJDL0ggZ3+LrrsCwU
         f0ri8RWlI+C3o1RHPq2XwMKPwSmZyX2GtBheQ6dnYq7rD8HmrD6bkVoJOYPJS01oBg+j
         PmDcYSTSGrTQ8GZc5RGy+QYtrOkDtTrbmbfcotbk/3hmikLk2udWq6Iyrqvetx4kzTpp
         mv3Ay8sGGc+lxjPavAA3pE49hqAam9kdwBmdlKVatlvkyAy1arIW2ABRUmIE8hPgUw7G
         rGrw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=M67B5Mqm;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q5sor41526895pgv.82.2018.12.21.13.58.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 13:58:41 -0800 (PST)
Received-SPF: pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=M67B5Mqm;
       spf=pass (google.com: domain of rientjes@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rientjes@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=tPIyQKEhD8jSuYym3JA98vimnD2uHKo0PyBvCttAp70=;
        b=M67B5Mqm948rD0LRf4ZPMVo+xHTg+EuImBkQtlQ06jbb08eViauzP/ayOcFgEL69Ms
         NT3otIX7hQlTC4vEvmuKVEi0iOeZXoGYZKpZHfywWwDrLxAUnbckPbgNoF0/aJXetfLI
         j48W6ffx/M8XbIrKlqCxAbP1eQQ4jrSIp79tPeZ2I8erPdlG0BuX7P2uwpgJGlhABIpg
         KsJPbwmc/IhAnPgZ8FUuJ4vqsBBNuc2tOqr4gY7Dx9kUfT7hrIuPqRDsZ/7dyFTM9/m0
         ZMf0ttwPZ34U61YBKsyZPE1bKnhQwa2cFfKNukyzHihQZ2cdsHyfrCT0ma6+R1x/Lb94
         dN1g==
X-Google-Smtp-Source: ALg8bN7THH/UMe8WVTeMlD31zR3I/nyagot0sPRVGoPHwqFzd1Sdga4IglBX8w70Ld/X83/h2r74hw==
X-Received: by 2002:a63:e445:: with SMTP id i5mr3999567pgk.307.1545429521165;
        Fri, 21 Dec 2018 13:58:41 -0800 (PST)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id 7sm82600646pfm.8.2018.12.21.13.58.40
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 21 Dec 2018 13:58:40 -0800 (PST)
Date: Fri, 21 Dec 2018 13:58:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Nicholas Mc Guire <hofrat@osadl.org>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    Chintan Pandya <cpandya@codeaurora.org>, Michal Hocko <mhocko@suse.com>, 
    Andrey Ryabinin <aryabinin@virtuozzo.com>, Arun KS <arunks@codeaurora.org>, 
    Joe Perches <joe@perches.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH RFC] mm: vmalloc: do not allow kzalloc to fail
In-Reply-To: <1545337437-673-1-git-send-email-hofrat@osadl.org>
Message-ID: <alpine.DEB.2.21.1812211356040.219499@chino.kir.corp.google.com>
References: <1545337437-673-1-git-send-email-hofrat@osadl.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181221215839.u8Q0Zsy94BgzW1c3VrIgqY_tkZPdJ_ffru4KuTdzxuU@z>

On Thu, 20 Dec 2018, Nicholas Mc Guire wrote:

> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 871e41c..1c118d7 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1258,7 +1258,7 @@ void __init vmalloc_init(void)
>  
>  	/* Import existing vmlist entries. */
>  	for (tmp = vmlist; tmp; tmp = tmp->next) {
> -		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
> +		va = kzalloc(sizeof(*va), GFP_NOWAIT | __GFP_NOFAIL);
>  		va->flags = VM_VM_AREA;
>  		va->va_start = (unsigned long)tmp->addr;
>  		va->va_end = va->va_start + tmp->size;

Hi Nicholas,

You're right that this looks wrong because there's no guarantee that va is 
actually non-NULL.  __GFP_NOFAIL won't help in init, unfortunately, since 
we're not giving the page allocator a chance to reclaim so this would 
likely just end up looping forever instead of crashing with a NULL pointer 
dereference, which would actually be the better result.

You could do

	BUG_ON(!va);

to make it obvious why we crashed, however.  It makes it obvious that the 
crash is intentional rather than some error in the kernel code.

