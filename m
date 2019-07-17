Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE595C76186
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 10:56:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8015421743
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 10:56:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8015421743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E88B6B0003; Wed, 17 Jul 2019 06:56:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 172F26B0005; Wed, 17 Jul 2019 06:56:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2CC88E0001; Wed, 17 Jul 2019 06:56:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9978D6B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 06:56:02 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d27so17771835eda.9
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 03:56:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=iFw2sRLELOLYsBPm0AR9UM8C+m1wBe5yITWVGlRCoL0=;
        b=ZmxZM0HIpbvPG7r6Y2nxjUjWNZBUNwgpJIHqOgSRF3BYVbZ60YFesASPGBifnEJDaq
         FvbyuFud9+SpFpEZxmHPRW/aPaRJo8Tgr66+iP7lpPUKNP8rDnk/ckqP6crq3pohKH7S
         vlOdAL1SLhiiQvYux7UGhcDfoLCAWUd5EYqL3iFSLVI31Rc3CntIk1bkZPZsBMvWEteX
         BntnyWePdktYv5DDtNgi8lZFhK1wiugk2wjHn5yZD17KMooGOdcWthDpCpOCn35RyZYZ
         jkCq3mhW+3saaL9EfYIyfYJ2M7obQPEgO4F2aAaJLYOyf9dJWfh9TUvidQfG1smKoITU
         iPNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAVmdEeeiI2g2HR4CyRC2MrO1mbtoJp7d5VRXwDziKF+CDb361CA
	HP1/hLcf/T8Z2axHzuBDAF3DPdW+ZbUDxKj9R6Sju/KjKfVbKiKFHDywwYxqrFTpTpPuohrju/T
	SY1J0/UeWMWyu0OV2J1Diw4M5bR3wuoFlBbZZZItDrb1z278Q9GHCQnzrjynBCT+nJg==
X-Received: by 2002:a17:906:948c:: with SMTP id t12mr30500468ejx.222.1563360962181;
        Wed, 17 Jul 2019 03:56:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpBEPqS++OrHCARPNDmTVyFrp5Ul1BVygrykoLhxMJqFXsbhzLQvnrhFUNDuEhpk1zyLGa
X-Received: by 2002:a17:906:948c:: with SMTP id t12mr30500408ejx.222.1563360961239;
        Wed, 17 Jul 2019 03:56:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563360961; cv=none;
        d=google.com; s=arc-20160816;
        b=Lh81RY7jgmTjFYvC6c1W50ZHP0GRscfZ/+Q+GmBfPxQS5fHJCqkqEJE4z7DqXZ4Ron
         rge/IMdeTO0vNhy3SwfZocW2PaHdUGsbRy1XT6GltoVyAVhLUVKB4Y8cSElilkgVcD7z
         lyNgcY3Xc8oiV8nheSWA2XgFw8lxgFG4jQmIxjvn9Ro2Jz/2q+YHslb8gikkqaihDXf6
         42wEWozUYBxzeecFbtl+Th9wmjFEXdI2Z8uY0bdpXu2s18pILqWLe3pHo5TKtWFv4Vve
         CgQ01ADr+srsicbrN5chbZPEA+xSH6hzNOhFBBPU1dv+vz5RvOgR1C647DpTPo9mHo4G
         svUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=iFw2sRLELOLYsBPm0AR9UM8C+m1wBe5yITWVGlRCoL0=;
        b=mo0IoCpOT0G34YBrpxGDMEu510639IEA1TGXJgx9zWdBIe1qdRK3rB6yhvDlyysUKY
         oYaFlf8qNPJl4D4T4+2i9oGNbybvkOzq+6Fx9g1k7rCt4TK3LkNV6W7z2jic9kk7y+6Y
         j15GJmvP7fG97f1fHUMrgzuVOXLPtXEZlcHe9zAb5WfbDQoU7DD0Vo7HFrjOMulI5qtK
         Uh89m37Cphm0xd82MeeZlMPTWce59meOKY90Szf5wNqsKIXivaLFMTabK988tZl/8cJT
         SEGy99pHHAaTifTBYTW4iEQU3FqbqW9hJ0qrMD7u3gJxD+W4Wva4DfeaPQCxhvXdcZt8
         b0nw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a9si12423964ejs.42.2019.07.17.03.56.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 03:56:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 75F31B048;
	Wed, 17 Jul 2019 10:56:00 +0000 (UTC)
Subject: Re: [v2 PATCH 1/2] mm: mempolicy: make the behavior consistent when
 MPOL_MF_MOVE* and MPOL_MF_STRICT were specified
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@kernel.org,
 mgorman@techsingularity.net, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1561162809-59140-1-git-send-email-yang.shi@linux.alibaba.com>
 <1561162809-59140-2-git-send-email-yang.shi@linux.alibaba.com>
 <fb74d657-90cd-6667-f253-162c951f1b05@suse.cz>
 <efe90132-6832-d61a-5d55-d2cc134c7087@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <7806e608-ffcb-fd56-2e0f-a20bea127f40@suse.cz>
Date: Wed, 17 Jul 2019 12:55:59 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <efe90132-6832-d61a-5d55-d2cc134c7087@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/16/19 7:18 PM, Yang Shi wrote:
>> I think after your patch, you miss putback_movable_pages() in cases
>> where some were queued, and later the walk returned -EIO. The previous
>> code doesn't miss it, but it's also not obvious due to the multiple if
>> (!err) checks. I would rewrite it some thing like this:
>>
>> if (ret < 0) {
>>      putback_movable_pages(&pagelist);
>>      err = ret;
>>      goto mmap_out; // a new label above up_write()
>> }
> 
> Yes, the old code had putback_movable_pages called when !err. But, I 
> think that is for error handling of mbind_range() if I understand it 
> correctly since if queue_pages_range() returns -EIO (only MPOL_MF_STRICT 
> was specified and there was misplaced page) that page list should be 
> empty . The old code should checked whether that list is empty or not.

Hm I guess you're right, returning with EIO means nothing was queued.
> So, in the new code I just removed that.
> 
>>
>> The rest can have reduced identation now.
> 
> Yes, the goto does eliminate the extra indentation.
> 
>>
>>> +	else {
>>> +		err = mbind_range(mm, start, end, new);
>>>   
>>> -		if (nr_failed && (flags & MPOL_MF_STRICT))
>>> -			err = -EIO;
>>> -	} else
>>> -		putback_movable_pages(&pagelist);
>>> +		if (!err) {
>>> +			int nr_failed = 0;
>>> +
>>> +			if (!list_empty(&pagelist)) {
>>> +				WARN_ON_ONCE(flags & MPOL_MF_LAZY);
>>> +				nr_failed = migrate_pages(&pagelist, new_page,
>>> +					NULL, start, MIGRATE_SYNC,
>>> +					MR_MEMPOLICY_MBIND);
>>> +				if (nr_failed)
>>> +					putback_movable_pages(&pagelist);
>>> +			}
>>> +
>>> +			if ((ret > 0) ||
>>> +			    (nr_failed && (flags & MPOL_MF_STRICT)))
>>> +				err = -EIO;
>>> +		} else
>>> +			putback_movable_pages(&pagelist);
>> While at it, IIRC the kernel style says that when the 'if' part uses
>> '{ }' then the 'else' part should as well, and it shouldn't be mixed.
> 
> Really? The old code doesn't have '{ }' for else, and checkpatch doesn't 
> report any error or warning.

Checkpatch probably doesn't catch it, nor did the reviewers of the older
code. But coding-style.rst says:

Do not unnecessarily use braces where a single statement will do.

...

This does not apply if only one branch of a conditional statement is a
single
statement; in the latter case use braces in both branches:

.. code-block:: c

        if (condition) {
                do_this();
                do_that();
        } else {
                otherwise();
        }


Thanks,
Vlastimil

