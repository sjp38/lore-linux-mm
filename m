Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D9F5C46470
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 12:11:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58D7121734
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 12:11:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58D7121734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEEFE6B0003; Mon, 29 Apr 2019 08:11:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4E8A6B0005; Mon, 29 Apr 2019 08:11:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF0666B0007; Mon, 29 Apr 2019 08:11:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 747946B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 08:11:57 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id u6so11682964wml.3
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 05:11:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=fNgtKi8T64RHceHJupE8PdZ7i8PveePQCjbL80UGZm0=;
        b=Lhq9Ay4ZBDzU3IVL/Ym6JoEKA+WXcOiJuNPQizy78R/gaimpHWymKgyNaKWK6m1cOC
         LKUS4G1XuhazNav5Nm1TUYBasH7AmmD/Y+flTzZSFaH1kTpuIwFYnmDLgn3Y5r8iB5M/
         knFug7Wtge6rzbNz8ALuvieqFHpX7GYD1SN2GNXJ6gpAyre8UOyLE77s9NVQqBO97Qbl
         v5WIg14THQY3GO1/3TgCx6VwdM2BuUXkx8cPwbGc+L9FYuD+QzIEZR3sE9JWDwVXayQT
         VLNgFQupV+s8diT/L2a+E+b6AIhRKtUnivdphtZ7kdomL3HMYK7zam+PDDlmLZtGnJDB
         Cgug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
X-Gm-Message-State: APjAAAVenA4GKI6MVAvqdnS935Xf5DE6g5eEUOH1N9KasZWr9qSJBOQM
	EzlKZdIgOA6/hwXL9HznRi/+EiRnDtR8uJ5682MyvoMxYaYfvc5Yz2M4bmYvJChMmyfhK4VdA6q
	uB6t+VSlxXy+0lOKIQFRuh3rf+ngs9P0Hk9sky7ra0+CrUuS5Zm9xCxw8FJMid28=
X-Received: by 2002:adf:d84f:: with SMTP id k15mr85851wrl.301.1556539917079;
        Mon, 29 Apr 2019 05:11:57 -0700 (PDT)
X-Received: by 2002:adf:d84f:: with SMTP id k15mr85817wrl.301.1556539916455;
        Mon, 29 Apr 2019 05:11:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556539916; cv=none;
        d=google.com; s=arc-20160816;
        b=ESc4xANenvoDno7zRn2+jbExWaD0rNnjrqqWNBKPcKAla1uTKjrgp4Kf6NheLISjKr
         C504o53P+oAk/0izPoE4XDE9H0p0mMuK+FcacCwMFQDqKrtqjb2kqb6m3LFv8CWSwrIj
         z7/kOpnAanQ9rULlMTtoew29tmBArHU1rb9gRfnS9mgphefN4ZhZvOXTo/q+S3bhzIRl
         N9DCVb/1NWuRiS88v1wAWKiNkDNemOkZlp1qd57xqHYMUUkHD8x/xT/5Nyj95FuG4PlJ
         oElGzksax/nVPDK86yxf6qx6gRxrF8NZcqTDhhW29njIJ3E46msNlb4E4j0afTyvMqao
         QA4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:references:cc:to:from
         :subject;
        bh=fNgtKi8T64RHceHJupE8PdZ7i8PveePQCjbL80UGZm0=;
        b=fygRvC7M/+MnRzAqEQ7DqpxAKEaWqH7fgIohqEouZrHnKbWWAyuzjM+Nfqwucra5UD
         +Rdm0p5f9qmQpsjxdIWo8BuTjJymJNg6DVxsVg63dVDgHXBkDZDXQj42HMS4ETfmu/kU
         fpRnitPVRsycmtBfNLHCkPAeBfUNctBEOgyrXfxPiHsw7jgICy1x0hK2B49MQNg6EIKT
         hZA4STIfKm7NMtBfV92PqqDHEXaB/4Ut8rnHnKGmqBaQ/O6azLh3714lqJyiyj9vpHp3
         u3nb79iZhqHP+X/yDZCRtm5QNkuEg1n0p1S0eh4kCCykhJ5tpGYwlkLM5bL3RwBKLmCw
         tG4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e7sor6607601wrj.45.2019.04.29.05.11.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Apr 2019 05:11:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
X-Google-Smtp-Source: APXvYqyMBKeaNsl8I4efNful1pC1ysaJWAkdI4FpZQPvjV0aCc00T4NLLoS4haCUfXWBcxnZ7cXMUw==
X-Received: by 2002:a5d:674f:: with SMTP id l15mr16726370wrw.41.1556539914740;
        Mon, 29 Apr 2019 05:11:54 -0700 (PDT)
Received: from [192.168.1.49] (185-219-167-24-static.vivo.cz. [185.219.167.24])
        by smtp.gmail.com with ESMTPSA id z13sm26944816wrh.41.2019.04.29.05.11.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 05:11:53 -0700 (PDT)
Subject: Re: [PATCH] memcg: make it work on sparse non-0-node systems
From: Jiri Slaby <jslaby@suse.cz>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Johannes Weiner <hannes@cmpxchg.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
 Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
References: <359d98e6-044a-7686-8522-bdd2489e9456@suse.cz>
 <20190429105939.11962-1-jslaby@suse.cz>
 <20190429112916.GI21837@dhcp22.suse.cz>
 <465a4b50-490c-7978-ecb8-d122b655f868@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=jslaby@suse.cz; prefer-encrypt=mutual; keydata=
 mQINBE6S54YBEACzzjLwDUbU5elY4GTg/NdotjA0jyyJtYI86wdKraekbNE0bC4zV+ryvH4j
 rrcDwGs6tFVrAHvdHeIdI07s1iIx5R/ndcHwt4fvI8CL5PzPmn5J+h0WERR5rFprRh6axhOk
 rSD5CwQl19fm4AJCS6A9GJtOoiLpWn2/IbogPc71jQVrupZYYx51rAaHZ0D2KYK/uhfc6neJ
 i0WqPlbtIlIrpvWxckucNu6ZwXjFY0f3qIRg3Vqh5QxPkojGsq9tXVFVLEkSVz6FoqCHrUTx
 wr+aw6qqQVgvT/McQtsI0S66uIkQjzPUrgAEtWUv76rM4ekqL9stHyvTGw0Fjsualwb0Gwdx
 ReTZzMgheAyoy/umIOKrSEpWouVoBt5FFSZUyjuDdlPPYyPav+hpI6ggmCTld3u2hyiHji2H
 cDpcLM2LMhlHBipu80s9anNeZhCANDhbC5E+NZmuwgzHBcan8WC7xsPXPaiZSIm7TKaVoOcL
 9tE5aN3jQmIlrT7ZUX52Ff/hSdx/JKDP3YMNtt4B0cH6ejIjtqTd+Ge8sSttsnNM0CQUkXps
 w98jwz+Lxw/bKMr3NSnnFpUZaxwji3BC9vYyxKMAwNelBCHEgS/OAa3EJoTfuYOK6wT6nadm
 YqYjwYbZE5V/SwzMbpWu7Jwlvuwyfo5mh7w5iMfnZE+vHFwp/wARAQABtBtKaXJpIFNsYWJ5
 IDxqc2xhYnlAc3VzZS5jej6JAjgEEwECACIFAk6S6NgCGwMGCwkIBwMCBhUIAgkKCwQWAgMB
 Ah4BAheAAAoJEL0lsQQGtHBJgDsP/j9wh0vzWXsOPO3rDpHjeC3BT5DKwjVN/KtP7uZttlkB
 duReCYMTZGzSrmK27QhCflZ7Tw0Naq4FtmQSH8dkqVFugirhlCOGSnDYiZAAubjTrNLTqf7e
 5poQxE8mmniH/Asg4KufD9bpxSIi7gYIzaY3hqvYbVF1vYwaMTujojlixvesf0AFlE4x8WKs
 wpk43fmo0ZLcwObTnC3Hl1JBsPujCVY8t4E7zmLm7kOB+8EHaHiRZ4fFDWweuTzRDIJtVmrH
 LWvRDAYg+IH3SoxtdJe28xD9KoJw4jOX1URuzIU6dklQAnsKVqxz/rpp1+UVV6Ky6OBEFuoR
 613qxHCFuPbkRdpKmHyE0UzmniJgMif3v0zm/+1A/VIxpyN74cgwxjhxhj/XZWN/LnFuER1W
 zTHcwaQNjq/I62AiPec5KgxtDeV+VllpKmFOtJ194nm9QM9oDSRBMzrG/2AY/6GgOdZ0+qe+
 4BpXyt8TmqkWHIsVpE7I5zVDgKE/YTyhDuqYUaWMoI19bUlBBUQfdgdgSKRMJX4vE72dl8BZ
 +/ONKWECTQ0hYntShkmdczcUEsWjtIwZvFOqgGDbev46skyakWyod6vSbOJtEHmEq04NegUD
 al3W7Y/FKSO8NqcfrsRNFWHZ3bZ2Q5X0tR6fc6gnZkNEtOm5fcWLY+NVz4HLaKrJuQINBE6S
 54YBEADPnA1iy/lr3PXC4QNjl2f4DJruzW2Co37YdVMjrgXeXpiDvneEXxTNNlxUyLeDMcIQ
 K8obCkEHAOIkDZXZG8nr4mKzyloy040V0+XA9paVs6/ice5l+yJ1eSTs9UKvj/pyVmCAY1Co
 SNN7sfPaefAmIpduGacp9heXF+1Pop2PJSSAcCzwZ3PWdAJ/w1Z1Dg/tMCHGFZ2QCg4iFzg5
 Bqk4N34WcG24vigIbRzxTNnxsNlU1H+tiB81fngUp2pszzgXNV7CWCkaNxRzXi7kvH+MFHu2
 1m/TuujzxSv0ZHqjV+mpJBQX/VX62da0xCgMidrqn9RCNaJWJxDZOPtNCAWvgWrxkPFFvXRl
 t52z637jleVFL257EkMI+u6UnawUKopa+Tf+R/c+1Qg0NHYbiTbbw0pU39olBQaoJN7JpZ99
 T1GIlT6zD9FeI2tIvarTv0wdNa0308l00bas+d6juXRrGIpYiTuWlJofLMFaaLYCuP+e4d8x
 rGlzvTxoJ5wHanilSE2hUy2NSEoPj7W+CqJYojo6wTJkFEiVbZFFzKwjAnrjwxh6O9/V3O+Z
 XB5RrjN8hAf/4bSo8qa2y3i39cuMT8k3nhec4P9M7UWTSmYnIBJsclDQRx5wSh0Mc9Y/psx9
 B42WbV4xrtiiydfBtO6tH6c9mT5Ng+d1sN/VTSPyfQARAQABiQIfBBgBAgAJBQJOkueGAhsM
 AAoJEL0lsQQGtHBJN7UQAIDvgxaW8iGuEZZ36XFtewH56WYvVUefs6+Pep9ox/9ZXcETv0vk
 DUgPKnQAajG/ViOATWqADYHINAEuNvTKtLWmlipAI5JBgE+5g9UOT4i69OmP/is3a/dHlFZ3
 qjNk1EEGyvioeycJhla0RjakKw5PoETbypxsBTXk5EyrSdD/I2Hez9YGW/RcI/WC8Y4Z/7FS
 ITZhASwaCOzy/vX2yC6iTx4AMFt+a6Z6uH/xGE8pG5NbGtd02r+m7SfuEDoG3Hs1iMGecPyV
 XxCVvSV6dwRQFc0UOZ1a6ywwCWfGOYqFnJvfSbUiCMV8bfRSWhnNQYLIuSv/nckyi8CzCYIg
 c21cfBvnwiSfWLZTTj1oWyj5a0PPgGOdgGoIvVjYXul3yXYeYOqbYjiC5t99JpEeIFupxIGV
 ciMk6t3pDrq7n7Vi/faqT+c4vnjazJi0UMfYnnAzYBa9+NkfW0w5W9Uy7kW/v7SffH/2yFiK
 9HKkJqkN9xYEYaxtfl5pelF8idoxMZpTvCZY7jhnl2IemZCBMs6s338wS12Qro5WEAxV6cjD
 VSdmcD5l9plhKGLmgVNCTe8DPv81oDn9s0cIRLg9wNnDtj8aIiH8lBHwfUkpn32iv0uMV6Ae
 sLxhDWfOR4N+wu1gzXWgLel4drkCJcuYK5IL1qaZDcuGR8RPo3jbFO7Y
Message-ID: <a8c032b3-a0be-1710-3ec3-cc3b0b1aaa67@suse.cz>
Date: Mon, 29 Apr 2019 14:11:51 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <465a4b50-490c-7978-ecb8-d122b655f868@suse.cz>
Content-Type: text/plain; charset=iso-8859-2
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29. 04. 19, 13:55, Jiri Slaby wrote:
> Well, I could have used first_node. But I am not sure, if the first
> POSSIBLE node is also ONLINE during boot?

Thinking about it, it does not matter, actually. Both first_node and
first_online are allocated and set up, no matter which one is ONLINE
node. So first_node should work as good as first_online_node.

thanks,
-- 
js
suse labs

