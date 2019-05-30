Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3A09C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 00:35:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D9BF243AA
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 00:35:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="opqCw3aq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D9BF243AA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D0E196B0266; Wed, 29 May 2019 20:35:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBE176B026E; Wed, 29 May 2019 20:35:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B86206B026F; Wed, 29 May 2019 20:35:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 835C56B0266
	for <linux-mm@kvack.org>; Wed, 29 May 2019 20:35:29 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 14so1098204pgo.14
        for <linux-mm@kvack.org>; Wed, 29 May 2019 17:35:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=WCSz9/I6gTeqg/ESOjee5MQIcRdo/bNNoxObWxNXK4E=;
        b=plQ6nTyxB1fdhCXKFsYeBD+ogUP4r5F0awv5K7Q3pORMVq/7VbttfHxMFO/TfLD+dX
         5Wlwa8pe84fRPB8ebXnI7O0FNzrRo2OY8IBFqDqvJ4hnmBaUPotpXNBr01ytrgXShcFI
         xTRHVJPa40x70JMoXBrAPZzKVm5ohji/U21VqttHMQWWo+PzhZlOX256eygz347qR29d
         fbRccdAij++2q2vRdMQHETPrtxOElWhCx32+iwXHZ6UaXe6WvG4xypRz5YsEyYSSkGvU
         jEqokNp+fa+qbnPL3xsQBggfpABzXy+7LMrTzZ8dyxKWs43m0wuxH5OVvfUqxJG0Nh7Q
         f1uA==
X-Gm-Message-State: APjAAAVbo+xw7J3Hnht779eNSwtF+Fmn8BDDACFzjTpjT3a4wXPliMjY
	cSeckNqdkEaDgLY/30wXi1fVvZmsGftE1i21f4x41ip5RTxb6BNO2fpc0of7T8fCvDThunUBxUO
	vnXnSIIatoy/khCjC/AcJbpSTW6kbHRfO0GQAhGL9UutvImXBv1WMD/3zH26gb2E=
X-Received: by 2002:a17:902:28ab:: with SMTP id f40mr831600plb.295.1559176529090;
        Wed, 29 May 2019 17:35:29 -0700 (PDT)
X-Received: by 2002:a17:902:28ab:: with SMTP id f40mr831545plb.295.1559176527922;
        Wed, 29 May 2019 17:35:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559176527; cv=none;
        d=google.com; s=arc-20160816;
        b=p7vZQOim/z33iZ3kAENaUXPkG1MlQ6X5/CCOLdj2bMVMta13XPUh41T0s+il8nNo+f
         dcFiEa5Q5bAgQpxtoRi65eZZY0r6vGatvvkWC+9locVB9M1R5UuDcIE/TvwUINvH5Dhn
         0f82wNfLq9K5KgKcByEP+APzdE8PG9FT9H0CUBT90wW2IkgNTSPbj/kIpr5zW+RbUth7
         Y7wF4XrW897UzHfVQy5VWLEbPeeMeYKreyt9RX9F6Iw1GfrDeET0sN+cbjq0IE/Z6IZ5
         /GdSaFgG2Cp8tKmjXGbDrBtpC3Lmq3bKYVCw10LN4tLri4N5ugqLtGIY1MzlFGNXdQuo
         UfpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=WCSz9/I6gTeqg/ESOjee5MQIcRdo/bNNoxObWxNXK4E=;
        b=TuJEAbzSZN+27dVCv6TsgOwutvYZ2mjiSHO21X0CRqMBickeoz3oBg5MVxjXOuS6La
         1K3XfKGNAwcgza9xEQA8QN8T+cNACUCo65tgzUwoeglI11xnYvShYAoU9MFPSwOvCZgI
         n2mNNWoDw5MIR/q8OFWy+6AdGvwpev0ibirTd56yhTkfhmaDwpuQiY1+qbCq4wVOx38s
         XWIROakvhmfB4VFxG5yPcqIe6yA4a3Q4ygz5jaPLD0oKU8TikniGANK7cphH5NT47+ty
         L1xD+oxbftM+xsr9zVghkgOXfUAQ5sorOlSIoUE42yhk5DgMvnb0uokFhdQW/IQOfB/v
         Gwww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=opqCw3aq;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a1sor1254797pla.0.2019.05.29.17.35.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 17:35:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=opqCw3aq;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=WCSz9/I6gTeqg/ESOjee5MQIcRdo/bNNoxObWxNXK4E=;
        b=opqCw3aqBIiknEKeQodAFFu3OCxtwvP+W4j9BVCjB36idpHMrPJrPuD5ph2s9xacgY
         fafk59YaCZmoDVNf64N7EctZ0V370beTquv0AGmOqimjyZ5UBcTuiUG6Z927N967cMRd
         CR3J73QQiSo7PFksi/g2h10sGE+qf+UlSrsXgb0c1vE0F24uoabRtcUWmov3uOZMJETH
         XF0B0gxdMK1u6tihyh92ckmO5B4OJbRTm8i1dDuBzZ14eITrt+6tvm1PaD82ziYXfkfT
         YgsEDfXqnArQu3czX0Vt6HJALiMWMcI7uP1mPTqs2V91tk6hCvtV8fUoDsIYlt4rm/3g
         2A9g==
X-Google-Smtp-Source: APXvYqwqxTqPzeJe0bYTfxudVeVQk2PJ/n+gl8eR6vQJis3N9o3oE/pOOo35+eiB0i/2B3itKVDFXA==
X-Received: by 2002:a17:902:b495:: with SMTP id y21mr839620plr.243.1559176527378;
        Wed, 29 May 2019 17:35:27 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id r7sm751659pjb.8.2019.05.29.17.35.23
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 29 May 2019 17:35:26 -0700 (PDT)
Date: Thu, 30 May 2019 09:35:20 +0900
From: Minchan Kim <minchan@kernel.org>
To: Hillf Danton <hdanton@sina.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 6/7] mm: extend process_madvise syscall to support vector
 arrary
Message-ID: <20190530003520.GA229459@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-7-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520035254.57579-7-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 12:14:47PM +0800, Hillf Danton wrote:
> 
> On Mon, 20 May 2019 12:52:53 +0900 Minchan Kim wrote:
> > Example)
> > 
> Better if the following stuff is stored somewhere under the
> tools/testing directory.

Sure, I will do once we figure out RFC stage.

