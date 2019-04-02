Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4699C10F0B
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 17:09:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7178B20693
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 17:09:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7178B20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C8A66B000C; Tue,  2 Apr 2019 13:09:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 078426B0266; Tue,  2 Apr 2019 13:09:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E80B36B0273; Tue,  2 Apr 2019 13:09:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id C85D86B000C
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 13:09:12 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id n1so13932222qte.12
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 10:09:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=Eun0PjxoAb9OIdKwjLDDAJnH3mbE0NbBCSq/fLjtGXw=;
        b=EMWmjRl+Chx8bW9/UOQbOb+hdSY+y0uq5OdXC1fLcVciJijqbws1InDe2R/kKN4Vnk
         Oknh1ETNaCXhyhOAMa6qaIjd5O4zBvBIiZHuwecvqr06IMSCi+0Ezk07nTAASLUnj56w
         3cwc8FifAX+gT44e0t+verscN9HDUNz8zdNNNHEI7JQReMmtvcrXsGQj8eJUEohCRWRK
         6DbEqJjPRjGJ3y8Wg28RO1TMvsUmV0ThAOrIOPtL4OtDoeXfpxtrj+3l4Pjwh0KXl9WH
         iHYhE+ER0gEvKcS2fzj2CtlH51TbOaQtE9DWaDtjVe3BaW5U8jmTEgBS1Vbppvie+jeM
         KJLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWMqlXSOJV2PGaRRBatSgHrbG7pn3B1+9ti+eO93QWNgTYhw0EC
	bV6QT9XmPJWSIfQ2E2gcjmgrS5yCMe7y0/GuqJ2OkHvwkp+mP3MhrjOwN7FF8ITF3hWycMTOuf0
	w5P5i0sQavRth/sRIBpYOMAYWrckct2ELq+Lo6Pf37ePeQMCoZan734J6cx1AoFL/cQ==
X-Received: by 2002:ac8:2f6f:: with SMTP id k44mr59137342qta.230.1554224952542;
        Tue, 02 Apr 2019 10:09:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuYhcJYWexjJZKIKIDYBoiHFf8ODafKGA5jPV7GtYPbuNzpH6ygovOmW0m4qnb4I8XV1aR
X-Received: by 2002:ac8:2f6f:: with SMTP id k44mr59137263qta.230.1554224951689;
        Tue, 02 Apr 2019 10:09:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554224951; cv=none;
        d=google.com; s=arc-20160816;
        b=mvBcwBaL5cutKma6JUROgo9ItOROTVTCk+C6G2XiBcNsdUpIiHaqCzN6yLuRiaQgmW
         txqfEF72P9871kJGi1m1KNhZHJQGkR4Pe/uUaH/MRYQob3QSLhHUu6DcFp4qVtK8LmFs
         mFYNE4HafMiyE9qgmBomYho4ouoNndFq4jSEJFPsAH6nTITjidCpE6UeiILOKFB/OrFA
         22BHSlJ15GvrncfLxKEPDksuSxMQuN9NHaROStx3veSqrCgncB908ocQUJULFfi3SFAJ
         dFBreFzFBVyXRnfgvktY+LVnQzf+bN+bL8wPw0lQwSahnazmoq9AeRn6tCNcPesJZyxo
         04bQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=Eun0PjxoAb9OIdKwjLDDAJnH3mbE0NbBCSq/fLjtGXw=;
        b=PmnCT+RhPHD/5Suo+g3XJKSD/iOaZXk8u0MpRuF5OFGoBVxnxernQow/CAp5ISMkOq
         QPheh2fmrHCg0lMI74jqx/9wOMgtZeLTgJONZ7JBOy16BMT3UhFH4nc8oALIrKyLa8Fi
         mRUTFTtwuDC3kLmoWqbWqge+NvfLBLsL+dEynUmIiKYgRjW8WbNJvSe9bjLjvQvoavXh
         t+g8s1LU4AlHTBn1XeUnwnesBbPPUMsv76O3lfMCHSQGV18R1692OAEsY/IFlgUFWUX4
         C3vzKsGTBW3ftrrZbbSP0ioacBwutpMFacfs0X+HFFH0VPFk/U+RR2v2nRQllczaqtAL
         5L5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h14si1222975qvc.98.2019.04.02.10.09.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 10:09:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A818E7DCF0;
	Tue,  2 Apr 2019 17:09:10 +0000 (UTC)
Received: from [10.36.116.79] (ovpn-116-79.ams2.redhat.com [10.36.116.79])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2C17B7D14D;
	Tue,  2 Apr 2019 17:08:57 +0000 (UTC)
Subject: Re: On guest free page hinting and OOM
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
 Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <f0ee075d-3e99-efd5-8c82-98d53b9f204f@redhat.com>
 <20190329125034-mutt-send-email-mst@kernel.org>
 <fb23fd70-4f1b-26a8-5ecc-4c14014ef29d@redhat.com>
 <20190401073007-mutt-send-email-mst@kernel.org>
 <29e11829-c9ac-a21b-b2f1-ed833e4ca449@redhat.com>
 <dc14a711-a306-d00b-c4ce-c308598ee386@redhat.com>
 <20190401104608-mutt-send-email-mst@kernel.org>
 <CAKgT0UcJuD-t+MqeS9geiGE1zsUiYUgZzeRrOJOJbOzn2C-KOw@mail.gmail.com>
 <6a612adf-e9c3-6aff-3285-2e2d02c8b80d@redhat.com>
 <CAKgT0Ue_By3Z0=5ZEvscmYAF2P40Bdyo-AXhH8sZv5VxUGGLvA@mail.gmail.com>
 <20190402112115-mutt-send-email-mst@kernel.org>
 <3dd76ce6-c138-b019-3a43-0bb0b793690a@redhat.com>
 <CAKgT0Uc78NYnva4T+G5uas_iSnE_YHGz+S5rkBckCvhNPV96gw@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 xsFNBFXLn5EBEAC+zYvAFJxCBY9Tr1xZgcESmxVNI/0ffzE/ZQOiHJl6mGkmA1R7/uUpiCjJ
 dBrn+lhhOYjjNefFQou6478faXE6o2AhmebqT4KiQoUQFV4R7y1KMEKoSyy8hQaK1umALTdL
 QZLQMzNE74ap+GDK0wnacPQFpcG1AE9RMq3aeErY5tujekBS32jfC/7AnH7I0v1v1TbbK3Gp
 XNeiN4QroO+5qaSr0ID2sz5jtBLRb15RMre27E1ImpaIv2Jw8NJgW0k/D1RyKCwaTsgRdwuK
 Kx/Y91XuSBdz0uOyU/S8kM1+ag0wvsGlpBVxRR/xw/E8M7TEwuCZQArqqTCmkG6HGcXFT0V9
 PXFNNgV5jXMQRwU0O/ztJIQqsE5LsUomE//bLwzj9IVsaQpKDqW6TAPjcdBDPLHvriq7kGjt
 WhVhdl0qEYB8lkBEU7V2Yb+SYhmhpDrti9Fq1EsmhiHSkxJcGREoMK/63r9WLZYI3+4W2rAc
 UucZa4OT27U5ZISjNg3Ev0rxU5UH2/pT4wJCfxwocmqaRr6UYmrtZmND89X0KigoFD/XSeVv
 jwBRNjPAubK9/k5NoRrYqztM9W6sJqrH8+UWZ1Idd/DdmogJh0gNC0+N42Za9yBRURfIdKSb
 B3JfpUqcWwE7vUaYrHG1nw54pLUoPG6sAA7Mehl3nd4pZUALHwARAQABzSREYXZpZCBIaWxk
 ZW5icmFuZCA8ZGF2aWRAcmVkaGF0LmNvbT7CwX4EEwECACgFAljj9eoCGwMFCQlmAYAGCwkI
 BwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEE3eEPcA/4Na5IIP/3T/FIQMxIfNzZshIq687qgG
 8UbspuE/YSUDdv7r5szYTK6KPTlqN8NAcSfheywbuYD9A4ZeSBWD3/NAVUdrCaRP2IvFyELj
 xoMvfJccbq45BxzgEspg/bVahNbyuBpLBVjVWwRtFCUEXkyazksSv8pdTMAs9IucChvFmmq3
 jJ2vlaz9lYt/lxN246fIVceckPMiUveimngvXZw21VOAhfQ+/sofXF8JCFv2mFcBDoa7eYob
 s0FLpmqFaeNRHAlzMWgSsP80qx5nWWEvRLdKWi533N2vC/EyunN3HcBwVrXH4hxRBMco3jvM
 m8VKLKao9wKj82qSivUnkPIwsAGNPdFoPbgghCQiBjBe6A75Z2xHFrzo7t1jg7nQfIyNC7ez
 MZBJ59sqA9EDMEJPlLNIeJmqslXPjmMFnE7Mby/+335WJYDulsRybN+W5rLT5aMvhC6x6POK
 z55fMNKrMASCzBJum2Fwjf/VnuGRYkhKCqqZ8gJ3OvmR50tInDV2jZ1DQgc3i550T5JDpToh
 dPBxZocIhzg+MBSRDXcJmHOx/7nQm3iQ6iLuwmXsRC6f5FbFefk9EjuTKcLMvBsEx+2DEx0E
 UnmJ4hVg7u1PQ+2Oy+Lh/opK/BDiqlQ8Pz2jiXv5xkECvr/3Sv59hlOCZMOaiLTTjtOIU7Tq
 7ut6OL64oAq+zsFNBFXLn5EBEADn1959INH2cwYJv0tsxf5MUCghCj/CA/lc/LMthqQ773ga
 uB9mN+F1rE9cyyXb6jyOGn+GUjMbnq1o121Vm0+neKHUCBtHyseBfDXHA6m4B3mUTWo13nid
 0e4AM71r0DS8+KYh6zvweLX/LL5kQS9GQeT+QNroXcC1NzWbitts6TZ+IrPOwT1hfB4WNC+X
 2n4AzDqp3+ILiVST2DT4VBc11Gz6jijpC/KI5Al8ZDhRwG47LUiuQmt3yqrmN63V9wzaPhC+
 xbwIsNZlLUvuRnmBPkTJwwrFRZvwu5GPHNndBjVpAfaSTOfppyKBTccu2AXJXWAE1Xjh6GOC
 8mlFjZwLxWFqdPHR1n2aPVgoiTLk34LR/bXO+e0GpzFXT7enwyvFFFyAS0Nk1q/7EChPcbRb
 hJqEBpRNZemxmg55zC3GLvgLKd5A09MOM2BrMea+l0FUR+PuTenh2YmnmLRTro6eZ/qYwWkC
 u8FFIw4pT0OUDMyLgi+GI1aMpVogTZJ70FgV0pUAlpmrzk/bLbRkF3TwgucpyPtcpmQtTkWS
 gDS50QG9DR/1As3LLLcNkwJBZzBG6PWbvcOyrwMQUF1nl4SSPV0LLH63+BrrHasfJzxKXzqg
 rW28CTAE2x8qi7e/6M/+XXhrsMYG+uaViM7n2je3qKe7ofum3s4vq7oFCPsOgwARAQABwsFl
 BBgBAgAPBQJVy5+RAhsMBQkJZgGAAAoJEE3eEPcA/4NagOsP/jPoIBb/iXVbM+fmSHOjEshl
 KMwEl/m5iLj3iHnHPVLBUWrXPdS7iQijJA/VLxjnFknhaS60hkUNWexDMxVVP/6lbOrs4bDZ
 NEWDMktAeqJaFtxackPszlcpRVkAs6Msn9tu8hlvB517pyUgvuD7ZS9gGOMmYwFQDyytpepo
 YApVV00P0u3AaE0Cj/o71STqGJKZxcVhPaZ+LR+UCBZOyKfEyq+ZN311VpOJZ1IvTExf+S/5
 lqnciDtbO3I4Wq0ArLX1gs1q1XlXLaVaA3yVqeC8E7kOchDNinD3hJS4OX0e1gdsx/e6COvy
 qNg5aL5n0Kl4fcVqM0LdIhsubVs4eiNCa5XMSYpXmVi3HAuFyg9dN+x8thSwI836FoMASwOl
 C7tHsTjnSGufB+D7F7ZBT61BffNBBIm1KdMxcxqLUVXpBQHHlGkbwI+3Ye+nE6HmZH7IwLwV
 W+Ajl7oYF+jeKaH4DZFtgLYGLtZ1LDwKPjX7VAsa4Yx7S5+EBAaZGxK510MjIx6SGrZWBrrV
 TEvdV00F2MnQoeXKzD7O4WFbL55hhyGgfWTHwZ457iN9SgYi1JLPqWkZB0JRXIEtjd4JEQcx
 +8Umfre0Xt4713VxMygW0PnQt5aSQdMD58jHFxTk092mU+yIHj5LeYgvwSgZN4airXk5yRXl
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <6b0a3610-0e7b-08dc-8b5f-707062f87bea@redhat.com>
Date: Tue, 2 Apr 2019 19:08:57 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0Uc78NYnva4T+G5uas_iSnE_YHGz+S5rkBckCvhNPV96gw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 02 Apr 2019 17:09:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 02.04.19 18:18, Alexander Duyck wrote:
> n Tue, Apr 2, 2019 at 8:57 AM David Hildenbrand <david@redhat.com> wrote:
>>
>> On 02.04.19 17:25, Michael S. Tsirkin wrote:
>>> On Tue, Apr 02, 2019 at 08:04:00AM -0700, Alexander Duyck wrote:
>>>> Basically what we would be doing is providing a means for
>>>> incrementally transitioning the buddy memory into the idle/offline
>>>> state to reduce guest memory overhead. It would require one function
>>>> that would walk the free page lists and pluck out pages that don't
>>>> have the "Offline" page type set,
>>>
>>> I think we will need an interface that gets
>>> an offline page and returns the next online free page.
>>>
>>> If we restart the list walk each time we can't guarantee progress.
>>
>> Yes, and essentially we are scanning all the time for chunks vs. we get
>> notified which chunks are possible hinting candidates. Totally different
>> design.
> 
> The problem as I see it is that we can miss notifications if we become
> too backlogged, and that will lead to us having to fall back to
> scanning anyway. So instead of trying to implement both why don't we
> just focus on the scanning approach. Otherwise the only other option
> is to hold up the guest and make it wait until the hint processing has
> completed and at that point we are back to what is essentially just a
> synchronous solution with batching anyway.
> 

In general I am not a fan of "there might be a problem, let's try
something completely different". Expect the unexpected. At this point, I
prefer to think about easy solutions to eventual problems. not
completely new designs. As I said, we've been there already.

Related to "falling behind" with hinting. If this is indeed possible
(and I'd like to know under which conditions), I wonder at which point
we no longer care about missed hints. If our guest as a lot of MM
activity, could be that is good that we are dropping hints, because our
guest is so busy, it will reuse pages soon again.

One important point is - I think - that free page hinting does not have
to fit all possible setups. In certain environments it just makes sense
to disable it. Or live with it not giving you "all the hints". E.g.
databases that eat up all free memory either way. The other extreme
would be a simple webserver that is mostly idle.

We are losing hitning of quite free memory already due to the MAX_ORDER
- X discussion. Dropping a couple of other hints shouldn't really hurt.
The question is, are there scenarios where we can completely screw up.

-- 

Thanks,

David / dhildenb

