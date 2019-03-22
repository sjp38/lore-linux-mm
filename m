Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE324C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 22:51:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A05121841
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 22:51:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="vrapgFdT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A05121841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F3276B0007; Fri, 22 Mar 2019 18:51:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A1126B0008; Fri, 22 Mar 2019 18:51:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED37E6B000A; Fri, 22 Mar 2019 18:51:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD336B0007
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 18:51:07 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id z9so900706wrn.21
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 15:51:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=losYwk/KnyYBXmqLLyIEJufi/8wg0iZYh/lFm2rrato=;
        b=b3xOu9xcAqAnZiATcGoydDy1dvb75uw8zFFp0GLByUEbo/+ZFMi+TLtmS4WL2lWMMZ
         IuhbhzAN1HcvzBhFkkm44Yxad2qjtaKCczBO2iipBEjCcjQyB4wh4uV004/nP+Sa7/2g
         xEMVxZwB3GkitKzxzBYYg+EwNORbVzfqbsk8y9OJ1uIcH9SZwq/cIQWsElOx02OTnStH
         rH7wNxpsBcMMUU8WjzXafehvvGThqjZCreZ7bUNynMpI23dm+987CLz5Aw5PWtQFqai9
         zWSC20vP3TT2L5gTn+6R4YgSycZNMfitsUZaRatgwtpXb8hfccxxc49PagWvHXGT87nM
         8VGg==
X-Gm-Message-State: APjAAAU7/5B2E1Jw91FBOiOHRh5FMYroyLaP37K8xRaXA+Xjd0bH0QMF
	8wIIdVwYo6n6KiuLSKK3wMiiGRPscjAvs/1YI9fexzUufiWF04LUwi7+PuO92ttDmqDZ/slbq3N
	3sWeS96AvDfhg7JuR6xzrCjn0bYFymMcvgxa7kgOBQ1nKJOCM6SsAWGVjSFvUTCg74w==
X-Received: by 2002:a05:6000:14a:: with SMTP id r10mr8081336wrx.107.1553295067262;
        Fri, 22 Mar 2019 15:51:07 -0700 (PDT)
X-Received: by 2002:a05:6000:14a:: with SMTP id r10mr8081316wrx.107.1553295066655;
        Fri, 22 Mar 2019 15:51:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553295066; cv=none;
        d=google.com; s=arc-20160816;
        b=UD3Wb1RnOXv3Euh2VLZ4hxJpQJbpVb5lfPTDMXe8HL0vs8cguQYgPKehDSsMpMXTpM
         kRYKkwK6+ipkmX4/7mv+WsctL7O1WkFapOEA0/V0DMwW0K3NWhWyHGFSjmxKyEuhdlwV
         lARfXrHeyFWcjf3DbrmVJqORBcxg7il+cSz4JcGOnqRgdcKiwlEUscghCjDIedoP8xC3
         kRa15agM1CbJs1w/h+P8VOkzcBM3fC7eCKEQpDgDTR+wHxjpXEkQpRx7p0XVugW9+nkz
         xHc99gQr9FBifYtt3CBQkuV3qiQkcdzh0iwrQxVYriQaAaZ5r1A8eV1DCUPodQbRAxpr
         758A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=losYwk/KnyYBXmqLLyIEJufi/8wg0iZYh/lFm2rrato=;
        b=DSr8eS3LDMd07xjevnUpXOra7bJ3EHEzG7eD07QFd0jFhgqMaf/Rb6CrwyXz6o6hg6
         G9JdEu6ZkW5UnfkeNOCdjVyIUUrYRwzdiZjTaAJVto2O8ap34MQiZCYcjtMApm8+arO6
         DnbfXLGCbkF6iRtbO2k91AdfJ39xS9kAeOY6oykQ5FXSoLtEkUAPpJ8Sk+v5dbgR2G1S
         kpYeU525MpdEU1QL5XbIMhnXGRWBSoIVgzzWHsui7zMqJpCPWGbjqdcTc70ReuocUHZS
         0ZSw14FvNAFASmLKyaaYNXkwxDrD1iWLh2upMq3Y8zDTdc0trVoij8qZN62PSZLuk5kj
         3ShA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=vrapgFdT;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l13sor6149368wmc.4.2019.03.22.15.51.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 15:51:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=vrapgFdT;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=losYwk/KnyYBXmqLLyIEJufi/8wg0iZYh/lFm2rrato=;
        b=vrapgFdTIfpT8XWFnIH1/GLXnuTAw40ZeVke3Yc0Z7QMZ5/Lb0zs8qCSPqghWJK9Qs
         GpkaCsqzi3mLS8zOASlqm0nzs2tmmRmILYWDayt/SwE2+swwnX0taFqcD+9XuGJvSE8G
         OfR8xGLbN93EsKI3jxWaNQkOCWDePK32gNlLQ=
X-Google-Smtp-Source: APXvYqwf8UKcetCKDuArWodMQzyGrYiEaHyrN7VvfQjQJmF/nB7qUNX7kI/1I5k/PxmVK44hxXSbhw==
X-Received: by 2002:a1c:ef1a:: with SMTP id n26mr4421627wmh.104.1553295066245;
        Fri, 22 Mar 2019 15:51:06 -0700 (PDT)
Received: from localhost ([89.36.66.5])
        by smtp.gmail.com with ESMTPSA id a82sm9301106wmf.11.2019.03.22.15.51.05
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 22 Mar 2019 15:51:05 -0700 (PDT)
Date: Fri, 22 Mar 2019 22:51:05 +0000
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
Message-ID: <20190322225105.GA21729@chrisdown.name>
References: <20190228213050.GA28211@chrisdown.name>
 <20190322160307.GA3316@chrisdown.name>
 <20190322222907.GA17496@tower.DHCP.thefacebook.com>
 <20190322224922.GA7729@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190322224922.GA7729@tower.DHCP.thefacebook.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.154546, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Roman Gushchin writes:
>However, we can race with the emin/elow update and end up with negative scan,
>especially if cgroup_size is about the effective protection size

Yeah, it's possible but unlikely, hence the TOCTOU check. :-)

