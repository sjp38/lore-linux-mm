Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FF1DC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 08:02:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D58620818
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 08:02:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D58620818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D3056B026F; Wed, 10 Apr 2019 04:02:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95C066B0270; Wed, 10 Apr 2019 04:02:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D5036B0271; Wed, 10 Apr 2019 04:02:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 269986B026F
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 04:02:40 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id 41so797628edr.19
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 01:02:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=O/HeNsU4l+tNkawzUeWOr7ltX1+iSbwR6OtOi2QwfP4=;
        b=Nu3Y908zRDt6XRZba1hgrPbcCI0KFtod2TDaDi12H0mAF2uRZnU3pqGBfOeXnHS9Bn
         KsGNFEogsgywdalVfgmaNLa1u4Ye2JuyjtUfiNJKe9d3XsEM6pb14+ufMjip2vhu/I5P
         Z/mJ6gQmzKm3n6jqz5gdUxIWtV3EVTpBoCJeE9rB0enii4APEv1G3UJgZIRVpjxAAFZ0
         vBNi/hakzY0SFswW7JElD5mc+yrKFGe09szqM2BhFrZU0NthfwyouiZjkE8+9hE8qnM4
         e1+NTiMJgb6ZYYA7mAwwyYIuMy0QlUxvE+THY852ZM7jPv9cN/RZUKkYK7acXOntZn/Y
         mV3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUFVSVhbMB3uNXsx6eH9H3MPnx9SqppO+BsUxmVxzTpfrKi10Vz
	koJ70o16prP/wIkOE4C79PuM2skJk/y7AlBYxipaGotZO5KbnNSHEdqZWW6N9oFaNtcuDaax017
	mlwwEaXv77hQ9KKn37br31KjIROp7XCRlfzNkbT/A2hpC5zSWlz1ho261kZskvixuMw==
X-Received: by 2002:a17:906:4bd6:: with SMTP id x22mr9990025ejv.234.1554883359694;
        Wed, 10 Apr 2019 01:02:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDtnXqLH4roIHXUCWX8PmqWrRvu9X2xbaMRdZlJ0m4YEN3w+ZCa/1h9tD5pi5Ik4Rs5Dkx
X-Received: by 2002:a17:906:4bd6:: with SMTP id x22mr9989983ejv.234.1554883358810;
        Wed, 10 Apr 2019 01:02:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554883358; cv=none;
        d=google.com; s=arc-20160816;
        b=WzY9B/AjtpNrKXbs+wu/XxnnaewAwzHs/AXWBNjO8fdhhXqQdPb2B8ZD5T+/un97lD
         SXtpG6LTJRfP90a0sP8PUz8YEqERU075xxwiGe0dJw8Yc/2/byY+XELYH+waEiONtUEq
         RgdMp78vZy8IQE2yhgJBefZqpvryV16iPBC0xHcN6vilcIiv/SW6M7wP/HZi4xHzGWU2
         lD4aKuTFip+VKsFwW/ydpFSo179CLllXNLMSVRdYfg54hk0J+P5++AEMTxaVJk/45HUQ
         8s0mNEZi64KZkNZHXri2LOEDQ32k9+Y1EIF889ctuP+3gAYuE9VxJoma3x2aDa2mGS65
         fVOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=O/HeNsU4l+tNkawzUeWOr7ltX1+iSbwR6OtOi2QwfP4=;
        b=Nn1fIANkVGY0vQewKGpD9QDtn7PpCdW0zeatea9zzQVULZrYQ8dJ5g6aOU38OKMyyR
         HeR91NHFr5bigHV5y6DCFQY0ludK9Y8M0ZtkWMbBq58McnLKglkqSizBl0d0QVk707eq
         0iknjsLvcJsPcnixoxokq0XDpDJ1IKmrpHYJKLWcpHVo/UI7IjwBkGGx847+VVSYqs6H
         0b2I98138MzroTSjwG1ANVxx2oC6YcxugfuClyZPuCdR5AP1LGQRsT1TFXNgFZSF2Jvu
         HrGbofVWe1sQ91HWTNqyR9RJABPhOnSeugmPY29E9UUmGH9k5l5wjPCQbj8RI+OfYMoo
         gEIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x98si4743674ede.377.2019.04.10.01.02.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 01:02:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 34E84B10B;
	Wed, 10 Apr 2019 08:02:38 +0000 (UTC)
Subject: Re: [PATCH 0/1] mm: Remove the SLAB allocator
To: "Tobin C. Harding" <tobin@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Tejun Heo <tj@kernel.org>, Qian Cai <cai@lca.pw>,
 Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>
References: <20190410024714.26607-1-tobin@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 mQINBFZdmxYBEADsw/SiUSjB0dM+vSh95UkgcHjzEVBlby/Fg+g42O7LAEkCYXi/vvq31JTB
 KxRWDHX0R2tgpFDXHnzZcQywawu8eSq0LxzxFNYMvtB7sV1pxYwej2qx9B75qW2plBs+7+YB
 87tMFA+u+L4Z5xAzIimfLD5EKC56kJ1CsXlM8S/LHcmdD9Ctkn3trYDNnat0eoAcfPIP2OZ+
 9oe9IF/R28zmh0ifLXyJQQz5ofdj4bPf8ecEW0rhcqHfTD8k4yK0xxt3xW+6Exqp9n9bydiy
 tcSAw/TahjW6yrA+6JhSBv1v2tIm+itQc073zjSX8OFL51qQVzRFr7H2UQG33lw2QrvHRXqD
 Ot7ViKam7v0Ho9wEWiQOOZlHItOOXFphWb2yq3nzrKe45oWoSgkxKb97MVsQ+q2SYjJRBBH4
 8qKhphADYxkIP6yut/eaj9ImvRUZZRi0DTc8xfnvHGTjKbJzC2xpFcY0DQbZzuwsIZ8OPJCc
 LM4S7mT25NE5kUTG/TKQCk922vRdGVMoLA7dIQrgXnRXtyT61sg8PG4wcfOnuWf8577aXP1x
 6mzw3/jh3F+oSBHb/GcLC7mvWreJifUL2gEdssGfXhGWBo6zLS3qhgtwjay0Jl+kza1lo+Cv
 BB2T79D4WGdDuVa4eOrQ02TxqGN7G0Biz5ZLRSFzQSQwLn8fbwARAQABtCBWbGFzdGltaWwg
 QmFia2EgPHZiYWJrYUBzdXNlLmN6PokCVAQTAQoAPgIbAwULCQgHAwUVCgkICwUWAgMBAAIe
 AQIXgBYhBKlA1DSZLC6OmRA9UCJPp+fMgqZkBQJcbbyGBQkH8VTqAAoJECJPp+fMgqZkpGoP
 /1jhVihakxw1d67kFhPgjWrbzaeAYOJu7Oi79D8BL8Vr5dmNPygbpGpJaCHACWp+10KXj9yz
 fWABs01KMHnZsAIUytVsQv35DMMDzgwVmnoEIRBhisMYOQlH2bBn/dqBjtnhs7zTL4xtqEcF
 1hoUFEByMOey7gm79utTk09hQE/Zo2x0Ikk98sSIKBETDCl4mkRVRlxPFl4O/w8dSaE4eczH
 LrKezaFiZOv6S1MUKVKzHInonrCqCNbXAHIeZa3JcXCYj1wWAjOt9R3NqcWsBGjFbkgoKMGD
 usiGabetmQjXNlVzyOYdAdrbpVRNVnaL91sB2j8LRD74snKsV0Wzwt90YHxDQ5z3M75YoIdl
 byTKu3BUuqZxkQ/emEuxZ7aRJ1Zw7cKo/IVqjWaQ1SSBDbZ8FAUPpHJxLdGxPRN8Pfw8blKY
 8mvLJKoF6i9T6+EmlyzxqzOFhcc4X5ig5uQoOjTIq6zhLO+nqVZvUDd2Kz9LMOCYb516cwS/
 Enpi0TcZ5ZobtLqEaL4rupjcJG418HFQ1qxC95u5FfNki+YTmu6ZLXy+1/9BDsPuZBOKYpUm
 3HWSnCS8J5Ny4SSwfYPH/JrtberWTcCP/8BHmoSpS/3oL3RxrZRRVnPHFzQC6L1oKvIuyXYF
 rkybPXYbmNHN+jTD3X8nRqo+4Qhmu6SHi3VquQENBFsZNQwBCACuowprHNSHhPBKxaBX7qOv
 KAGCmAVhK0eleElKy0sCkFghTenu1sA9AV4okL84qZ9gzaEoVkgbIbDgRbKY2MGvgKxXm+kY
 n8tmCejKoeyVcn9Xs0K5aUZiDz4Ll9VPTiXdf8YcjDgeP6/l4kHb4uSW4Aa9ds0xgt0gP1Xb
 AMwBlK19YvTDZV5u3YVoGkZhspfQqLLtBKSt3FuxTCU7hxCInQd3FHGJT/IIrvm07oDO2Y8J
 DXWHGJ9cK49bBGmK9B4ajsbe5GxtSKFccu8BciNluF+BqbrIiM0upJq5Xqj4y+Xjrpwqm4/M
 ScBsV0Po7qdeqv0pEFIXKj7IgO/d4W2bABEBAAGJA3IEGAEKACYWIQSpQNQ0mSwujpkQPVAi
 T6fnzIKmZAUCWxk1DAIbAgUJA8JnAAFACRAiT6fnzIKmZMB0IAQZAQoAHRYhBKZ2GgCcqNxn
 k0Sx9r6Fd25170XjBQJbGTUMAAoJEL6Fd25170XjDBUH/2jQ7a8g+FC2qBYxU/aCAVAVY0NE
 YuABL4LJ5+iWwmqUh0V9+lU88Cv4/G8fWwU+hBykSXhZXNQ5QJxyR7KWGy7LiPi7Cvovu+1c
 9Z9HIDNd4u7bxGKMpn19U12ATUBHAlvphzluVvXsJ23ES/F1c59d7IrgOnxqIcXxr9dcaJ2K
 k9VP3TfrjP3g98OKtSsyH0xMu0MCeyewf1piXyukFRRMKIErfThhmNnLiDbaVy6biCLx408L
 Mo4cCvEvqGKgRwyckVyo3JuhqreFeIKBOE1iHvf3x4LU8cIHdjhDP9Wf6ws1XNqIvve7oV+w
 B56YWoalm1rq00yUbs2RoGcXmtX1JQ//aR/paSuLGLIb3ecPB88rvEXPsizrhYUzbe1TTkKc
 4a4XwW4wdc6pRPVFMdd5idQOKdeBk7NdCZXNzoieFntyPpAq+DveK01xcBoXQ2UktIFIsXey
 uSNdLd5m5lf7/3f0BtaY//f9grm363NUb9KBsTSnv6Vx7Co0DWaxgC3MFSUhxzBzkJNty+2d
 10jvtwOWzUN+74uXGRYSq5WefQWqqQNnx+IDb4h81NmpIY/X0PqZrapNockj3WHvpbeVFAJ0
 9MRzYP3x8e5OuEuJfkNnAbwRGkDy98nXW6fKeemREjr8DWfXLKFWroJzkbAVmeIL0pjXATxr
 +tj5JC0uvMrrXefUhXTo0SNoTsuO/OsAKOcVsV/RHHTwCDR2e3W8mOlA3QbYXsscgjghbuLh
 J3oTRrOQa8tUXWqcd5A0+QPo5aaMHIK0UAthZsry5EmCY3BrbXUJlt+23E93hXQvfcsmfi0N
 rNh81eknLLWRYvMOsrbIqEHdZBT4FHHiGjnck6EYx/8F5BAZSodRVEAgXyC8IQJ+UVa02QM5
 D2VL8zRXZ6+wARKjgSrW+duohn535rG/ypd0ctLoXS6dDrFokwTQ2xrJiLbHp9G+noNTHSan
 ExaRzyLbvmblh3AAznb68cWmM3WVkceWACUalsoTLKF1sGrrIBj5updkKkzbKOq5gcC5AQ0E
 Wxk1NQEIAJ9B+lKxYlnKL5IehF1XJfknqsjuiRzj5vnvVrtFcPlSFL12VVFVUC2tT0A1Iuo9
 NAoZXEeuoPf1dLDyHErrWnDyn3SmDgb83eK5YS/K363RLEMOQKWcawPJGGVTIRZgUSgGusKL
 NuZqE5TCqQls0x/OPljufs4gk7E1GQEgE6M90Xbp0w/r0HB49BqjUzwByut7H2wAdiNAbJWZ
 F5GNUS2/2IbgOhOychHdqYpWTqyLgRpf+atqkmpIJwFRVhQUfwztuybgJLGJ6vmh/LyNMRr8
 J++SqkpOFMwJA81kpjuGR7moSrUIGTbDGFfjxmskQV/W/c25Xc6KaCwXah3OJ40AEQEAAYkC
 PAQYAQoAJhYhBKlA1DSZLC6OmRA9UCJPp+fMgqZkBQJbGTU1AhsMBQkDwmcAAAoJECJPp+fM
 gqZkPN4P/Ra4NbETHRj5/fM1fjtngt4dKeX/6McUPDIRuc58B6FuCQxtk7sX3ELs+1+w3eSV
 rHI5cOFRSdgw/iKwwBix8D4Qq0cnympZ622KJL2wpTPRLlNaFLoe5PkoORAjVxLGplvQIlhg
 miljQ3R63ty3+MZfkSVsYITlVkYlHaSwP2t8g7yTVa+q8ZAx0NT9uGWc/1Sg8j/uoPGrctml
 hFNGBTYyPq6mGW9jqaQ8en3ZmmJyw3CHwxZ5FZQ5qc55xgshKiy8jEtxh+dgB9d8zE/S/UGI
 E99N/q+kEKSgSMQMJ/CYPHQJVTi4YHh1yq/qTkHRX+ortrF5VEeDJDv+SljNStIxUdroPD29
 2ijoaMFTAU+uBtE14UP5F+LWdmRdEGS1Ah1NwooL27uAFllTDQxDhg/+LJ/TqB8ZuidOIy1B
 xVKRSg3I2m+DUTVqBy7Lixo73hnW69kSjtqCeamY/NSu6LNP+b0wAOKhwz9hBEwEHLp05+mj
 5ZFJyfGsOiNUcMoO/17FO4EBxSDP3FDLllpuzlFD7SXkfJaMWYmXIlO0jLzdfwfcnDzBbPwO
 hBM8hvtsyq8lq8vJOxv6XD6xcTtj5Az8t2JjdUX6SF9hxJpwhBU0wrCoGDkWp4Bbv6jnF7zP
 Nzftr4l8RuJoywDIiJpdaNpSlXKpj/K6KrnyAI/joYc7
Message-ID: <f06aaeae-28c0-9ea4-d795-418ec3362d17@suse.cz>
Date: Wed, 10 Apr 2019 10:02:36 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190410024714.26607-1-tobin@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/10/19 4:47 AM, Tobin C. Harding wrote:
> Recently a 2 year old bug was found in the SLAB allocator that crashes
> the kernel.  This seems to imply that not that many people are using the
> SLAB allocator.

AFAIK that bug required CONFIG_DEBUG_SLAB_LEAK, not just SLAB. That
seems to imply not that many people are using SLAB when debugging and
yeah, SLUB has better debugging support. But I wouldn't dare to make the
broader implication :)

> Currently we have 3 slab allocators.  Two is company three is a crowd -
> let's get rid of one. 
> 
>  - The SLUB allocator has been the default since 2.6.23

Yeah, with a sophisticated reasoning :)
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=a0acd820807680d2ccc4ef3448387fcdbf152c73

>  - The SLOB allocator is kinda sexy.  Its only 664 LOC, the general
>    design is outlined in KnR, and there is an optimisation taken from
>    Knuth - say no more.
> 
> If you are using the SLAB allocator please speak now or forever hold your peace ...

FWIW, our enterprise kernel use it (latest is 4.12 based), and openSUSE
kernels as well (with openSUSE Tumbleweed that includes latest
kernel.org stables). AFAIK we don't enable SLAB_DEBUG even in general
debug kernel flavours as it's just too slow.

IIRC last time Mel evaluated switching to SLUB, it wasn't a clear
winner, but I'll just CC him for details :)

> Testing:
> 
> Build kernel with `make defconfig` (on x86_64 machine) followed by `make
> kvmconfig`.  Then do the same and manually select SLOB.  Boot both
> kernels in Qemu.
> 
> 
> thanks,
> Tobin.
> 
> 
> Tobin C. Harding (1):
>   mm: Remove SLAB allocator
> 
>  include/linux/slab.h |   26 -
>  kernel/cpu.c         |    5 -
>  mm/slab.c            | 4493 ------------------------------------------
>  mm/slab.h            |   31 +-
>  mm/slab_common.c     |   20 +-
>  5 files changed, 5 insertions(+), 4570 deletions(-)
>  delete mode 100644 mm/slab.c
> 

