Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73426C46460
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 15:04:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 392A1206C3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 15:04:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="oERv5R43"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 392A1206C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C32C86B000E; Wed,  5 Jun 2019 11:04:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE3306B0010; Wed,  5 Jun 2019 11:04:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF9366B0266; Wed,  5 Jun 2019 11:04:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 784276B000E
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 11:04:12 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 145so5671294pfv.18
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 08:04:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=4r0N0/cqZQsQLzB9riNWHtGeoqNPwixp4EIavL99nJ8=;
        b=rXb5e/2EusCCPLqyPxF8DXSkNq8n9cFEMYC30JNBUbM9sRG4KGKbdsv0l/PpaGzwUp
         sBhFB8kxo1paA+ePb5itLz8+2V3AZWVdJxmdUUB2I5ZvPrGX8uMYSwuSHx/8KrKYZ2Fa
         2S8xAEKMqMt51Rta9QT6SRJ1UUGJgEvRBT8M9+9EaYzfHXT9dxrvoGhtn7ApVHjlcVNy
         liBJoogWBXf/plEdL+FNE2pwLFGRVQDvLs9zUjC0AGJimnarHSMwQ2BFBhdxMympviGp
         zf031wt/kSYUTtefx4CUvpUyklzvxcvn5OrQytl6iFDWl1cUsUQmaAAYuzG5ja54g77k
         Zt7g==
X-Gm-Message-State: APjAAAWVfTUm9FShaRahDTodRLmmj/NNBbXq/3DSTakwtyYrhDEpbf5o
	VOKcTwxquH7Crejg6rEl6EY2AK2ONQLBATKJ7SZqkMZI6qmczEfcTvA0t9nJIlJEDV/2Aiw13pO
	GCsAagByU5+AsuxwLwEmEDhq4lnvhkW7qdM6basJymQRdlZocxx7q5Iu9/J8s5IvfmA==
X-Received: by 2002:a17:902:b18c:: with SMTP id s12mr42695921plr.181.1559747052136;
        Wed, 05 Jun 2019 08:04:12 -0700 (PDT)
X-Received: by 2002:a17:902:b18c:: with SMTP id s12mr42695806plr.181.1559747051242;
        Wed, 05 Jun 2019 08:04:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559747051; cv=none;
        d=google.com; s=arc-20160816;
        b=NfTYorTDMH4TsJGx2MID2OoFqPzfffJWBapXTJsucpmnc6KN9PuQAVDYbW9awWEfzS
         nrVSCX6dPYbx1nlaAfXXUwL/splQhFclIt8H+SxbchyGBZvl8O4syt7bwVh/ENbgBbuQ
         Piyb7P+UU5u5RJLezf5ZVfwdZR7m3KXWKZBu65crHAWPOUivocdOiFUAMsBZ8/q9vnpI
         yzN4IybmmxLhDQXQoEfKIptcyHG+r46rbzq4pjUKeSxiPJsN+Y3czFz/Nc6k7txmzs9m
         4R1HK8zWA4fYzo8Dswc7aS7X0ZoiNaZ50d4ydHKz5AgC/Lacd1oEKFglAnRqJwWjg+zP
         GKnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=4r0N0/cqZQsQLzB9riNWHtGeoqNPwixp4EIavL99nJ8=;
        b=NLSpwADtJGCYSOMWtPA7X+wEYLrlCikpHNlqfa8waASEzLwqZNUKTvuH0L5eUXBPGf
         i0ZCEz6kUNNNZN6vyL8wPT1UR9TF3gn8I1Kuf7XEznMRWl9SpmD8zlCTPRU85tTRjLmH
         XLnSZDtnujOOhXoDIxbJQX4Pe2FCi7HJ/wDybdTzL1Ga6qqEPt7iwgXpDTYa8F3+ilb7
         U39Xc5qshl04wvpFyAujTOAI3Lrvaa/2/79VOTAlQY1q2vhFVLArSLhhv4vkrI93Gq8c
         Ay+yI4JATXTz54YpeF/E6R9mJJVCZVdAaE16P5mjI6sqS9JDP0bdMQqf6RUk4E65N6dr
         nEzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=oERv5R43;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v2sor24321822plo.32.2019.06.05.08.04.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 08:04:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=oERv5R43;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=4r0N0/cqZQsQLzB9riNWHtGeoqNPwixp4EIavL99nJ8=;
        b=oERv5R43tdTVogKDqW2pbdEh9X3kPQEt8rkO9i+PyA1hnJj546cBlYXzqcNAnkeH2o
         xDmAZeAaD3jnQjr0VGd/3yJeW9/U0/CoKmRqtd40ETtm22bSXsBnOuB32EKuu31MPb91
         ZSIW51BWmFZMHfkABF4+vmPS6bIFLD3LSrnjCSMx6330KEtzZiRV2rAVVXuuu5u6ZNF3
         54Qq+ZfFN/F7mWNAP2jok++5M9n9LfGsg48fbCOmIs1bUlM0G9Lx/jcF9KRHn8EseCjE
         5m7W7V2GXw5p0rXmC+VRWhzHmSy5HHyIgphZ1oqomuWKlWHVxlDyDSRiGqUbPO44zi0Z
         IlWw==
X-Google-Smtp-Source: APXvYqzBM2bZj69n7MfkaSXw8zh+DTZMgfwk0BMgMehP81PBePSCTHmM2EpXvogAFZyH4IQcEXIAvw==
X-Received: by 2002:a17:902:b905:: with SMTP id bf5mr44544164plb.155.1559747050554;
        Wed, 05 Jun 2019 08:04:10 -0700 (PDT)
Received: from [192.168.1.158] ([65.144.74.34])
        by smtp.gmail.com with ESMTPSA id k1sm4864237pjp.2.2019.06.05.08.04.03
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 08:04:03 -0700 (PDT)
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
To: Peter Zijlstra <peterz@infradead.org>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, hch@lst.de,
 oleg@redhat.com, gkohli@codeaurora.org, mingo@redhat.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1559161526-618-1-git-send-email-cai@lca.pw>
 <20190530080358.GG2623@hirez.programming.kicks-ass.net>
 <82e88482-1b53-9423-baad-484312957e48@kernel.dk>
 <20190603123705.GB3419@hirez.programming.kicks-ass.net>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <ddf9ee34-cd97-a62b-6e91-6b4511586339@kernel.dk>
Date: Wed, 5 Jun 2019 09:04:02 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190603123705.GB3419@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/3/19 6:37 AM, Peter Zijlstra wrote:
> On Fri, May 31, 2019 at 03:12:13PM -0600, Jens Axboe wrote:
>> On 5/30/19 2:03 AM, Peter Zijlstra wrote:
> 
>>> What is the purpose of that patch ?! The Changelog doesn't mention any
>>> benefit or performance gain. So why not revert that?
>>
>> Yeah that is actually pretty weak. There are substantial performance
>> gains for small IOs using this trick, the changelog should have
>> included those. I guess that was left on the list...
> 
> OK. I've looked at the try_to_wake_up() path for these exact
> conditions and we're certainly sub-optimal there, and I think we can put
> much of this special case in there. Please see below.
> 
>> I know it's not super kosher, your patch, but I don't think it's that
>> bad hidden in a generic helper.
> 
> How about the thing that Oleg proposed? That is, not set a waiter when
> we know the loop is polling? That would avoid the need for this
> alltogether, it would also avoid any set_current_state() on the wait
> side of things.
> 
> Anyway, Oleg, do you see anything blatantly buggered with this patch?
> 
> (the stats were already dodgy for rq-stats, this patch makes them dodgy
> for task-stats too)

Tested this patch, looks good to me. Made the trace change to make it
compile, and also moved the cpu = task_cpu() assignment earlier to
avoid uninitialized use of that variable.

How about the following plan - if folks are happy with this sched patch,
we can queue it up for 5.3. Once that is in, I'll kill the block change
that special cases the polled task wakeup. For 5.2, we go with Oleg's
patch for the swap case.

-- 
Jens Axboe

