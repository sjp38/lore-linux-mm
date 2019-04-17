Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0905C282DD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:48:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B1192177B
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:48:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B1192177B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02DBB6B0005; Wed, 17 Apr 2019 09:48:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1F736B0006; Wed, 17 Apr 2019 09:48:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE73A6B0007; Wed, 17 Apr 2019 09:48:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id BDCA96B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 09:48:22 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id n13so22562163qtn.6
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 06:48:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=m6+zh/PAiUA0dxVD6ebVjItDP+9QsOkQhdnRWPD8Qhw=;
        b=T9JEeWKXIasPeDtYaAKgnN0pPOTXSYivQ8mu323QGw7dfgVi+1CqJycixHljgM//hj
         B4H3JCXfVzcwMMd4RxDZ1VTTi6reSOlex9lvfSKYpd8Q/wieiQ3uGsZoVtxh79LZZkmT
         dzTGlhBzZGMfUNa2hmFta51JWDLptXx5S9YO666zXPBJGLh6EQjLWBP2Mwn3Owg9P/xJ
         aeCeky/WjJ66U0wLt4++00YFX3+lULgPqMd/7svIjkYeomNCLI9SL7jFFyT3Z8CNs1wd
         EBvOgHUm9aoTdI37f9lmDAVqNCRZvkSQebEArMx8d+fFVhCbfQ06coo0bE8od7BYerUB
         9Wsg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVB4zK3bsVsYFQtzTRpcAYqQepQJWqO+dSbxLksQNALgzZGC3qk
	vVgswSYSRKNW4aXvmvykux2RHndMnGAhbxtbLWZCgTdNklROAxo7ptAACw5vTiZJvB7hf6z3ioi
	a2+iEaqpc2SXQijOd662Ipn+p09GBARlhS2aP4/fufUwMCxF68dcuYQQQ/eZrNGUqNQ==
X-Received: by 2002:ac8:1631:: with SMTP id p46mr67682123qtj.285.1555508902481;
        Wed, 17 Apr 2019 06:48:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymjkanYxEEUEKm/u/tU/w0kqD0szVyIXe2KsiwbFCivr+zudfNmWRaRHY/It+FXQaXO9C2
X-Received: by 2002:ac8:1631:: with SMTP id p46mr67682074qtj.285.1555508901776;
        Wed, 17 Apr 2019 06:48:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555508901; cv=none;
        d=google.com; s=arc-20160816;
        b=HTmiaqHrbJZOmUlCMxyRzry/nNaxux7WBYzLJWY53qVaeVJlhmPS/ECzPHQe6uIms2
         Xm5pWnxXSeXdDFovtDuRw0BvQn2JHdYZIydtrKOJoZEvmLswfZsSdJx2uDg1ZpA04nhT
         31ouwYS3MDYTBUG9ciM3bC49dlQLxHuDgKs7kJEOLlcbyCS1WBVwES34XAVt4tlOBAPJ
         7V1kP6ia8CECmwLHUm5bgTzCiqE5EQ/N//ZcMCyFVU8kwqvmdCOugLAA/vNNa9DuZGfF
         UzW/HzMPkFn9eLPVs8ofidh14HqGj5ztTQwJ0WHl2VqN8EPTpyLwhKI3stWD+FSNuM9O
         f3kQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=m6+zh/PAiUA0dxVD6ebVjItDP+9QsOkQhdnRWPD8Qhw=;
        b=xmmNjOUQdjGJd4q/6lyeZUTqtCldWami+GDOA9icNrYjvWERjCUPpWvarav3fcjF5H
         1Hx2X/0/5FA/oGNrDkft6DZAbFvjtl4tYB0fBUMdspA8Vz5Hca1IyAQAO0L7SCCY32AV
         V7hlnVGTBjk0qK8AgT4t1kuz2dTJWXXMAsS6+0P12bcnEtscFacr1PkugrxP8TJ4nhc4
         zbb1AbtPw216iw1OefWUfW+hdlOVfeqAk2ykOEXNLWvSGkX3wLQ5wX21+UQ3SeHdjGRF
         jUkx18SDXAWOK27B+td7OscDJeHNeexhPp5ol9m5L1v2D9FKIymS9iuzC5sJ+NBbrvkO
         KLVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i53si278759qvi.108.2019.04.17.06.48.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 06:48:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 06C95308404C;
	Wed, 17 Apr 2019 13:48:20 +0000 (UTC)
Received: from [10.36.116.187] (ovpn-116-187.ams2.redhat.com [10.36.116.187])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 034DD5D6A6;
	Wed, 17 Apr 2019 13:48:17 +0000 (UTC)
Subject: Re: [PATCH v1 1/4] mm/memory_hotplug: Release memory resource after
 arch_remove_memory()
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador
 <osalvador@suse.de>, Pavel Tatashin <pasha.tatashin@soleen.com>,
 Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
 Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>
References: <20190409100148.24703-1-david@redhat.com>
 <20190409100148.24703-2-david@redhat.com>
 <20190417131258.GI5878@dhcp22.suse.cz>
 <ae4cc790-8d9b-39ad-d29c-d8bd290da165@redhat.com>
 <20190417133131.GK5878@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <b5a76b2c-923c-e5a4-0f3a-b78a78b7b1de@redhat.com>
Date: Wed, 17 Apr 2019 15:48:17 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190417133131.GK5878@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Wed, 17 Apr 2019 13:48:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 17.04.19 15:31, Michal Hocko wrote:
> On Wed 17-04-19 15:24:47, David Hildenbrand wrote:
>> On 17.04.19 15:12, Michal Hocko wrote:
>>> On Tue 09-04-19 12:01:45, David Hildenbrand wrote:
>>>> __add_pages() doesn't add the memory resource, so __remove_pages()
>>>> shouldn't remove it. Let's factor it out. Especially as it is a special
>>>> case for memory used as system memory, added via add_memory() and
>>>> friends.
>>>>
>>>> We now remove the resource after removing the sections instead of doing
>>>> it the other way around. I don't think this change is problematic.
>>>>
>>>> add_memory()
>>>> 	register memory resource
>>>> 	arch_add_memory()
>>>>
>>>> remove_memory
>>>> 	arch_remove_memory()
>>>> 	release memory resource
>>>>
>>>> While at it, explain why we ignore errors and that it only happeny if
>>>> we remove memory in a different granularity as we added it.
>>>
>>> OK, I agree that the symmetry is good in general and it certainly makes
>>> sense here as well. But does it make sense to pick up this particular
>>> part without larger considerations of add vs. remove apis? I have a
>>> strong feeling this wouldn't be the only thing to care about. In other
>>> words does this help future changes or it is more likely to cause more
>>> code conflicts with other features being developed right now?
>>
>> I am planning to
>>
>> 1. factor out memory block device handling, so features like sub-section
>> add/remove are easier to add internally. Move it to the user that wants
>> it. Clean up all the mess we have right now due to supporting memory
>> block devices that span several sections.
>>
>> 2. Make sure that any arch_add_pages() and friends clean up properly if
>> they fail instead of indicating failure but leaving some partially added
>> memory lying around.
>>
>> 3. Clean up node handling regarding to memory hotplug/unplug. Especially
>> don't allow to offline/remove memory spanning several nodes etc.
> 
> Yes, this all sounds sane to me.
> 
>> IOW, in order to properly clean up memory block device handling and
>> prepare for more changes people are interested in (e.g. sub-section add
>> of device memory), this is the right thing to do. The other parts are
>> bigger changes.
> 
> This would be really valuable to have in the cover. Beause there is so
> much to clean up in this mess but making random small cleanups without a
> larger plan tends to step on others toes more than being useful.

I agree, let's discuss the bigger plan I have in mind

1. arch_add_memory()/arch_remove_memory() don't deal with memory block
devices. add_memory()/remove_memory()/online_pages()/offline_pages() do.

2. add_memory()/remove_memory()/online_pages()/offline_pages()
- Only work on memory block device alignment/granularity
- Only work on single nodes.
- Only work on single zones.

3. mem->nid correctly indicates if
- Memory block devices belongs to single node / no node / multiple nodes
- Fast and reliable way to detect
remove_memory()/online_pages()/offline_pages() being called with
multiple nodes.

4. arch_remove_memory() and friends never fail. Removing of memory
always succeeds. This allows better error handling when adding of memory
fails. We will move some parts from CONFIG_MEMORY_HOTREMOVE to
CONFIG_MEMORY_HOTPLUG, so we can use them to clean up if adding of
memory fails.

5. Remove all accesses to struct_page from memory removal path. Pages
might never have been initialized, they should not be touched.

All other features I see on the horizon (vmemmap on added memory,
sub-section hot-add) would mainly be centered around
arch_add_memory()/arch_remove_memory(), which would not have to deal
with any special cases around memory block device memory.

Do you agree, do you have any other points/things in mind you consider
important?

-- 

Thanks,

David / dhildenb

