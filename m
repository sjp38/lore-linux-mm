Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6932C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 12:52:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91DED2184E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 12:52:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91DED2184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B2036B000A; Thu, 11 Apr 2019 08:52:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13C1D6B000C; Thu, 11 Apr 2019 08:52:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF7396B000D; Thu, 11 Apr 2019 08:52:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9F8B16B000A
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 08:52:12 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y7so3032856eds.7
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 05:52:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc:from
         :subject:openpgp:autocrypt:message-id:date:user-agent:mime-version
         :content-language:content-transfer-encoding;
        bh=znZcNJjqDeGe5SQ1Uk+hTNDHo5JxLftmWQV6SoOsQ5c=;
        b=e0vzTET2lux16gXxBtECsjoENHhZyplUHEQ7K/A6T8kiRczkVYvIbs0RDLfqx1yHay
         sRwz8zAVBJc6QFQmoYqr5zhE1tjA5OQLQk57eNzzlAa1jVq0zoiG5sbMhzpmb7DM1f3s
         fZxSEZ/u6xUbWqVfVXAVjCCbpUsSN6aUqvTKWDV4alnBJ9z6bsUBoV9qbZ0OLkQchwOJ
         WLTqNnPsk7lPp46+OCpfzFnHz15Ej4bOSuLVk93hOSIwYrbJLxX60TpO7gmGjNLszqC9
         PaOXhG9jaPSXrxyTUP0NbBYz4KGyMTU7OK0XRgAU4fK2NTostyxm2mGNDKcc5SmMO8Yh
         R2Mg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAVqVv5mOFSGlSgSHtFvO3TxDVsLTeczK2Y12ICrgYOz8coeT+Jj
	z0XVRnYT6QFRet8LfPiYZbQlYiuQfiYwk014jiehurJj0Od8DKalIMNfcZGC07jXOiQ9KOjPHPQ
	80dYLwc8I+3gELQYGLMPTDj5xEd38vEZiTS8e2Wx73i2xM3YGgXI9FXhoaTZZtRyNcg==
X-Received: by 2002:a50:c40f:: with SMTP id v15mr30514705edf.236.1554987132133;
        Thu, 11 Apr 2019 05:52:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkHqefspzln0oiyJAd0E3qXDe39AFOSNWH4V9AxgI2+jVwEXhEE3xNLZXNxBWNU26X0hY5
X-Received: by 2002:a50:c40f:: with SMTP id v15mr30514648edf.236.1554987131227;
        Thu, 11 Apr 2019 05:52:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554987131; cv=none;
        d=google.com; s=arc-20160816;
        b=j9933gEPNlbp0zrgfe5guHkuE9cmg68yTZXBG7nkS7DULQZWZeObfAV/cKdRAmKGrH
         2V1mYrtCo2Ia1PxMa0V1LCqS1nRVZzPm/enZojaFTqzmKO1LoqoXmz1ZdyJEKuE+pxt/
         46mCP3dZDqaptFKbWX5QLZTGax9y+R7lbQE1+T7RcrolDtZGqlux1S1si5F6ILJ587Gw
         2FD9L0CABv6ikd2kGJXKg4tGov/CmfA5fkTa+lZ+tE2t0eYpA3iusBYrugM3qeJieW1F
         +PcjhBH/e35/tdZDwYAgVYZjLkRp/Pg/ZEsaFtIAuCVAmUuHXAhMvThyW49b3TOAXFdd
         iYag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:autocrypt:openpgp:subject:from:cc:to;
        bh=znZcNJjqDeGe5SQ1Uk+hTNDHo5JxLftmWQV6SoOsQ5c=;
        b=FGlJa4mcG9D8Dd8iJ1a1dxCLjTnKypnu5TerNgWRJM0lcTb9mqpOoZJ9FhiiFU+IMH
         8xQSHz7HOyfph/g4caut2qnHGzgvq9xRN7OaM9lhzavG4cFMg5Gx4rFbxCsYr5rvErfS
         nBhdbOIMYwhaU0dVJe0jlPCMf6JW8f36eg2E2oWFvEfBw1SxNWoDGO8sIALNig7exwOF
         v/uIkCwwqFjuaixCStjDwNKUDF/FuphwEZUOXet8ceUqTfXlxHoa+JNvqqJ3F52l4fef
         PKwGwPdm3B8tsthf0WGoOEQQ2nb+2ErfCCK+/jpNtrR/fpWCkDEYTuRJ2eyvScfESbQy
         J8JQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h17si1847004ejj.366.2019.04.11.05.52.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 05:52:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6ACC2AC5F;
	Thu, 11 Apr 2019 12:52:10 +0000 (UTC)
To: lsf-pc@lists.linux-foundation.org
Cc: Linux-FSDevel <linux-fsdevel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, linux-block@vger.kernel.org,
 Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>,
 David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ming Lei <ming.lei@redhat.com>,
 linux-xfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
 Dave Chinner <david@fromorbit.com>,
 "Darrick J . Wong" <darrick.wong@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [LSF/MM TOPIC] guarantee natural alignment for kmalloc()?
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
Message-ID: <790b68b7-3689-0ff6-08ae-936728bc6458@suse.cz>
Date: Thu, 11 Apr 2019 14:52:08 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

here's a late topic for discussion that came out of my patchset [1]. It
would likely have to involve all three groups, as FS/IO people would
benefit, but it's MM area.

Background:
The recent thread [2] inspired me to look into guaranteeing alignment
for kmalloc() for power-of-two sizes. IIUC some usecases (see [2]) don't
know the required sizes in advance in order to create named caches via
kmem_cache_create() with explicit alignment parameter (which is the only
way to guarantee alignment right now). Moreover, in most cases the
alignment happens naturally as the slab allocators split
power-of-two-sized pages into smaller power-of-two-sized objects.
kmalloc() users then might rely on the alignment even unknowingly, until
it breaks when e.g. SLUB debugging is enabled.

Turns out it's not difficult to add the guarantees [1] and in the
production SLAB/SLUB configurations nothing really changes as explained
above. Then folks wouldn't have to come up with workarounds as in [2].
Technical downsides would be for SLUB debug mode (increased memory
fragmentation, should be acceptable in a bug hunting scenario?), and
SLOB (potentially worse performance due to increased packing effort, but
this slab variant is rather marginal).

In the session I hope to resolve the question whether this is indeed the
right thing to do for all kmalloc() users, without an explicit alignment
requests, and if it's worth the potentially worse
performance/fragmentation it would impose on a hypothetical new slab
implementation for which it wouldn't be optimal to split power-of-two
sized pages into power-of-two-sized objects (or whether there are any
other downsides).

Thanks,
Vlastimil

[1] https://lore.kernel.org/lkml/20190319211108.15495-1-vbabka@suse.cz/T/#u
[2]
https://lore.kernel.org/linux-fsdevel/20190225040904.5557-1-ming.lei@redhat.com/T/#u

