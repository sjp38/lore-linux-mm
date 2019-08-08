Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA2F5C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 17:57:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78B75214C6
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 17:57:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78B75214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=redhazel.co.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18BFE6B0003; Thu,  8 Aug 2019 13:57:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13D356B0006; Thu,  8 Aug 2019 13:57:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 054AF6B0007; Thu,  8 Aug 2019 13:57:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AB6F36B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 13:57:05 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l14so58734246edw.20
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 10:57:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :user-agent:in-reply-to:references:mime-version
         :content-transfer-encoding:subject:to:cc:from:message-id;
        bh=vxS5l7XgveVxRTCzuXtaYIMt0isboBr9yfr3gZBBar0=;
        b=fWeLx8Coo3Z7fzXICeQj+4VxtUK045J/bOB+zqvRxA7nf+9djhQ935Ub9jRSVexRvy
         aZeVf44CzDTEJhCbGNlUgwmQGd5LeM/4Xzwc8TFwp2aAhecz3IGyMMy5adyDxR++Uv+Z
         HklQuORNM/LMn5w/FMdYOR3VA+obe+YmqPsdLg3HSHbmXzRbfvsFLmiQQMRCt7DurZcO
         CWvOoJfIt0SI0EDmYW1BhlcBAzoHqYWHNqio1rRAHLGXGir2HdO6wUnZO6KQKDLDLSr7
         czXiOHNY9x/Gf27GB/qXfbhreuvz1o57PnN4w9I/37qdcBXIcb+deeJHnNHf6RM3jDg3
         ELIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) smtp.mailfrom=ndrw.xf@redhazel.co.uk
X-Gm-Message-State: APjAAAX0Tfr8szilUpOZ9lXO4uzVhD1dbbmbgIJgvEpS3N6gKfOqcHvQ
	GfsYWqsSp5ToNhlkdPckTKARQmE5+vTeLJ/tujX+MBhc3XanZyH8TqJLQpjzVIzd58S7Mmq6vzj
	uAXjggj7Isw4g4VUqjjz61/eYizIfwS50erxhV3r8y/OlM5TXSavMGr8+heJ220JdRg==
X-Received: by 2002:a17:906:9453:: with SMTP id z19mr14762680ejx.287.1565287025238;
        Thu, 08 Aug 2019 10:57:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7KG1elAjotg5EEG4cU4/s9uW6ksaEuicBt3VtGqg0Joqq2XlomBTDf31Z5u6mIwyocsfw
X-Received: by 2002:a17:906:9453:: with SMTP id z19mr14762612ejx.287.1565287024298;
        Thu, 08 Aug 2019 10:57:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565287024; cv=none;
        d=google.com; s=arc-20160816;
        b=gMDurTavFJTU2fntotlVRRBb/iteEU0azJyfM+Zs4Z/iLdO3B8H+g18vEDkq5x2Aip
         QVUosdGknD3J6yixN2f/YsT37jsO+KLgpkTmUSPlA9uXEV5EPPx3Kkm09WIZdB8/YDjR
         j70C38XZM61xEfi74gntp2IXDIMEQEPyiF+hJz9w4fwyBnUV7uwWmBaJohFhK2FQuAc1
         9Hfh4FpZqRGH+Z6zrk6+WaBQ2YohxYbOi85Pi9uci2I3QAlLxSXo9gTMfY5UHhBGwh7d
         kzGSJmMXd1YcM17HmKEC2eDHkuJhw7e3S0lGQnto9toqEGyr/rm9pIjw7errEaggQ8tQ
         38pA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:from:cc:to:subject:content-transfer-encoding
         :mime-version:references:in-reply-to:user-agent:date;
        bh=vxS5l7XgveVxRTCzuXtaYIMt0isboBr9yfr3gZBBar0=;
        b=cO5uH9orGoFoaHGpJAz4lYR3H//WHLl5sVHL8Avl3p6fLepd5/BLDJstIk3RvGqjHo
         Qn6h7GVyZa1lRsWhYefScVbQiyWpya87T0SLSd74jxyIbnCJ3xbL3Xs5+GA+Er5ZcYdT
         W7wGBP+Gaw0N9plSydv+1qYfqXWZ6PdCQ7oC5xfQBVTUg+zU5as06Y2hQnpqlaRQHK71
         W1/lB3/jLShi2XEtYyzMYZrczdlMgMywVk2wUcojKWoh1gVAGQO1TmHLTvycMogtXgWd
         EJ11WjDPjeF7gbV+8su2v9E7HBC53hTcxTNmfZdSkBFFCdExeA7MAWxaMzB5I2CBxd36
         uxyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) smtp.mailfrom=ndrw.xf@redhazel.co.uk
Received: from vps.redhazel.co.uk ([68.66.241.172])
        by mx.google.com with ESMTPS id 57si33226246eds.450.2019.08.08.10.57.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 10:57:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) client-ip=68.66.241.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) smtp.mailfrom=ndrw.xf@redhazel.co.uk
Received: from [100.121.56.177] (unknown [213.205.240.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by vps.redhazel.co.uk (Postfix) with ESMTPSA id AEFC31C02182;
	Thu,  8 Aug 2019 18:57:03 +0100 (BST)
Date: Thu, 08 Aug 2019 18:57:02 +0100
User-Agent: K-9 Mail for Android
In-Reply-To: <20190808163228.GE18351@dhcp22.suse.cz>
References: <CAJuCfpHhR+9ybt9ENzxMbdVUd_8rJN+zFbDm+5CeE2Desu82Gg@mail.gmail.com> <398f31f3-0353-da0c-fc54-643687bb4774@suse.cz> <20190806142728.GA12107@cmpxchg.org> <20190806143608.GE11812@dhcp22.suse.cz> <CAJuCfpFmOzj-gU1NwoQFmS_pbDKKd2XN=CS1vUV4gKhYCJOUtw@mail.gmail.com> <20190806220150.GA22516@cmpxchg.org> <20190807075927.GO11812@dhcp22.suse.cz> <20190807205138.GA24222@cmpxchg.org> <20190808114826.GC18351@dhcp22.suse.cz> <806F5696-A8D6-481D-A82F-49DEC1F2B035@redhazel.co.uk> <20190808163228.GE18351@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's inability to gracefully handle low memory pressure
To: Michal Hocko <mhocko@kernel.org>
CC: Johannes Weiner <hannes@cmpxchg.org>,Suren Baghdasaryan <surenb@google.com>,Vlastimil Babka <vbabka@suse.cz>,"Artem S. Tashkinov" <aros@gmx.com>,Andrew Morton <akpm@linux-foundation.org>,LKML <linux-kernel@vger.kernel.org>,linux-mm <linux-mm@kvack.org>
From: ndrw.xf@redhazel.co.uk
Message-ID: <5FBB0A26-0CFE-4B88-A4F2-6A42E3377EDB@redhazel.co.uk>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 8 August 2019 17:32:28 BST, Michal Hocko <mhocko@kernel=2Eorg> wrote:
>
>> Would it be possible to reserve a fixed (configurable) amount of RAM
>for caches,
>
>I am afraid there is nothing like that available and I would even argue
>it doesn't make much sense either=2E What would you consider to be a
>cache? A kernel/userspace reclaimable memory? What about any other in
>kernel memory users? How would you setup such a limit and make it
>reasonably maintainable over different kernel releases when the memory
>footprint changes over time?

Frankly, I don't know=2E The earlyoom userspace tool works well enough for=
 me so I assumed this functionality could be implemented in kernel=2E Defau=
lt thresholds would have to be tested but it is unlikely zero is the optimu=
m value=2E=20

>Besides that how does that differ from the existing reclaim mechanism?
>Once your cache hits the limit, there would have to be some sort of the
>reclaim to happen and then we are back to square one when the reclaim
>is
>making progress but you are effectively treshing over the hot working
>set (e=2Eg=2E code pages)

By forcing OOM killer=2E Reclaiming memory when system becomes unresponsiv=
e is precisely what I want to avoid=2E

>> and trigger OOM killer earlier, before most UI code is evicted from
>memory?
>
>How does the kernel knows that important memory is evicted?

I assume current memory management policy (LRU?) is sufficient to keep mos=
t frequently used pages in memory=2E

>If you know which task is that then you can put it into a memory cgroup
>with a stricter memory limit and have it killed before the overal
>system
>starts suffering=2E

This is what I intended to use=2E But I don't know how to bypass SystemD o=
r configure such policies via SystemD=2E=20

>PSI is giving you a matric that tells you how much time you
>spend on the memory reclaim=2E So you can start watching the system from
>lower utilization already=2E

This is a fantastic news=2E Really=2E I didn't know this is how it works=
=2E Two potential issues, though:
1=2E PSI (if possible) should be normalised wrt the memory reclaiming cost=
 (SSDs have lower cost than HDDs)=2E If not automatically then perhaps via =
a user configurable option=2E That's somewhat similar to having configurabl=
e PSI thresholds=2E=20
2=2E It seems PSI measures the _rate_ pages are evicted from memory=2E Whi=
le this may correlate with the _absolute_ amount of of memory left, it is n=
ot the same=2E Perhaps weighting PSI with absolute amount of memory used fo=
r caches would improve this metric=2E

Best regards,
ndrw

