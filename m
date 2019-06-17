Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FAD3C31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:17:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C8CC2084D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:17:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C8CC2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABDBB8E0004; Mon, 17 Jun 2019 08:17:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6E778E0001; Mon, 17 Jun 2019 08:17:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 936698E0004; Mon, 17 Jun 2019 08:17:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 453A78E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:17:26 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o13so16186447edt.4
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:17:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=13wzpY1Clc9deve4PuEPaYMvG5EUzexKDMBUBXFFTgw=;
        b=IiYwS2A1izLk8KxJewbJt3v+rljIXaYUZJWPpnFNdRoqHOGEhgWykpyuec2MIJVCeK
         GLLn93qneO0Bsuo90wsmk6pWNUOxtI24DmaXepM8opJiOKgsmjw//jy9TWWBIFkH5BaT
         qu6nBWRx58ZVeXdQkeJSmLxEPVUOzqzhs2FfDBxSRLJt280oOfvSsFgmijwEppeSaZhZ
         osx/gEYeOk3KKpLeZSJ40H6uVV+hDmWNW7QABxLcI5T5bnw6tVKMH24uqq2yJubOAwMT
         AIWDop7VVTncTJjZX/jahodAxYVLdMfDkeBw2P2pnsiN6LXATnYudemJ4xaNhTYKDQj8
         WLbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXTuM1aQO84fZx6HRbSlwPaIkL4zMqglf0rYxkfF7fU8I9Xew0L
	Z0v79AzWcNoJh6INT2pUdqYQMm8bpQ2qqoMdO6OciiakqOXZMhwih21f5y3UD8LsG6IwOxvnI6k
	LBZC2ZJmoT7TR0KBToFmlkDas87HBGsEX/DG/lnJhllPehwqKUYZAFIQf6miJ5EKumQ==
X-Received: by 2002:a50:974b:: with SMTP id d11mr82099970edb.24.1560773845858;
        Mon, 17 Jun 2019 05:17:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiBfNcXNghZMDLmJfywd9PdEKBkxz+zBmSlWMwL4R2K8D6H4+6oUAWQmRJ+/UrBASxyY/R
X-Received: by 2002:a50:974b:: with SMTP id d11mr82099878edb.24.1560773844934;
        Mon, 17 Jun 2019 05:17:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560773844; cv=none;
        d=google.com; s=arc-20160816;
        b=wpbfsxfzZeY1wegAreZtHcynxddB0+GUs8MZ+p99Yl0D4+nA+obMX0nsnMjGl5m34C
         qJBHt5muQrrr6lfrQSNO2/N+YrhVqTXZNN5BPY5n+P+ErHBQ8xftNdjHGj1VPrrmanBF
         FZuGZrRrA7ccDWLKLNMqEVYSZV5gvLJlzzOXHtlr0ysPJkL+2UrkrduAqdS2QseTHAPb
         ahYmUgmt6FEMRTboPQuIcnx2ePJJ+dJwjkHCLZouCzjkUHD3HKFZsxpJMbg7cJldpB8T
         OJ+g6twA0F0JazZTgd/gFZWArVkG5dDFeoTFB/cB5MfNrPBYN6WaMFnad2/DWsNzbtq6
         LoEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=13wzpY1Clc9deve4PuEPaYMvG5EUzexKDMBUBXFFTgw=;
        b=QUnYQUVF0jsbcZEIewihsAgJfDGQqjh6fzKG18XuAi12hqS5BUZhPmjv4G1Vou0Inw
         Yl+4NvVnIX45yaSiU+X3CnMTxoEJk/MUd6K9vu2KMZzz3HF+w2ucYoMGcVO7w5z4IVVK
         SpilekXYosuz3OTmcP6FR2ZKhCd+FwD1ocWjp+esx9n8EwtAcq8IhK8CWpYMoX0bHm0n
         cyvls5AAM4UvyE8QbSGpbjBu40Y30JL+2VLt1lIfPnlmUM19Yrd1Lhpsu6KR2Iz2ijJC
         iv8lsp20YKU8cFrgdXau9oTi7RrQ1+5rmJu7t8E1PPcWap8wgXCfjvECqzIA5W1CMNh1
         IK2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i15si6831564ejp.201.2019.06.17.05.17.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 05:17:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7E18FAE5A;
	Mon, 17 Jun 2019 12:17:24 +0000 (UTC)
Subject: Re: kernel BUG at mm/swap_state.c:170!
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
 Michal Hocko <mhocko@kernel.org>
Cc: Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
 linux-mm@kvack.org
References: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
 <CABXGCsNq4xTFeeLeUXBj7vXBz55aVu31W9q74r+pGM83DrPjfA@mail.gmail.com>
 <20190529180931.GI18589@dhcp22.suse.cz>
 <CABXGCsPrk=WJzms_H+-KuwSRqWReRTCSs-GLMDsjUG_-neYP0w@mail.gmail.com>
 <CABXGCsMjDn0VT0DmP6qeuiytce9cNBx8PywpqejiFNVhwd0UGg@mail.gmail.com>
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
Message-ID: <ee245af2-a0ae-5c13-6f1f-2418f43d1812@suse.cz>
Date: Mon, 17 Jun 2019 14:17:24 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CABXGCsMjDn0VT0DmP6qeuiytce9cNBx8PywpqejiFNVhwd0UGg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 6/16/19 12:12 PM, Mikhail Gavrilov wrote:
> Hi,
> I finished today bisecting kernel.
> And first bad commit for me was cd736d8b67fb22a85a68c1ee8020eb0d660615ec

That's commit "tcp: fix retrans timestamp on passive Fast Open" which is
almost certainly not the culprit.

> Can you look into this?
> 
> 
> $ git bisect log
> git bisect start
> # good: [a188339ca5a396acc588e5851ed7e19f66b0ebd9] Linux 5.2-rc1
> git bisect good a188339ca5a396acc588e5851ed7e19f66b0ebd9
> # good: [a188339ca5a396acc588e5851ed7e19f66b0ebd9] Linux 5.2-rc1
> git bisect good a188339ca5a396acc588e5851ed7e19f66b0ebd9

You told bisect that 5.2-rc1 is good, but it probably isn't.
What you probably need to do is:
git bisect good v5.1
git bisect bad v5.2-rc2

The presence of the other ext4 bug complicates the bisect, however.
According to tytso in the thread you linked, it should be fixed by
commit 0a944e8a6c66, while the bug was introduced by commit
345c0dbf3a30. So in each step of bisect, before building the kernel, you
should cherry-pick the fix if the bug is there:

git merge-base --is-ancestor 345c0dbf3a30 HEAD && git cherry-pick 0a944e8a6c66

Also in case you see a completely different problem in some bisect step, try
'git bisect skip' instead of guessing if it's good or bad.
Hopefully that will lead to a better result.

