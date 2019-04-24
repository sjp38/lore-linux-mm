Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEB41C282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:39:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D009221902
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:38:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D009221902
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BC196B0006; Wed, 24 Apr 2019 10:38:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76B2F6B026B; Wed, 24 Apr 2019 10:38:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 634E26B026C; Wed, 24 Apr 2019 10:38:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 15C1C6B0006
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:38:59 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o8so9997988edh.12
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:38:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=OcSzPFGs2F9L2nr2KYx4RD8IMFMmjRDWXqifNCgttxI=;
        b=V+70TiPYVAK8xo9o0lNQl44hqIhhVPrf2Zg72MRz7X/8Coh9OvtZgi8+PZbYNP1Q4P
         rdDYep39YHiVOe1WEkt1yhMsANCFzJZcCd3+r4rK1vBMlvE9UDbNqQ/T4nSkKlNCK+Dr
         pDWbHmlnUL6GwdCewAEt2OZ+0YeGruqRrV6pgBWrGc/6M68Omj/K0mHTcaY1kZG8tU0s
         Hqr9AMW5vby242gm32iPAw5e6x6PKsQYpsJAUuu2pU3LHcjxYPIu19p3LhMJ+6j0I3S7
         NL5g0Y1KsEzDSd/V9qmpoa2Deeh52mvFfx+GoS3oS41s1qwot4wpE7+KX5URxycF9qYt
         JKcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAWtm/k844Y6p2xxdOzesgFRbcuyoDneOX+FWevzHrwXz0RcEvt1
	6BoHuDn5c2IUAb+gTgkd5eIto85hPD6QitHOybaf2dPOM75YLRCVVgIc2JIblhwlcHLuA5nZ9AC
	huWUgmCj1okGHjUdqMWc13UVt2kW2I9vS9fqGo8pQvj8UALjOMSUfs6DHI07K+CfMQg==
X-Received: by 2002:aa7:da81:: with SMTP id q1mr19995516eds.116.1556116738673;
        Wed, 24 Apr 2019 07:38:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/diAPGSQkQ+/KXapL+dlFeGmi9uIyO7yXBKJevdQNHZs0zWkcG9rOqWYbj74tobdZXfTK
X-Received: by 2002:aa7:da81:: with SMTP id q1mr19995471eds.116.1556116737756;
        Wed, 24 Apr 2019 07:38:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556116737; cv=none;
        d=google.com; s=arc-20160816;
        b=c58PKxselzo8R/qTpzJ6yzZecM/y7ut06XfH5T09c/nLR7thvn3zPqnVTrtNmyQf3Y
         ogdpmvfbaCcKU1wrDSPRwwnWE7pxu4CMbIdNIbUavl1NhyLGdVa46cpwoYEV2Whbgbhs
         18sFH4G1Ukyb8vjc6NvZZLedBcC9tCEtrvObMfnseCiKa1tgH06nUADx8RJ1ogtRZ0up
         9COShracoG9nPqWjJOwHy7eOwlGY0TeYR/ZdvcxwNqic4CCjzCjjojqKTWh6pgs1BU6A
         khKO9CZWnph5kM4YQtz1234IElTdc6eSMcTJOZcDcbeLtHsqabTM470TpaAiepi/Rtlf
         uR+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=OcSzPFGs2F9L2nr2KYx4RD8IMFMmjRDWXqifNCgttxI=;
        b=l018ZWesToMzMJpeR8h3f6thzw2/f3lc1SC20rSZdE+wfAKPSodT0KLjGg1ioDU7ik
         VxuvzVUx2uArgNqDrMaPXbTp4r+bBwGJoPT339cqZl7jAl+jHsDF8gDdNCufTo3Vprng
         2zVfYtDcq7mgz3Mhg+oGNvQeaJ4EmtuOTXzQY9L0GBKh84kLwAD6d6snmQKXwbU3dqkp
         MC41g6NxawywcqVhZX1RpZnHz2g6DzMNmCkBGFp5Tmr9IeqW5ntR4PW5Tau5dzp9KIYY
         tZcURuGp2KHPvdK3nQkYqqxb0MWPP25SRBostzcUmBDM5v5YF5+IvGmbFA2cuG6vgFVv
         QN7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o10si3243180ejd.258.2019.04.24.07.38.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 07:38:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 22A71AC61;
	Wed, 24 Apr 2019 14:38:57 +0000 (UTC)
Subject: Re: [Question] Should direct reclaim time be bounded?
To: Mike Kravetz <mike.kravetz@oracle.com>, Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
 linux-kernel <linux-kernel@vger.kernel.org>,
 Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>,
 Johannes Weiner <hannes@cmpxchg.org>
References: <d38a095e-dc39-7e82-bb76-2c9247929f07@oracle.com>
 <20190423071953.GC25106@dhcp22.suse.cz>
 <eac582cf-2f76-4da1-1127-6bb5c8c959e4@oracle.com>
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
Message-ID: <04329fea-cd34-4107-d1d4-b2098ebab0ec@suse.cz>
Date: Wed, 24 Apr 2019 16:35:37 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <eac582cf-2f76-4da1-1127-6bb5c8c959e4@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/23/19 6:39 PM, Mike Kravetz wrote:
>> That being said, I do not think __GFP_RETRY_MAYFAIL is wrong here. It
>> looks like there is something wrong in the reclaim going on.
> 
> Ok, I will start digging into that.  Just wanted to make sure before I got
> into it too deep.
> 
> BTW - This is very easy to reproduce.  Just try to allocate more huge pages
> than will fit into memory.  I see this 'reclaim taking forever' behavior on
> v5.1-rc5-mmotm-2019-04-19-14-53.  Looks like it was there in v5.0 as well.

I'd suspect this in should_continue_reclaim():

        /* Consider stopping depending on scan and reclaim activity */
        if (sc->gfp_mask & __GFP_RETRY_MAYFAIL) {
                /*
                 * For __GFP_RETRY_MAYFAIL allocations, stop reclaiming if the
                 * full LRU list has been scanned and we are still failing
                 * to reclaim pages. This full LRU scan is potentially
                 * expensive but a __GFP_RETRY_MAYFAIL caller really wants to succeed
                 */
                if (!nr_reclaimed && !nr_scanned)
                        return false;

And that for some reason, nr_scanned never becomes zero. But it's hard
to figure out through all the layers of functions :/

