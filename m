Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97033C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 08:16:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5143C20848
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 08:16:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5143C20848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E10506B0007; Fri, 17 May 2019 04:16:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBEC06B0008; Fri, 17 May 2019 04:16:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C86546B000A; Fri, 17 May 2019 04:16:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B7DB6B0007
	for <linux-mm@kvack.org>; Fri, 17 May 2019 04:16:29 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id o82so1102822wmb.8
        for <linux-mm@kvack.org>; Fri, 17 May 2019 01:16:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=VVddGdwNwzt754dECiwX4P5eL0snKFoHnCCiVdymDOE=;
        b=Sr8k4+GUhk6s6aXu/0w81M+AH+Lq+W+/+zzKUp3ydZWwa41mLNlGmuOiyWsNebeVW/
         iMd/sfV6oxKH3g+4VkgNw2ARvw4o3y3IUOVCWhksmwDH3W0gmIxfzpucuy0fcEb/GleZ
         3u+H50vKl6xhAFf2A/sqRG3OaW10rEV0TWDPXfbKLMwE8WF1fr1keqbvPs0JNsKbqYXX
         MK+AR70k5MZtXfTNqchySbD03t8JgB4o7DwbKQt88s89tdp0De1MAEbfXTIsnk2lE9iU
         mLfwMHLgRhaJ+sJGyhvbl8S+N9tJLrbdVeMa9tj+1dwEKWOWHG7BThKcPyGfoAtsn+iF
         Jh+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
X-Gm-Message-State: APjAAAUDsj6ldryeXR2QuAyhH/pLAz68GWrNm4xNd4NctEm92fUMny4w
	ldWuTsiCk/RnQiPVSr0yvQXiQSV3E/uQvHRT0SBAdNSvf6Gla8zMzCh32kwE9h5FRIJ0nntMdhA
	eKKXr34zuijc5gT77YJMqWdGJes9nB1VESq+m7q3lrSZlsDcdCp5FZxaPR5peGQQ=
X-Received: by 2002:adf:c807:: with SMTP id d7mr4643045wrh.112.1558080989069;
        Fri, 17 May 2019 01:16:29 -0700 (PDT)
X-Received: by 2002:adf:c807:: with SMTP id d7mr4642986wrh.112.1558080988127;
        Fri, 17 May 2019 01:16:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558080988; cv=none;
        d=google.com; s=arc-20160816;
        b=bhccj27WEJeVsth0/INYZw4DnuhM/1xeFpOyLF9IyUvyKZu0TXCovQskBguOF7xzvD
         ztu7fCFZjq1guUXbGoM4IRWnnso535RWnEa5L9t+Ro66b4lrePx/+AnRjV40Q0CxwufJ
         Gm+3nDH5922D9TKl+mxap7MLDg5qLg0aVEx4tS2TLehz61Fo99fD4GFPhZmDuLC8RqUq
         NbnjRq6f4c1xLfSs1bWsqKP1f4sD3t7dkrzTplm7YyeB0xGeHhn/elyPlvAaf+8HgNQc
         WVWQd+ranNkHvPZtfZzOreUVr8WAjj7sV4wbJB8CV/D+UVeWo7yc1VvLFTxvsSKZeHN6
         zszg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=VVddGdwNwzt754dECiwX4P5eL0snKFoHnCCiVdymDOE=;
        b=g5GbDckjsnyDLySk9XPu17/bt9WJ0zMNhim8R4qsrxBmnQUdHT6SCEXdalJCBVK0cc
         JdcLBkZpE2PfVkxccJlMdMwNHwpl7SLpkrU8duAepVH3B5WuStkJdaYDU6onbpJPGRdl
         xLF2ppYEFKvflepKBWNPrBxeO5kn+jyMcOfXraPRDMjRONl5lSDhzprj1Tk9uSNU0I76
         j5Jj6JOg+cpCcsgaoKa4+fW6OqvlScjEA9MoukiWqdsovb9xFE2KXxrx/ay1V/N3z2ZH
         vfAl5Ht31Vlq7dhQN17u00ZZm9p2wRRlOE0MfVyAIdYtGq9CeFjjZp4mGvwMVm4J8Ylp
         q4bg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s16sor1459937wmc.0.2019.05.17.01.16.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 01:16:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
X-Google-Smtp-Source: APXvYqx2TpPJUw9AqnVLULGUdNzWC44410i4wRTRx0SBLF55tOJDc12m8wI6vToM3Jtht4jov2W4pg==
X-Received: by 2002:a7b:c0d5:: with SMTP id s21mr15354880wmh.152.1558080987723;
        Fri, 17 May 2019 01:16:27 -0700 (PDT)
Received: from ?IPv6:2a0b:e7c0:0:107::49? ([2a0b:e7c0:0:107::49])
        by smtp.gmail.com with ESMTPSA id k63sm236268wmf.35.2019.05.17.01.16.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 01:16:26 -0700 (PDT)
Subject: Re: [PATCH] memcg: make it work on sparse non-0-node systems
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
 cgroups@vger.kernel.org, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
References: <359d98e6-044a-7686-8522-bdd2489e9456@suse.cz>
 <20190429105939.11962-1-jslaby@suse.cz>
 <20190509122526.ck25wscwanooxa3t@esperanza>
 <20190516135923.GV16651@dhcp22.suse.cz>
 <68075828-8fd7-adbb-c1d9-5eb39fbf18cb@suse.cz>
 <20190517080044.tnwhbeyxcccsymgf@esperanza>
From: Jiri Slaby <jslaby@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=jslaby@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <2c3fab03-99fb-9313-140b-04a245065dd7@suse.cz>
Date: Fri, 17 May 2019 10:16:23 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190517080044.tnwhbeyxcccsymgf@esperanza>
Content-Type: text/plain; charset=iso-8859-2
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 17. 05. 19, 10:00, Vladimir Davydov wrote:
> On Fri, May 17, 2019 at 06:48:37AM +0200, Jiri Slaby wrote:
>> On 16. 05. 19, 15:59, Michal Hocko wrote:
>>>> However, I tend to agree with Michal that (ab)using node[0].memcg_lrus
>>>> to check if a list_lru is memcg aware looks confusing. I guess we could
>>>> simply add a bool flag to list_lru instead. Something like this, may be:
>>>
>>> Yes, this makes much more sense to me!
>>
>> I am not sure if I should send a patch with this solution or Vladimir
>> will (given he is an author and has a diff already)?
> 
> I didn't even try to compile it, let alone test it. I'd appreciate if
> you could wrap it up and send it out using your authorship. Feel free
> to add my acked-by.

OK, NP.

thanks,
-- 
js
suse labs

