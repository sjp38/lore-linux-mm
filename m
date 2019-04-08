Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0147EC10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 20:51:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A376D20857
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 20:51:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A376D20857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F7166B000A; Mon,  8 Apr 2019 16:51:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37C6F6B000C; Mon,  8 Apr 2019 16:51:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F7416B000E; Mon,  8 Apr 2019 16:51:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id EAC346B000A
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 16:51:22 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id a15so12664867qkl.23
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 13:51:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=qWgoqLrehLWrlYPdO3DLSlxzqJjTk6sf/El8Ywa/2fU=;
        b=L9bTSvnweWyjoovmXdzIc3vSBSnVY6ez8CMCJENnonDNnlUbvsy1Qtw1UhXGrf56R9
         +/dpzLetquO5jyOvAy/BLoAdOecMXvJP550oXAlkbALcSfNc8CZXiZ9Z8Rcwy6JVTObj
         wfm60tMJAYsZFY9ONHt8mLaRQS3Ygmsq4+0FliKQb2b8cWDXRBKRsXninbGk3ulesmWm
         Vq7j4C+fNt91AlNG6o237723AddH4/0AvPCVAxtVpp1tBasWB4KH3Os4Tlh9FgaulToe
         KuNw6w67IhC4GG9jzkqU5qEJ8WIenIYGt005lrb4p/+hcRsg2fZknhEBYclY4BLdefjP
         R8TQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVWXGA/47fvEPGmdGKGwGcc9R0mCxjrl7A4Fs278+RNBTvVkvco
	EwlAm5f3WGX3ogUH3UHdzW6zacBo2MKC2aaof4cKmpvkVtUxNg5wS1Qzd/VIkIaP+M6fV9jrQ8t
	xeJs6qlEvlfMEQoOS6ici4QZkWHKz+K4QnWFomV1/bVmIU/VTMUjmpVq9ug/c2VB8XQ==
X-Received: by 2002:a37:638c:: with SMTP id x134mr23942593qkb.107.1554756682647;
        Mon, 08 Apr 2019 13:51:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPc3FjawPIFKus+RkLr/z7cHTTK+mm/ehMwTOpEkCTsdlnJUxDlfvQdlrailFuyCYc/UNK
X-Received: by 2002:a37:638c:: with SMTP id x134mr23942543qkb.107.1554756681892;
        Mon, 08 Apr 2019 13:51:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554756681; cv=none;
        d=google.com; s=arc-20160816;
        b=pftQrqoP2/UkBlS/vTdiGIou4GQ4KaQkNekRJJY81sYet/5uslZdN0jAWg9DeI1bZx
         iszbGYPjpP4POb2a9SDuwOvB74+CiilaHwG+NeVY22QnVg2ptjfAv0eGUz2sgC0sffE4
         cgjsWNGNVJQFotRu5kHydT6T+vqYhISJri7VIaPZfrNLmZ1cfiotdGZNgWIspiXpc9LA
         yfk6NwCCells4Nyp7M5xLKbP/P+XD4Odh1jlrv0bmud945HnVEScQpvIA/CtYRAwIQYz
         S+IG+yX9+8YphR1F5zw32qqQrQhBDwd/nO7aQ72V5mDIgbJ89IqD0uatg4gQqButys93
         VnjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=qWgoqLrehLWrlYPdO3DLSlxzqJjTk6sf/El8Ywa/2fU=;
        b=a6vGj2VU/lu7auyM/qNpSlmkJV6R47+siYMjs9J9rCUOtPN41Q8g4ZWQ0Gm18IdjAd
         8+hZ1SDvO/Lds5XlY2utnZ9lDY23OPmLDziu5DPpU/HRHv2UDugQuUWj+uHirRBhSA6J
         L9A2W8VZ6L66TXFa56C6iBAKG0WqRmWWsmBDTYRuQ+Im9KTBkUc0Jd7wEzLgWEJkD267
         LhfuzYWINl9HWqvVDnFrJ/qCSCs8w0fjMOo+y6InTYb8czxREXnwmof7MeDaahR4eeKh
         xrVFApsdma25sGzptGnCO+281Yrm3zLiUs9jAPw43NKvg+rf9X+wXzD7lNPCp6S2LZZe
         /7jA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r15si8787913qkm.252.2019.04.08.13.51.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 13:51:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E89A73092645;
	Mon,  8 Apr 2019 20:51:20 +0000 (UTC)
Received: from [10.36.116.113] (ovpn-116-113.ams2.redhat.com [10.36.116.113])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7E7C260472;
	Mon,  8 Apr 2019 20:51:11 +0000 (UTC)
Subject: Re: Thoughts on simple scanner approach for free page hinting
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
 Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
 <01d5f4e8-742b-33f5-6d91-0c7c396d1cfc@redhat.com>
 <CAKgT0UfbVS2iupbf4Dfp91PAdgHNHwZ-RNyL=mcPsS_68Ly_9Q@mail.gmail.com>
 <ef4c219f-6686-f5f6-fd22-d1da0b1720f3@redhat.com>
 <CAKgT0Ucp1nt4roC1xdZEMcD17TvJovsDKBdkRK6vA_4bUM8bdw@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <efe01b95-33d4-71ce-2a48-ec43f0846d68@redhat.com>
Date: Mon, 8 Apr 2019 22:51:10 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0Ucp1nt4roC1xdZEMcD17TvJovsDKBdkRK6vA_4bUM8bdw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Mon, 08 Apr 2019 20:51:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08.04.19 22:10, Alexander Duyck wrote:
> On Mon, Apr 8, 2019 at 11:40 AM David Hildenbrand <david@redhat.com> wrote:
>>
>>>>>
>>>>> In addition we will need some way to identify which pages have been
>>>>> hinted on and which have not. The way I believe easiest to do this
>>>>> would be to overload the PageType value so that we could essentially
>>>>> have two values for "Buddy" pages. We would have our standard "Buddy"
>>>>> pages, and "Buddy" pages that also have the "Offline" value set in the
>>>>> PageType field. Tracking the Online vs Offline pages this way would
>>>>> actually allow us to do this with almost no overhead as the mapcount
>>>>> value is already being reset to clear the "Buddy" flag so adding a
>>>>> "Offline" flag to this clearing should come at no additional cost.
>>>>
>>>> Just nothing here that this will require modifications to kdump
>>>> (makedumpfile to be precise and the vmcore information exposed from the
>>>> kernel), as kdump only checks for the the actual mapcount value to
>>>> detect buddy and offline pages (to exclude them from dumps), they are
>>>> not treated as flags.
>>>>
>>>> For now, any mapcount values are really only separate values, meaning
>>>> not the separate bits are of interest, like flags would be. Reusing
>>>> other flags would make our life a lot easier. E.g. PG_young or so. But
>>>> clearing of these is then the problematic part.
>>>>
>>>> Of course we could use in the kernel two values, Buddy and BuddyOffline.
>>>> But then we have to check for two different values whenever we want to
>>>> identify a buddy page in the kernel.
>>>
>>> Actually this may not be working the way you think it is working.
>>
>> Trust me, I know how it works. That's why I was giving you the notice.
>>
>> Read the first paragraph again and ignore the others. I am only
>> concerned about makedumpfile that has to be changed.
>>
>> PAGE_OFFLINE_MAPCOUNT_VALUE
>> PAGE_BUDDY_MAPCOUNT_VALUE
>>
>> Once you find out how these values are used, you should understand what
>> has to be changed and where.
> 
> Ugh. Is there an official repo I am supposed to refer to for makedumpfile?
> 
> As far as the changes needed I don't think this would necessitate
> additional exports. We could probably just get away with having
> makedumpfile generate a new value by simply doing an "&" of the two
> values to determine what an offline buddy would be. If need be I can
> submit a patch for that. I find it kind of annoying that the kernel is
> handling identifying these bits one way, and makedumpfile is doing it
> another way. It should have been setup to handle this all the same
> way.
> 
>>
>>>>>
>>>>> Lastly we would need to create a specialized function for allocating
>>>>> the non-"Offline" pages, and to tweak __free_one_page to tail enqueue
>>>>> "Offline" pages. I'm thinking the alloc function it would look
>>>>> something like __rmqueue_smallest but without the "expand" and needing
>>>>> to modify the !page check to also include a check to verify the page
>>>>> is not "Offline". As far as the changes to __free_one_page it would be
>>>>> a 2 line change to test for the PageType being offline, and if it is
>>>>> to call add_to_free_area_tail instead of add_to_free_area.
>>>>
>>>> As already mentioned, there might be scenarios where the additional
>>>> hinting thread might consume too much CPU cycles, especially if there is
>>>> little guest activity any you mostly spend time scanning a handful of
>>>> free pages and reporting them. I wonder if we can somehow limit the
>>>> amount of wakeups/scans for a given period to mitigate this issue.
>>>
>>> That is why I was talking about breaking nr_free into nr_freed and
>>> nr_bound. By doing that I can record the nr_free value to a
>>> virtio-balloon specific location at the start of any walk and should
>>> know exactly now many pages were freed between that call and the next
>>> one. By ordering things such that we place the "Offline" pages on the
>>> tail of the list it should make the search quite fast since we would
>>> just be always allocating off of the head of the queue until we have
>>> hinted everything int he queue. So when we hit the last call to alloc
>>> the non-"Offline" pages and shut down our thread we can use the
>>> nr_freed value that we recorded to know exactly how many pages have
>>> been added that haven't been hinted.
>>>
>>>> One main issue I see with your approach is that we need quite a lot of
>>>> core memory management changes. This is a problem. I wonder if we can
>>>> factor out most parts into callbacks.
>>>
>>> I think that is something we can't get away from. However if we make
>>> this generic enough there would likely be others beyond just the
>>> virtualization drivers that could make use of the infrastructure. For
>>> example being able to track the rate at which the free areas are
>>> cycling in and out pages seems like something that would be useful
>>> outside of just the virtualization areas.
>>
>> Might be, but might be the other extreme, people not wanting such
>> special cases in core mm. I assume the latter until I see a very clear
>> design where such stuff has been properly factored out.
> 
> The only real pain point I am seeing right now is the assumptions
> makedumpfile is currently making about how mapcount is being used to
> indicate pagetype. If we patch it to fix it most of the other bits are
> minor.

I'll be curious how splitting etc. will be handled. Especially if you
want to set Offline for all affected sub pages.

-- 

Thanks,

David / dhildenb

