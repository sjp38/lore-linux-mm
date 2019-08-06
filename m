Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3389C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:22:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDDA6217D9
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:22:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDDA6217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40BD76B000A; Tue,  6 Aug 2019 17:22:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BC676B000C; Tue,  6 Aug 2019 17:22:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D2436B000D; Tue,  6 Aug 2019 17:22:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC8186B000A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 17:22:57 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 30so55632613pgk.16
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 14:22:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xbQN0Ze09ToNotXdvYlrtR5iu2WpxvqWAqxh6cDd7I0=;
        b=P2EAcCCxIp316LzZ9Xlb8II0vvqvUsDvXZZr28mkfDwfHQ5xZytabuTo4iaLQGpL+P
         vtZnIN+kecmssx8cPFbWOw9JPydsuyBHfhIHY+58D/bJjt5ItlN4IcfI/pyHbURDnvMM
         29aNihOfI3jS3DfzIfSN1mYv/Cm6Q8Ppz82Bnjrdm66lP1nR8sfmq3hEj+zrXtMoiNp+
         z5tp3oC9CBOZXsoKZE1R8EujqdknNNqe8aRfy2BGoBHuCLSZuIxktFK7WzKgTyVgoOG6
         7okIfVzJGqXEkcEY/PgeH3mTjEgpjjlLR1narAv+IuugqVURmuIrUf/dfE4omZwFmznE
         w6jg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAUClbgfOoFItzG6otM1veqyrl5RFTIv5Ps69guB6xiPEU8X8VAK
	jUl9ZQjihXtDoGZwM3jGkvoN5rcKplku3TWS3cyvmY/vTP97TjgD7EXIwk67Q9PlumEeGuVZVnk
	GzpvrtontwDzXtOH3xRpGIuOdbSNiDjcKzBuTytU13Uc6WBy/zuSFbFPROaXngUo=
X-Received: by 2002:aa7:92cb:: with SMTP id k11mr5874167pfa.126.1565126577655;
        Tue, 06 Aug 2019 14:22:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytIvHf0jvnKNCp5Exh7J2z4/qSPdPmmprF2yzo9AixgD+gLwAHMfR6TrEQalDGsbw9L2F9
X-Received: by 2002:aa7:92cb:: with SMTP id k11mr5874131pfa.126.1565126577013;
        Tue, 06 Aug 2019 14:22:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565126577; cv=none;
        d=google.com; s=arc-20160816;
        b=ZyJb5odwTRMIYonaZh3klrWcxXnWiVijWXulyE+XUb2AoV0t+avRV+sEiLHAuyTGRj
         o48qxtq7NosbEy7qkWVKIgtNHeNakOA1MPDCXeueyBtIg9B/27qShe4FZ3ZVCL0+EtwM
         SPbABgR4nVM0zZNk8R0wi+Q2Y043r6m1LWRKXDRCz1k+ijfqpmRgwbkg6TY01L5O2M+A
         o/Bg5jPvOp7tmbplmUgqo1TXOAwr8td74RqK3aW4W2I5GtiMYGjjygSBvIxtisvNHNgb
         2/RViqWEi4iw3hMV7PgTh6DjJiIgVbHMd3/e6t+xnBqilex65Jyw4P9Eub9/4zIns0Ei
         VzsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xbQN0Ze09ToNotXdvYlrtR5iu2WpxvqWAqxh6cDd7I0=;
        b=hO7ba42kCWX3KGRzQO3ZNGKI1iM+jL6s4v60GrI6IWXCKY9nS9V8C9IgzLG1+I8ar6
         VKqf52vC5+q4XUcUhEpME9eBkEr+D0o29z6sNkerM0z1Yvm/4BtvfZh85/+YhM2wmdDK
         d0WHb7eHSAAJr2r5PfhNzgEs0z8cvfcDrda8+NJ+jJLKdMrmVbznethr9/5mYysql7tj
         DFofx9J8ZFqOhFWHFTofhUVr96KIz1dWq2/kcRhRzjJ8aIjqJgWPSS2cU/damj4cgAvq
         1A2pPs8ux9MqnfgKguFAC617n+1cBILifX0qJp+Rx+7ISBiQwdDntPkWBZJx4IXv0vyj
         TJiw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id q9si53897563pfl.287.2019.08.06.14.22.56
        for <linux-mm@kvack.org>;
        Tue, 06 Aug 2019 14:22:56 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 7490B43C5F0;
	Wed,  7 Aug 2019 07:22:55 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hv6tw-000533-Gl; Wed, 07 Aug 2019 07:21:48 +1000
Date: Wed, 7 Aug 2019 07:21:48 +1000
From: Dave Chinner <david@fromorbit.com>
To: Brian Foster <bfoster@redhat.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 15/24] xfs: eagerly free shadow buffers to reduce CIL
 footprint
Message-ID: <20190806212148.GH7777@dread.disaster.area>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-16-david@fromorbit.com>
 <20190805180300.GE14760@bfoster>
 <20190805233326.GA7777@dread.disaster.area>
 <20190806125727.GD2979@bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806125727.GD2979@bfoster>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0 cx=a_idp_d
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=7-415B0cAAAA:8 a=b5DoXVf_MhzvH81YMsoA:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 08:57:27AM -0400, Brian Foster wrote:
> On Tue, Aug 06, 2019 at 09:33:26AM +1000, Dave Chinner wrote:
> > I'll recheck this, but I'm pretty sure overwrite won't leave a
> > shadow buffer around.
> > 
> 
> But before that we have the following logic:
> 
> static void
> xlog_cil_alloc_shadow_bufs(
> 	...
> 
> 	if (!lip->li_lv_shadow ||
> 	    buf_size > lip->li_lv_shadow->lv_size) {
> 		...
> 		lv = kmem_alloc_large(buf_size, KM_SLEEP | KM_NOFS);
> 		...
> 		lip->li_lv_shadow = lv;
> 	} else {
> 		<reuse shadow>
> 	}
> 	...
> }
> 
> ... which always allocates a shadow buffer if one doesn't exist. We
> don't look at the currently used (lip->li_lv) buffer at all here. IIUC,
> that has to do with the TOCTOU race described in the big comment above
> the function.. hm?

You might be right there. I haven't had a chance to follow up on
this from yesterday yet, so I'll keep this in mind when I look at it
again.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

