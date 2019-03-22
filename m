Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E114C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 23:51:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E290D2175B
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 23:51:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="F2HThYNw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E290D2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DEAF6B0005; Fri, 22 Mar 2019 19:51:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38E5D6B0006; Fri, 22 Mar 2019 19:51:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 255BA6B0007; Fri, 22 Mar 2019 19:51:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id C4B6E6B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 19:51:23 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id s10so1754136wrn.8
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 16:51:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=uB1/IWOEK+GFSUVXVpArQJE+Iwx/dVBKwpNZw8eSYdI=;
        b=ifqN2L/abpl7+1+5Y/Q8de+LD3FQaReyInPsIV9Ob7SAk3lICC5OwSqd0DwPGb/ynS
         xbw6goxbyVagqj46TM4fMtPeXMjhtGm95GyrR+LHCvTl5SX/j5dcQmUVgDfWvfgi5Oh9
         /aft9D8PTnOHkF+H0L2dcG0LgqEtqpm215M2zInQ8MdJQIM3SyaxXFMpepYPgDEfw52x
         zI8dy/+Ad7jApyTHFnf/zYBIId+13JnTVa/Yr/KVrKHwXXluSgXXxNZVyDc3n6k2IbbW
         WEVzbPfGm4aqTrakOE2YGssDVQnQu7Asd4gLgywm7gvdLydRJwZ/0QecbwLZS/8Rx2oY
         BAcw==
X-Gm-Message-State: APjAAAUyCN9wMU7A+JVV9aTwkqUfk3NFyDx98hGXmnAYY2QiG06UI6fC
	3EAP8KK9gEQMBVthPFEXGBB0t6g69wDGKWHR4eCZva+joOrL0DMJRGnyDFn4QYeRJQlZYdqIdiU
	aUXvJuUZJYRBX20dWeT/CDWmZEvGHVQhsr190elF4QXJup6BIeHUuAECWaQkyeIvY3w==
X-Received: by 2002:a5d:5192:: with SMTP id k18mr8236940wrv.171.1553298683192;
        Fri, 22 Mar 2019 16:51:23 -0700 (PDT)
X-Received: by 2002:a5d:5192:: with SMTP id k18mr8236918wrv.171.1553298682322;
        Fri, 22 Mar 2019 16:51:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553298682; cv=none;
        d=google.com; s=arc-20160816;
        b=Zr2tOJroDdTwuzA3OoTTZKwCXTAzR7VJEYmEMzaiqpMlwJ8SjNJ4VcR13zsGIa3TLV
         Cwu4L6lEQX8UeEQtKce4Bb0UK1mqoI+n73NwsHhZMXE5pb5iF/itO7W5X2xIkQfaF4z7
         tcUjnIECSgNaKZ3DsD++29t7LQ9z5SPO2OOc3XYXIGn462UqjGj5j9edWWfog00trxbE
         6FFCQLQGgX/jb8xdcc1V8Oneqs5w3/owQFLxDeGhIacDOMY+yB0qE1/5hvS4G209HWry
         DaxwqifdEi934/xKEe0Q3pTDXUUu/1zPpeOuf5OMODXP8TFFYiCTyMQ6nfd7MgHmcvnz
         Xa5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=uB1/IWOEK+GFSUVXVpArQJE+Iwx/dVBKwpNZw8eSYdI=;
        b=SLODOym7z22+Tq2TbQi+Lv2NrMXDgjsVC9m2+vaqLHzmQPxPUWCcEb9YqqlKLcBviX
         N1Vlq7McybaxPrvB4mFbF3Flw3LR43Tc2syyqTV3QIuTL7bjpMT/tTb48OojLKv3HSs+
         vrh6mYTyRwcqPFR6vZB/tT+Fq/aA50qbJmS13SRObErxS1XXCMaBintV0Yy+jOk+f0/h
         pUjONvqDp65EwqmmI+TLCU8fgMWD27Lm5rglLcN8vPxDte7M3YOmN63IkzJFHdU+bWrX
         cL3Nt6Ewain1qcEUOnK/3T/qXAS2X7wobRYtwln+L3SR4Mt56xicbU8DhnTqpvIRnIPr
         jxHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=F2HThYNw;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a18sor1475289wrs.17.2019.03.22.16.51.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 16:51:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=F2HThYNw;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=uB1/IWOEK+GFSUVXVpArQJE+Iwx/dVBKwpNZw8eSYdI=;
        b=F2HThYNwJG9xqwjVQ01U0dygceVtFhVN0zGiTc2s3fFci+rr5MHvTeD5KDR+N1swhg
         X3d076qrgSksIDL+shRkHOExAf9duEYrkKtDhF+zKxlEIWgd0PSqwXV4x63UJIIQCSve
         jF4basxGu6d75EeaUSo5T89X47nRmV5VwwpNY=
X-Google-Smtp-Source: APXvYqyRBZybPLJFkSojkdSL5WTU/65TusoLI8KSoWFwV/aSQt7LQc2reLKao6ubYa/QY/UGQAr7PQ==
X-Received: by 2002:adf:fbd2:: with SMTP id d18mr8010207wrs.55.1553298681935;
        Fri, 22 Mar 2019 16:51:21 -0700 (PDT)
Received: from localhost ([89.36.66.5])
        by smtp.gmail.com with ESMTPSA id y125sm5899796wmc.39.2019.03.22.16.51.20
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 22 Mar 2019 16:51:21 -0700 (PDT)
Date: Fri, 22 Mar 2019 23:51:20 +0000
From: Chris Down <chris@chrisdown.name>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>,
	Dennis Zhou <dennis@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH REBASED] mm, memcg: Make scan aggression always exclude
 protection
Message-ID: <20190322235120.GA31019@chrisdown.name>
References: <20190228213050.GA28211@chrisdown.name>
 <20190322160307.GA3316@chrisdown.name>
 <20190322222907.GA17496@tower.DHCP.thefacebook.com>
 <20190322224946.GA12527@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190322224946.GA12527@chrisdown.name>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000012, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Chris Down writes:
>Are you certain? If so, I don't see what you mean. This is how the 
>code looks in Linus' tree after the fixups:

Hmm, apparently this actually didn't go into Linus' tree yet, so yeah, seems 
worth having as a fixup maybe indeed.

