Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F91EC282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 17:25:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB62020818
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 17:25:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB62020818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 621218E0092; Tue,  5 Feb 2019 12:25:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5AA008E0091; Tue,  5 Feb 2019 12:25:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45CB08E0092; Tue,  5 Feb 2019 12:25:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1635C8E0091
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 12:25:28 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id z126so3813334qka.10
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 09:25:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to;
        bh=VXoeiKC8puCQxF/8cJN387rMptBDk7xFz104588BhO4=;
        b=AIzVqo3uwjG27+EVPonpVLTMWFvr6J3jYakVNuSFlVeii41Fj1d8mwB12OSh5ANCC5
         L0PoNpFNUjz7cew/gvyconXVqvXM6kLv2+SL+ap5E3fBJUiqOZjaitT/1YmBVqdZLmau
         MH8dzKu/CjmuOPRfn3aZFKNu7b4jES+ElIUeMCVj+VdNiD0/01dlDoBYlLRIQBOEZT//
         kjlGKk8oKxNHFvUfCNSiL0YEF3X99aUfpGTcvmMfEaZjqp8omOFDhzYegryafd4QRjkG
         Y6y2LgDtKCCHKq1a9UuVauG9gptCuvVwnE2Wa2oQ+9htLafHd4HkNQJ04omjVz0osseW
         I3SA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAub1oPaoXc63dPTXT20eaxlyP+6KJtPot07Qs0dPQaDtupvHct4K
	YI99lHhfJeTO+ep7OHOy20E568niHdQhMM/I34jH7YeABLlB0uoRmiqQusViHBRv9wP5juNJvJ4
	W7caQ1jxrI6FuH9HTiMJmmEmuGKUJvVJ0ZfeNQcUd3bKeysOmifVFU5zeo617xVTIkQ==
X-Received: by 2002:ac8:4644:: with SMTP id f4mr4361824qto.329.1549387527851;
        Tue, 05 Feb 2019 09:25:27 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbraO/Rrp6xASfFOYUR+1IvUUziDlmQ+CYY2s/Rdmb9gWnZTL9s57pp+mn/N9muTd38zhNi
X-Received: by 2002:ac8:4644:: with SMTP id f4mr4361783qto.329.1549387527231;
        Tue, 05 Feb 2019 09:25:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549387527; cv=none;
        d=google.com; s=arc-20160816;
        b=jT96Lf3So0FJnb69AWPTBPxtIQzmUWMP+TJl8hvhvAsoj1BMTQkBaG8PBqcyWZAIWQ
         r80f3optdDwOCwm6mi0a0s0L1q4DXcJBwSo3cawcUTz8z8yJFEj8yWH6hcuqAO75ez9H
         1WcCQXKjbZrz9FFWECAGa/NwDJ5ckjKjjQ/1uKOZ2tmMn0UzBxFSOkObx7hmB6MAFFTi
         nYf5HNc81oMuTChBwN2FhrmJLF7+zSAKPauUCSR+9LK7o6u1GIMxyn4/A9w5pD0IoEIA
         HjJPWuhvEu4lhpGldavBHBpAcNK3k36xoQhbmOPMQ4qK5/+xDV2I9nhAWk/gakt9ndjJ
         tfTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :autocrypt:openpgp:from:references:cc:to:subject;
        bh=VXoeiKC8puCQxF/8cJN387rMptBDk7xFz104588BhO4=;
        b=vazv9rm87jgaCv8z/4pTFmZsDqx/5+MvcI4PXvYQg7FvO3p2pYITYjaiiY3tbZwqAr
         Uo/GIRTSjfXGII5yjwKMIlYYY33uioG3mrk+OMb4NHCgVITjJK0fOzPRCYM2Hma++abC
         3YhWH6uvs+txF4dX+LpxU4eTk8sHBLHJa0e8PUz/JE2PBY8PWCPI9gC6BdFrLZVaMktS
         Jy62uZN5y4u5lV85NJnnBM24S+sEx61fLGGaIPGlmfpuBGdcBq6YlzPVzqGdEjZUp+er
         O49aCSveM2vwlJGuvrfbGfrDf0jj5xyZvT3NMg4Zd3wJgT7j2weu7zYGzuV80AOYA6eg
         1Eqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a2si1695523qkj.36.2019.02.05.09.25.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 09:25:27 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EDF3681DE3;
	Tue,  5 Feb 2019 17:25:25 +0000 (UTC)
Received: from [10.40.205.61] (unknown [10.40.205.61])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 33C1D19743;
	Tue,  5 Feb 2019 17:25:13 +0000 (UTC)
Subject: Re: [RFC PATCH 0/4] kvm: Report unused guest pages to host
To: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org
Cc: rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com, x86@kernel.org,
 mingo@redhat.com, bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com,
 tglx@linutronix.de, akpm@linux-foundation.org,
 Luiz Capitulino <lcapitulino@redhat.com>,
 David Hildenbrand <david@redhat.com>, Pankaj Gupta <pagupta@redhat.com>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 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
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <697d3769-9320-a632-749e-56de9474bdf0@redhat.com>
Date: Tue, 5 Feb 2019 12:25:11 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190204181118.12095.38300.stgit@localhost.localdomain>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="UNUvqpHAYHR04TsVLVUGxIIA9gwO8kvCl"
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 05 Feb 2019 17:25:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--UNUvqpHAYHR04TsVLVUGxIIA9gwO8kvCl
Content-Type: multipart/mixed; boundary="3mzxJ6gNvVUIdJzVqezGb18HN9ja562tQ";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org
Cc: rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com, x86@kernel.org,
 mingo@redhat.com, bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com,
 tglx@linutronix.de, akpm@linux-foundation.org,
 Luiz Capitulino <lcapitulino@redhat.com>,
 David Hildenbrand <david@redhat.com>, Pankaj Gupta <pagupta@redhat.com>
Message-ID: <697d3769-9320-a632-749e-56de9474bdf0@redhat.com>
Subject: Re: [RFC PATCH 0/4] kvm: Report unused guest pages to host
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
In-Reply-To: <20190204181118.12095.38300.stgit@localhost.localdomain>

--3mzxJ6gNvVUIdJzVqezGb18HN9ja562tQ
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US


On 2/4/19 1:15 PM, Alexander Duyck wrote:
> This patch set provides a mechanism by which guests can notify the host=
 of
> pages that are not currently in use. Using this data a KVM host can mor=
e
> easily balance memory workloads between guests and improve overall syst=
em
> performance by avoiding unnecessary writing of unused pages to swap.
>
> In order to support this I have added a new hypercall to provided unuse=
d
> page hints and made use of mechanisms currently used by PowerPC and s39=
0
> architectures to provide those hints. To reduce the overhead of this ca=
ll
> I am only using it per huge page instead of of doing a notification per=
 4K
> page. By doing this we can avoid the expense of fragmenting higher orde=
r
> pages, and reduce overall cost for the hypercall as it will only be
> performed once per huge page.
>
> Because we are limiting this to huge pages it was necessary to add a
> secondary location where we make the call as the buddy allocator can me=
rge
> smaller pages into a higher order huge page.
>
> This approach is not usable in all cases. Specifically, when KVM direct=

> device assignment is used, the memory for a guest is permanently assign=
ed
> to physical pages in order to support DMA from the assigned device. In
> this case we cannot give the pages back, so the hypercall is disabled b=
y
> the host.
>
> Another situation that can lead to issues is if the page were accessed
> immediately after free. For example, if page poisoning is enabled the
> guest will populate the page *after* freeing it. In this case it does n=
ot
> make sense to provide a hint about the page being freed so we do not
> perform the hypercalls from the guest if this functionality is enabled.=

>
> My testing up till now has consisted of setting up 4 8GB VMs on a syste=
m
> with 32GB of memory and 4GB of swap. To stress the memory on the system=
 I
> would run "memhog 8G" sequentially on each of the guests and observe ho=
w
> long it took to complete the run. The observed behavior is that on the
> systems with these patches applied in both the guest and on the host I =
was
> able to complete the test with a time of 5 to 7 seconds per guest. On a=

> system without these patches the time ranged from 7 to 49 seconds per
> guest. I am assuming the variability is due to time being spent writing=

> pages out to disk in order to free up space for the guest.

Hi Alexander,

Can you share the host memory usage before and after your run. (In both
the cases with your patch-set and without your patch-set)

>
> ---
>
> Alexander Duyck (4):
>       madvise: Expose ability to set dontneed from kernel
>       kvm: Add host side support for free memory hints
>       kvm: Add guest side support for free memory hints
>       mm: Add merge page notifier
>
>
>  Documentation/virtual/kvm/cpuid.txt      |    4 ++
>  Documentation/virtual/kvm/hypercalls.txt |   14 ++++++++
>  arch/x86/include/asm/page.h              |   25 +++++++++++++++
>  arch/x86/include/uapi/asm/kvm_para.h     |    3 ++
>  arch/x86/kernel/kvm.c                    |   51 ++++++++++++++++++++++=
++++++++
>  arch/x86/kvm/cpuid.c                     |    6 +++-
>  arch/x86/kvm/x86.c                       |   35 +++++++++++++++++++++
>  include/linux/gfp.h                      |    4 ++
>  include/linux/mm.h                       |    2 +
>  include/uapi/linux/kvm_para.h            |    1 +
>  mm/madvise.c                             |   13 +++++++-
>  mm/page_alloc.c                          |    2 +
>  12 files changed, 158 insertions(+), 2 deletions(-)
>
> --
--=20
Regards
Nitesh


--3mzxJ6gNvVUIdJzVqezGb18HN9ja562tQ--

--UNUvqpHAYHR04TsVLVUGxIIA9gwO8kvCl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlxZxvcACgkQo4ZA3AYy
ozkEqhAAu4FHz89C2Q2BhyO80m3XgDigU0kqHA+faS1wy8w83dDXh/V4nczbn1Z5
71V8p7YZuD/8LK2yyKk5m62Me5QlHlQIAooBajew4/H60B8aR+kcCEqM7GxtBTqE
rKVPDdSws3+9NH53PtODsskZjS2kgX2NHknphl6EYzEzOwrQeO2nxJgNFALnAFz1
bUyUYcEj9gaIYWHRai6kJnjnaIT8FN6u0C7PCjiWxDHKz8Xm3LBvuk2wvgPXPYEQ
ctX3vQRttgoYylfthdkWBFQGXk+NCiOx7neGRRgOUcZz/eRdL3vu6BRHQuzS6lKJ
TzZWfxTZvKVeYVdP1JGBemrxIA9QqBIKlcGooICQ1MXaFN3sxDd3bq+6zwvCE5Gt
VsP3as0v1qX5+Whv2knjUnylamBqZLxS6hd3MHTX8o8ZUtLJXY2QEB6yQrTULy/0
zvjm1xVNxewJEtAes3d5WEmii0XdGogBd9kyfkSCTQJmgP15Ea8gh3mkpIg3CKJv
WBpV7acIZLtYiDhrO7knKDvwGOqhCdAfiPgWwACDEf5E+EPLfgkNqi47WcyOylou
Un3lME+yCA6xOUIC2Kz1bVnIcvaQE0fDqGtB62fvXN0nMhxhZxSEidU0cO0PLIG5
G1GfmzY2yZVLSJ1yg8FgM5jazu7YMX5Y2oCjvYdZeYIZYmwk4p8=
=0CAg
-----END PGP SIGNATURE-----

--UNUvqpHAYHR04TsVLVUGxIIA9gwO8kvCl--

