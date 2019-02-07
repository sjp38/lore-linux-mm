Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 203ECC282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 14:48:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF1D021872
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 14:48:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF1D021872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 579618E0036; Thu,  7 Feb 2019 09:48:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 502618E0002; Thu,  7 Feb 2019 09:48:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A2038E0036; Thu,  7 Feb 2019 09:48:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0AB478E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 09:48:37 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 207so94960qkl.2
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 06:48:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to;
        bh=7tqcIkQ2xBEin/1Kv+EH2lA8j2M4381YTNG2tnNsA7M=;
        b=fSLoKwb1KtsHBJnYW3/o7z2Lew0Y12tSMXDBKVZteNxPsC6Wv/v6yOnJX1y60a2jvL
         kDmRBkTTst+lq+eDLOGwqyea1CyRrbk4hkPDLO5QC/e639lhWOiLioWQfA11fipbTEHw
         nTDnzWmspbbhnFqhYnS4gOkjQPIQJDh2zncO8ntmAcKAfU3i/3Rk29Dm7dDXJsBt8334
         Z+VQCn4DI6TvdHqCKr1MpiILYenSB5FpLMUiEjmFsLr3MYxbSJ1FVfrdBj6xUm898ziK
         VXP9iD36OCGUXI3dYlExtQwf767rfdnM45aqUtrZAwWk7lx8aRzHfCWBSnpEGf6ouZBR
         +sfA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZu4lQpioV+8b1OXCyt2+BufyJV7CqHZdW6Ss+GA98DEXqnZbql
	230eqTD29p8KlFlSTDxee5byiOyqIExa16w0VkzVjNpgYQatLOqwdqJLOWyxLaAxDb/4d2Mb1Uv
	4vCjW5/iNj8exmsl7wfsnU/w9jJHUJW821zJhhuDuASwMZR02tTV9RdXm4Fj1XmMwpw==
X-Received: by 2002:ae9:f50d:: with SMTP id o13mr12125263qkg.137.1549550916635;
        Thu, 07 Feb 2019 06:48:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYEdLvt/bNHRXrLmOejBGFrhUfoEz7/U5JIqn6DmvzxLnpT25V0W5X/8wN+hYao3eZnwyZR
X-Received: by 2002:ae9:f50d:: with SMTP id o13mr12125239qkg.137.1549550916183;
        Thu, 07 Feb 2019 06:48:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549550916; cv=none;
        d=google.com; s=arc-20160816;
        b=ec/7Y4bbudqs141EU5LvNc1RLL1XDdR18WhEOOBp+Uq3nwMIcfSLZqG75SwzG6szRS
         0qddwaL3uUUswhEzb+xQkhhwjE8pfI5CFKvO/aXWmja9XpvD6GXnawqt+xJwdfdp9yR9
         NxQ2mSCnAxnm9gZlvYvCx5sdYwogS8MoTCubkLFj7TjuJt2evblFXKobRNSENGys1d0P
         WdPg6BzX9Q3KWUTmOUAUsCfPmYSzyL/0Vo9ySJX9fVkDzrnXckAHhwIyQpOXJMQdcVoR
         BqA2qnfMH75YqcoHZY40WV8ZIQM3SOAp72uzD0F81Eu1yrYQGikzch9nduEKdUWi7CFw
         T3vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :autocrypt:openpgp:from:references:cc:to:subject;
        bh=7tqcIkQ2xBEin/1Kv+EH2lA8j2M4381YTNG2tnNsA7M=;
        b=GOqItIw/TxjuhDhN7e8HQxKqwaEiS4AwdEFu/e4KbMZhMT0Z0rUosOVZFRUIoq5JL+
         pX2XcKJoWjbjiVNuDLphAQh4HkmiWhNWBljW6C79eBPI0iM0IHRsnYoLCNY7NnJCQw6Z
         bYIX/he0SAAd+tfnsn0ZcSeHwipLTIf+O3cOQY0LCOAxANtW7m21kVUnM4fI5tELWY90
         P3Y5p+1mrupICQSLnB4boXKRhPyxCTPK1dR2+Zxq2RUYcg+gDC9+HL1IOdms6TRZpp5c
         ashMdO6vvPi3ZCejEldUr9p9lIe742Volmx9RygkS50fdXcqOSSCCIsBac8ShHp0rFP8
         E8gg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y2si3343086qtf.92.2019.02.07.06.48.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 06:48:36 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E44C859467;
	Thu,  7 Feb 2019 14:48:34 +0000 (UTC)
Received: from [10.18.17.32] (dhcp-17-32.bos.redhat.com [10.18.17.32])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1526067639;
	Thu,  7 Feb 2019 14:48:28 +0000 (UTC)
Subject: Re: [RFC PATCH 0/4] kvm: Report unused guest pages to host
To: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org
Cc: rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com, x86@kernel.org,
 mingo@redhat.com, bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com,
 tglx@linutronix.de, akpm@linux-foundation.org,
 Luiz Capitulino <lcapitulino@redhat.com>,
 David Hildenbrand <david@redhat.com>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 mQINBFl4pQoBEADT/nXR2JOfsCjDgYmE2qonSGjkM1g8S6p9UWD+bf7YEAYYYzZsLtbilFTe
 z4nL4AV6VJmC7dBIlTi3Mj2eymD/2dkKP6UXlliWkq67feVg1KG+4UIp89lFW7v5Y8Muw3Fm
 uQbFvxyhN8n3tmhRe+ScWsndSBDxYOZgkbCSIfNPdZrHcnOLfA7xMJZeRCjqUpwhIjxQdFA7
 n0s0KZ2cHIsemtBM8b2WXSQG9CjqAJHVkDhrBWKThDRF7k80oiJdEQlTEiVhaEDURXq+2XmG
 jpCnvRQDb28EJSsQlNEAzwzHMeplddfB0vCg9fRk/kOBMDBtGsTvNT9OYUZD+7jaf0gvBvBB
 lbKmmMMX7uJB+ejY7bnw6ePNrVPErWyfHzR5WYrIFUtgoR3LigKnw5apzc7UIV9G8uiIcZEn
 C+QJCK43jgnkPcSmwVPztcrkbC84g1K5v2Dxh9amXKLBA1/i+CAY8JWMTepsFohIFMXNLj+B
 RJoOcR4HGYXZ6CAJa3Glu3mCmYqHTOKwezJTAvmsCLd3W7WxOGF8BbBjVaPjcZfavOvkin0u
 DaFvhAmrzN6lL0msY17JCZo046z8oAqkyvEflFbC0S1R/POzehKrzQ1RFRD3/YzzlhmIowkM
 BpTqNBeHEzQAlIhQuyu1ugmQtfsYYq6FPmWMRfFPes/4JUU/PQARAQABtCVOaXRlc2ggTmFy
 YXlhbiBMYWwgPG5pbGFsQHJlZGhhdC5jb20+iQI9BBMBCAAnBQJZeKUKAhsjBQkJZgGABQsJ
 CAcCBhUICQoLAgQWAgMBAh4BAheAAAoJEKOGQNwGMqM56lEP/A2KMs/pu0URcVk/kqVwcBhU
 SnvB8DP3lDWDnmVrAkFEOnPX7GTbactQ41wF/xwjwmEmTzLrMRZpkqz2y9mV0hWHjqoXbOCS
 6RwK3ri5e2ThIPoGxFLt6TrMHgCRwm8YuOSJ97o+uohCTN8pmQ86KMUrDNwMqRkeTRW9wWIQ
 EdDqW44VwelnyPwcmWHBNNb1Kd8j3xKlHtnS45vc6WuoKxYRBTQOwI/5uFpDZtZ1a5kq9Ak/
 MOPDDZpd84rqd+IvgMw5z4a5QlkvOTpScD21G3gjmtTEtyfahltyDK/5i8IaQC3YiXJCrqxE
 r7/4JMZeOYiKpE9iZMtS90t4wBgbVTqAGH1nE/ifZVAUcCtycD0f3egX9CHe45Ad4fsF3edQ
 ESa5tZAogiA4Hc/yQpnnf43a3aQ67XPOJXxS0Qptzu4vfF9h7kTKYWSrVesOU3QKYbjEAf95
 NewF9FhAlYqYrwIwnuAZ8TdXVDYt7Z3z506//sf6zoRwYIDA8RDqFGRuPMXUsoUnf/KKPrtR
 ceLcSUP/JCNiYbf1/QtW8S6Ca/4qJFXQHp0knqJPGmwuFHsarSdpvZQ9qpxD3FnuPyo64S2N
 Dfq8TAeifNp2pAmPY2PAHQ3nOmKgMG8Gn5QiORvMUGzSz8Lo31LW58NdBKbh6bci5+t/HE0H
 pnyVf5xhNC/FuQINBFl4pQoBEACr+MgxWHUP76oNNYjRiNDhaIVtnPRqxiZ9v4H5FPxJy9UD
 Bqr54rifr1E+K+yYNPt/Po43vVL2cAyfyI/LVLlhiY4yH6T1n+Di/hSkkviCaf13gczuvgz4
 KVYLwojU8+naJUsiCJw01MjO3pg9GQ+47HgsnRjCdNmmHiUQqksMIfd8k3reO9SUNlEmDDNB
 XuSzkHjE5y/R/6p8uXaVpiKPfHoULjNRWaFc3d2JGmxJpBdpYnajoz61m7XJlgwl/B5Ql/6B
 dHGaX3VHxOZsfRfugwYF9CkrPbyO5PK7yJ5vaiWre7aQ9bmCtXAomvF1q3/qRwZp77k6i9R3
 tWfXjZDOQokw0u6d6DYJ0Vkfcwheg2i/Mf/epQl7Pf846G3PgSnyVK6cRwerBl5a68w7xqVU
 4KgAh0DePjtDcbcXsKRT9D63cfyfrNE+ea4i0SVik6+N4nAj1HbzWHTk2KIxTsJXypibOKFX
 2VykltxutR1sUfZBYMkfU4PogE7NjVEU7KtuCOSAkYzIWrZNEQrxYkxHLJsWruhSYNRsqVBy
 KvY6JAsq/i5yhVd5JKKU8wIOgSwC9P6mXYRgwPyfg15GZpnw+Fpey4bCDkT5fMOaCcS+vSU1
 UaFmC4Ogzpe2BW2DOaPU5Ik99zUFNn6cRmOOXArrryjFlLT5oSOe4IposgWzdwARAQABiQIl
 BBgBCAAPBQJZeKUKAhsMBQkJZgGAAAoJEKOGQNwGMqM5ELoP/jj9d9gF1Al4+9bngUlYohYu
 0sxyZo9IZ7Yb7cHuJzOMqfgoP4tydP4QCuyd9Q2OHHL5AL4VFNb8SvqAxxYSPuDJTI3JZwI7
 d8JTPKwpulMSUaJE8ZH9n8A/+sdC3CAD4QafVBcCcbFe1jifHmQRdDrvHV9Es14QVAOTZhnJ
 vweENyHEIxkpLsyUUDuVypIo6y/Cws+EBCWt27BJi9GH/EOTB0wb+2ghCs/i3h8a+bi+bS7L
 FCCm/AxIqxRurh2UySn0P/2+2eZvneJ1/uTgfxnjeSlwQJ1BWzMAdAHQO1/lnbyZgEZEtUZJ
 x9d9ASekTtJjBMKJXAw7GbB2dAA/QmbA+Q+Xuamzm/1imigz6L6sOt2n/X/SSc33w8RJUyor
 SvAIoG/zU2Y76pKTgbpQqMDmkmNYFMLcAukpvC4ki3Sf086TdMgkjqtnpTkEElMSFJC8npXv
 3QnGGOIfFug/qs8z03DLPBz9VYS26jiiN7QIJVpeeEdN/LKnaz5LO+h5kNAyj44qdF2T2AiF
 HxnZnxO5JNP5uISQH3FjxxGxJkdJ8jKzZV7aT37sC+Rp0o3KNc+GXTR+GSVq87Xfuhx0LRST
 NK9ZhT0+qkiN7npFLtNtbzwqaqceq3XhafmCiw8xrtzCnlB/C4SiBr/93Ip4kihXJ0EuHSLn
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <e0bf61d2-c315-ae4f-6ddb-93b7882fd13f@redhat.com>
Date: Thu, 7 Feb 2019 09:48:27 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190204181118.12095.38300.stgit@localhost.localdomain>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="u3whL6aquCy1ts4iceBw9JljlbrMn7YPA"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 07 Feb 2019 14:48:35 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--u3whL6aquCy1ts4iceBw9JljlbrMn7YPA
Content-Type: multipart/mixed; boundary="DOAx8TQ4zzvecILyQ2LYNZmFYya6XHM3o";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org
Cc: rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com, x86@kernel.org,
 mingo@redhat.com, bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com,
 tglx@linutronix.de, akpm@linux-foundation.org,
 Luiz Capitulino <lcapitulino@redhat.com>,
 David Hildenbrand <david@redhat.com>
Message-ID: <e0bf61d2-c315-ae4f-6ddb-93b7882fd13f@redhat.com>
Subject: Re: [RFC PATCH 0/4] kvm: Report unused guest pages to host
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
In-Reply-To: <20190204181118.12095.38300.stgit@localhost.localdomain>

--DOAx8TQ4zzvecILyQ2LYNZmFYya6XHM3o
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

Hi Alexander,

Did you get a chance to look at my v8 posting of Guest Free Page Hinting
[1]?
Considering both the solutions are trying to solve the same problem. It
will be great if we can collaborate and come up with a unified solution.

[1] https://lkml.org/lkml/2019/2/4/993
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


--DOAx8TQ4zzvecILyQ2LYNZmFYya6XHM3o--

--u3whL6aquCy1ts4iceBw9JljlbrMn7YPA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlxcRTsACgkQo4ZA3AYy
oznkYBAAxlLH2s8HfygIKMiuKDu6CPvf/Fk18SRuvBRIFJSSOyeC/qzlDoyn8By6
tLRTpm7sAnrU1eCzfKq2GUSWrFPxAIHVe1ynU/gpaqE16ynC6TjENlSNeCyHUC1P
r8QD5E+aNa2hIbkNcBmiMvS3a9fPJo9FyoWdY0S8hqABvpDMJ1r3E5Rawnrfw8EX
qadktlGMdMRcyv9xepwf75fc7eRQmTHdXTJcUn0svqQTL89F6IZ4uXJmkfMtL9Gn
7tVEbghXQlDuUaVQ8NgZwn0M2o5wg/PyC3mTX2kJL90Pi5uEX8/tNrRh/bay3o0Y
izULYHVm4LizCGDtRoT6zX8N6lG/+VtO4FIaO+rcmhb1La4UCGTlZ/BToe/rH1+W
Uy5FpfxmgrpJJ4S2/15lPUIXeAM4XlZjqqX0lHW8o0+cd4fQ3PsmjWQPPL6oIYAT
L8vwgD80lUFvTi0Lvn8nWtXynTPH0Re8PVh3sP8GA0tiCtuDaYRGSblUHEjf5z1a
KqpfSl+dq2IcQjAUd8Y34FKS/KSzRsNa1hseCr2aImWdpgrz2gQr6Q1rqmV0YXSg
x4GDPp+syLtPdg200l+AJ/oPzg6heu+zVf83zn4m7O5W6pH71aIwS8sL5PLLjF2K
mwpz4LNGlhuPey8ruTnnS4BZiV4kXSiUJOjFZZ2ZwYJvrccHFZI=
=H1K3
-----END PGP SIGNATURE-----

--u3whL6aquCy1ts4iceBw9JljlbrMn7YPA--

