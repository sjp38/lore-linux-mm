Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17A73C10F00
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 20:31:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1429206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 20:31:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1429206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 414578E0003; Wed,  6 Mar 2019 15:31:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39D2A8E0002; Wed,  6 Mar 2019 15:31:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23FDA8E0003; Wed,  6 Mar 2019 15:31:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id EADEB8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 15:31:33 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id f24so12887393qte.4
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 12:31:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:organization:message-id:date:user-agent
         :mime-version:in-reply-to;
        bh=UlC7qYsBq2rAW0oNth9dOh1TqkQSBwF+kzd5m3TYBGU=;
        b=G3414E1uPyFw14XKyLqud9YsJysObIFfw8OjnWa3yKoHx/9dqRrojbjlOJa3pbFurK
         s31rTPIV501gdRim44Dp5Xeo/dSyHuelvGzVCXRgqTNbQDNRFpN3hrsf1OsoghRBwNyK
         SzdUYp7PcQPaftB4lVQXtZIjEVEiYjEPtumSzNG+62wGwAIKVCp3nOHfg7wJrdrhyLLz
         NZl4LbzHbFJ1myKCxO2xWEhl8vM1X3nxaUPjVL5EDqPcvMBNqvqkWnU4HJTFeQBUCBCa
         sq+4u+saFagtrLCVZvcoxT0R1HmFVbh4tbiTKZHr+cnQA3PY9YCgS/RxbWR3Qd3SzKjB
         me5w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVkg9Dw4tc9KI5pKjYMUK7v4TC0CLo2eRNqduC5qlimkQuc+hoZ
	fCXsPpiagm9wSS+xpWi1xFaw5cNstM4Y0mUqSdjDRpmk1qi+fcgg412BH3grye2nnAOGRt7APot
	WG9csoVPSGQpj7DyqARBe1AOvF+gmDR8pMVgN6ux/se0vs8p15xFw77k+9E1t062RXg==
X-Received: by 2002:a37:e40f:: with SMTP id y15mr7168173qkf.230.1551904293712;
        Wed, 06 Mar 2019 12:31:33 -0800 (PST)
X-Google-Smtp-Source: APXvYqx/zLbYj3m3L2eEDaC+0uDiN95IiPH9tXkiEQAeREGRFZTQiL49r5dcAzd0AGlG/93wDSx0
X-Received: by 2002:a37:e40f:: with SMTP id y15mr7168098qkf.230.1551904292523;
        Wed, 06 Mar 2019 12:31:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551904292; cv=none;
        d=google.com; s=arc-20160816;
        b=GjmDhOo4g3nvBe3zPUDBOCDMpoatqxA1fq7fEeR9sI9g2c2EElUrCRJGdwLUkHdPa4
         F9SqDWS+x8wBXvMZuMoaaBLzyQyo6BIbVMVOn6+vOhzNi/K2y2BHCqnwvEExbqtmKKPO
         riDk6Y0a79nFI+X4CS/NvtwdyjMio5fril+iaaDSubW7GtZYsdODC8IQwIydhy51dVaD
         d8ZvtoxOZzg336hKUPISdew9sYHQVvjJEj9SWezAB111Czq3F+PQm5aqJURu8VWpfLZK
         nro8j11+H789MhNH30MUGJSu0aHddgNHAEDgM8A2tqIotUuLHuJak2llmbIcTTtnoXEF
         qOiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :references:subject:cc:to:from;
        bh=UlC7qYsBq2rAW0oNth9dOh1TqkQSBwF+kzd5m3TYBGU=;
        b=Gve9f3U34HymdfUFR89xtWlMW0H2hz8G3rJLRPsWWMiRUeMTIEBoxNiGZKXF7D9hHs
         ZigUo62Fs1iiliK7/nrOcNIZCemViS7wsyyEq3oq3sktqzCvtF/H9sD7o/AGXhzG04eN
         8S0oCnrNOIzAR7brS/0BuRkO3U/8DXaDJzDMCe1BJwiHVJiuAvVlCcHz//Cb/cZSESbz
         DbPaX5S7Ve6LLVO7SY229u/fYRARGZDwff3meZ32cViuvNLu1cR2Q3iDLWANca5W08A0
         UaSPXFzmgWQBoZsv68wLXSF0f2Fzivn394d1QnigIYt7+vWtX7QasqjZKmw2j1+TkxMc
         J5TQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l32si1553850qve.83.2019.03.06.12.31.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 12:31:32 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 425E130A81BE;
	Wed,  6 Mar 2019 20:31:31 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 3C65A5C647;
	Wed,  6 Mar 2019 20:31:20 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
 "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>,
 David Hildenbrand <david@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com>
 <20190306130955-mutt-send-email-mst@kernel.org>
 <afc52d00-c769-01a0-949a-8bc96af47fab@redhat.com>
 <20190306133826-mutt-send-email-mst@kernel.org>
 <3f87916d-8d18-013c-8988-9eb516c9cd2e@redhat.com>
 <CAKgT0UdqCb37VNe7pABBYBXYFrVzYdPntmPf-V6ZYp9DdwmxYA@mail.gmail.com>
 <7b98b7b3-68f5-e4e0-1454-2217f41e46ad@redhat.com>
 <CAKgT0UePn86cnjzietzuqdosjJH3McH2xDQ3ocjbujMKdsk7Pw@mail.gmail.com>
Organization: Red Hat Inc,
Message-ID: <7f82319b-17a8-71f9-853e-fccbe064282c@redhat.com>
Date: Wed, 6 Mar 2019 15:31:18 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0UePn86cnjzietzuqdosjJH3McH2xDQ3ocjbujMKdsk7Pw@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="xOcfvAQELRTUWgL4ByVin4A4MMsspyN5F"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Wed, 06 Mar 2019 20:31:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xOcfvAQELRTUWgL4ByVin4A4MMsspyN5F
Content-Type: multipart/mixed; boundary="TZLb9yKarVLPas4urIf5edq6PNwntwBBE";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
 "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>,
 David Hildenbrand <david@redhat.com>
Message-ID: <7f82319b-17a8-71f9-853e-fccbe064282c@redhat.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting

--TZLb9yKarVLPas4urIf5edq6PNwntwBBE
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 3/6/19 2:24 PM, Alexander Duyck wrote:
> On Wed, Mar 6, 2019 at 11:18 AM David Hildenbrand <david@redhat.com> wr=
ote:
>> On 06.03.19 20:08, Alexander Duyck wrote:
>>> On Wed, Mar 6, 2019 at 11:00 AM David Hildenbrand <david@redhat.com> =
wrote:
>>>> On 06.03.19 19:43, Michael S. Tsirkin wrote:
>>>>> On Wed, Mar 06, 2019 at 01:30:14PM -0500, Nitesh Narayan Lal wrote:=

>>>>>>>> Here are the results:
>>>>>>>>
>>>>>>>> Procedure: 3 Guests of size 5GB is launched on a single NUMA nod=
e with
>>>>>>>> total memory of 15GB and no swap. In each of the guest, memhog i=
s run
>>>>>>>> with 5GB. Post-execution of memhog, Host memory usage is monitor=
ed by
>>>>>>>> using Free command.
>>>>>>>>
>>>>>>>> Without Hinting:
>>>>>>>>                  Time of execution    Host used memory
>>>>>>>> Guest 1:        45 seconds            5.4 GB
>>>>>>>> Guest 2:        45 seconds            10 GB
>>>>>>>> Guest 3:        1  minute               15 GB
>>>>>>>>
>>>>>>>> With Hinting:
>>>>>>>>                 Time of execution     Host used memory
>>>>>>>> Guest 1:        49 seconds            2.4 GB
>>>>>>>> Guest 2:        40 seconds            4.3 GB
>>>>>>>> Guest 3:        50 seconds            6.3 GB
>>>>>>> OK so no improvement.
>>>>>> If we are looking in terms of memory we are getting back from the =
guest,
>>>>>> then there is an improvement. However, if we are looking at the
>>>>>> improvement in terms of time of execution of memhog then yes there=
 is none.
>>>>> Yes but the way I see it you can't overcommit this unused memory
>>>>> since guests can start using it at any time.  You timed it carefull=
y
>>>>> such that this does not happen, but what will cause this timing on =
real
>>>>> guests?
>>>> Whenever you overcommit you will need backup swap. There is no way
>>>> around it. It just makes the probability of you having to go to disk=

>>>> less likely.
>>>>
>>>> If you assume that all of your guests will be using all of their mem=
ory
>>>> all the time, you don't have to think about overcommiting memory in =
the
>>>> first place. But this is not what we usually have.
>>> Right, but the general idea is that free page hinting allows us to
>>> avoid having to use the swap if we are hinting the pages as unused.
>>> The general assumption we are working with is that some percentage of=

>>> the VMs are unused most of the time so you can share those resources
>>> between multiple VMs and have them free those up normally.
>> Yes, similar to VCPU yielding or playin scheduling when the VCPU is
>> spleeping. Instead of busy looping, hand over the resource to somebody=

>> who can actually make use of it.
>>
>>> If we can reduce swap usage we can improve overall performance and
>>> that was what I was pointing out with my test. I had also done
>>> something similar to what Nitesh was doing with his original test
>>> where I had launched 8 VMs with 8GB of memory per VM on a system with=

>>> 32G of RAM and only 4G of swap. In that setup I could keep a couple
>>> VMs busy at a time without issues, and obviously without the patch I
>>> just started to OOM qemu instances and  could only have 4 VMs at a
>>> time running at maximum.
>> While these are nice experiments (especially to showcase reduced swap
>> usage!), I would not suggest to use 4GB of swap on a x2 overcomited
>> system (32GB overcommited). Disks are so cheap nowadays that one does
>> not have to play with fire.
> Right. The only reason for using 4G is because the system normally has
> 128G of RAM available and I didn't really think I would need swap for
> the system when I originally configured it.
>
>> But yes, reducing swap usage implies overall system performance (unles=
s
>> the hinting is terribly slow :) ). Reducing swap usage, not swap space=
 :)
> Right. Also the swap is really a necessity if we are going to look at
> things like MADV_FREE as I have not seen us really start to free up
> resources until we are starting to put some pressure on swap.
I agree in order to see the effect of MADV_FREE we may have to use
swap(it doesn't have to be huge).
About Michael's comment, if the guest is consistently under memory
pressure then we may not get anything back in the host at all during
this time.


--=20
Thanks
Nitesh


--TZLb9yKarVLPas4urIf5edq6PNwntwBBE--

--xOcfvAQELRTUWgL4ByVin4A4MMsspyN5F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyALhYACgkQo4ZA3AYy
ozlDYw/9F8NvkshmvVPAJtd0pZqaaFw9gpymX81vRnXnGdFI+jXt5h215P6hXO6+
FQKlWJu3gV4NPefa/hOYcLe++/b+eARdRUQIluxlwoEDkMbxAFKHAXi0s5aDhKR2
3gWukHuEKXm/V8xyqrh34By10Dl83JPtFAw0WOfAUadMmTPEmAIWreky3KUs9s4j
3LS+YbXUT7LVwzFOgh9ScYn6MhkS9Ais6Di4cPcBc962WhDlfFhYbR3YFFpOXcgb
NPZfXp649nnJjMumH0SnohUXEiZmuVn9f8HjZIUu8Jckn2j3TceXX4MnZzrVYHt4
gfo3JRydjB+y/2NUdjOqcDZrHRZILMEr+GZyoIvqd3nG/7mku+yf85UoVwgcAHQv
AsKHZhjHDp2HTnV8wBFgO7amvCF29jpvdFpIZjkpQeejHfT0x4sFg0rDKc5Z6F57
gkJotUkvvBegUJHh86/5Yk525lNdywEd4pFPBDVoLl71s1eHhVwfyNbUr/QhSW5e
7IzDxRboTxgI0k1cBQjuXBFN1Etqa2prkou171DmBhnKJSmKEe1tum3aYaTV+YOR
0vOKzIJgoAK640bqO9kIxaO8kD5DUnIReRj5I9gNmjmEfYXjmIRyodoHpYE5bl7h
GUMTkt3Rci/72UmqmHrAfLvZv41MMLyArJV5EdWqgxZJAniJXxE=
=Fdc3
-----END PGP SIGNATURE-----

--xOcfvAQELRTUWgL4ByVin4A4MMsspyN5F--

