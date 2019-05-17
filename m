Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76201C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 04:48:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3380E20868
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 04:48:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3380E20868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D98D76B0006; Fri, 17 May 2019 00:48:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D48986B0007; Fri, 17 May 2019 00:48:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C11286B0008; Fri, 17 May 2019 00:48:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 733266B0006
	for <linux-mm@kvack.org>; Fri, 17 May 2019 00:48:44 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id l13so2268492wrw.10
        for <linux-mm@kvack.org>; Thu, 16 May 2019 21:48:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=XZUN1rSQFoJQRTlk7qizj3g35k1ro3ZlvPQUs7PXq7Y=;
        b=frQ5UMFVxQWeMotnhcIfutPYzDmrI6DGVhjuLMssoupcrrkMRUNhzySjLlC1K91k0U
         nSwSTCqjk82eaK94yVZUG+ScXLSVGfEklLlHtLjsPCxTGJ5c5rG4gjS+uj/k+3e1sNDk
         9lqwc1bt5y71xURm1mGLac9c/1y1IhSr3bGVRt82iwNUMHBo9xprFHyGiaiuDlo/tzEO
         sFas0CtFZN5YGlKiIvnLAhCNEEBoqU4tCazify1nIHHLkJLXb82ggTNjrpOA5LwmPtXO
         soETnAFc5tLvbkhZnS5xk+g8yWeESrfNblHlj9/jeyralUkLU6Ecmp0j7oQWNXEuhyLK
         ZmdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
X-Gm-Message-State: APjAAAWSnh0qlJjqP1+aDNVWjdaAuvfjty41+oltWMB5NVFYWHA4dRbh
	5OPr1flyDb0oTpawxRC6Z8poLaU82F3P1Qj7+t/LKEFp5rEyjkvDGKjxC4d2aGPqfW9IGuikXGi
	+DLNa5j9DQBHCQiVzYhbdGxXWKGvI7i7ZB21epVTIBUaTHsOEd81hZBXJswvp6vs=
X-Received: by 2002:a1c:e443:: with SMTP id b64mr3435372wmh.71.1558068524057;
        Thu, 16 May 2019 21:48:44 -0700 (PDT)
X-Received: by 2002:a1c:e443:: with SMTP id b64mr3435334wmh.71.1558068523253;
        Thu, 16 May 2019 21:48:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558068523; cv=none;
        d=google.com; s=arc-20160816;
        b=BsbKWE18c93dYLE5/hMGxmHpsY1ER27dUygtyX8RwxO5vfU/0JhcWg+Yne80kBFovc
         dtbNyo4JGAHu6dqvDwshjWekK2TYW6oeFaOq5Ne8jZbvXrw7rgU6QAktjWJKYexEmDwx
         0K3b2m9VCM9AhHyroTXed3/G3waPg9n9wyJqMR/lywJVEfUqi66LGBniCJoPElFTreLL
         HzEb5Dy0akSYybiMCySjmXNbePnHj6SNYaiPM5QOvkb6eeNWkOEe+PrGlyjc7MFHmU9P
         J6XbgNxun89dNeUE2MoVqQBoyYpAI7HLhJXdNRg3jhBXPD8Tq4hMbD4862H9so5yG1rb
         CU8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=XZUN1rSQFoJQRTlk7qizj3g35k1ro3ZlvPQUs7PXq7Y=;
        b=IlRnebfCML8cnK2Vi2bNxo0sdrC6Z6M2TZazk+18FSt1qY64iFr9aGHZKrVNPwyC9j
         I8CeAToIJ0DFkDGCC/NJ5YYr4+eZdTqFMmwrtPLsT8V6k4Sw6PM8XugfvPsMCpzXIY43
         udrnxS/KetVierzLkO8BSc0DoKGVmggnbc8+02nPV1ikq7Eyd/4WCNdmsNYAprud+eFk
         4Bg1XX86Xwq1OYDT2WzUC/AfAOXywyBNobbkJA6sE/AXePJWWWUNmDwuVfV9RY8loL2h
         eo2iyxTcYiOkVosoNUXuKKC+SZpuj1Z13E27lheYzz0TT1tnhOlAYhxtcRzgAKtHwDbO
         0bYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y69sor4448620wmd.20.2019.05.16.21.48.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 21:48:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
X-Google-Smtp-Source: APXvYqwR25sv4dtpyUB74mgoWSvpPid3DFq7m389WuIN93GuDMxdyIXdJcbswvGymVd/5ur/g85h4Q==
X-Received: by 2002:a1c:b756:: with SMTP id h83mr564817wmf.64.1558068522865;
        Thu, 16 May 2019 21:48:42 -0700 (PDT)
Received: from ?IPv6:2a0b:e7c0:0:107::49? ([2a0b:e7c0:0:107::49])
        by smtp.gmail.com with ESMTPSA id o6sm12612149wrh.55.2019.05.16.21.48.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 21:48:41 -0700 (PDT)
Subject: Re: [PATCH] memcg: make it work on sparse non-0-node systems
To: Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org,
 Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
References: <359d98e6-044a-7686-8522-bdd2489e9456@suse.cz>
 <20190429105939.11962-1-jslaby@suse.cz>
 <20190509122526.ck25wscwanooxa3t@esperanza>
 <20190516135923.GV16651@dhcp22.suse.cz>
From: Jiri Slaby <jslaby@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=jslaby@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <68075828-8fd7-adbb-c1d9-5eb39fbf18cb@suse.cz>
Date: Fri, 17 May 2019 06:48:37 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190516135923.GV16651@dhcp22.suse.cz>
Content-Type: text/plain; charset=iso-8859-2
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 16. 05. 19, 15:59, Michal Hocko wrote:
>> However, I tend to agree with Michal that (ab)using node[0].memcg_lrus
>> to check if a list_lru is memcg aware looks confusing. I guess we could
>> simply add a bool flag to list_lru instead. Something like this, may be:
> 
> Yes, this makes much more sense to me!

I am not sure if I should send a patch with this solution or Vladimir
will (given he is an author and has a diff already)?

thanks,
-- 
js
suse labs

