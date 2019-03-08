Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BF0FC10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 19:39:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 480E720851
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 19:39:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 480E720851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE5258E0003; Fri,  8 Mar 2019 14:39:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6D308E0002; Fri,  8 Mar 2019 14:39:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B36988E0003; Fri,  8 Mar 2019 14:39:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 84A9F8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 14:39:21 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id p5so19704724qtp.3
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 11:39:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:organization:message-id:date:user-agent
         :mime-version:in-reply-to;
        bh=WLd5iabUz7fVsD25SCAIyrIkTaIch2arfngvvBG4A4k=;
        b=PuNRHfd1h/dNIuu8a1gmGrxP8LrIIMXb0TaiZ7uKPNeVnfc6/2H4gCzDU+OxxVhB1B
         L48d2jHU9LT8/ZEL0KrPq4hyOrCdHtuwxIXJJUWl9PlrL7fDwdZZaCT8JPDV2pmazSB5
         DqSKNf3SXKyDi8as4OZ+UJ+/f/avF7cn4y48PHrOPCUOU1VGj7+Z3WbJWu0KptxMWC0L
         16XMjTeOqfFUP5FttCBykAGDjHFr2b1qBoU7d0kpbLwCasENXlhFVmJc3C2TLfs93fLA
         bAN7YvoqbeE0Kw+zvNZznbql3xGpoYcHkvsXbMTLWHuC7KH6vRb4bC3nonftN68+eLpd
         kVPg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXLVaRgfPG8jKgCp49BW4a/64rrNZxcjA2J6U9SmcMgEEaylgtA
	r11csODY5c6KGZKPawE4BQDkeeXfKbg42EQjM6BcjZikfG2JVI6syrMBU6+12bZT5vq0BdB0hdV
	+E4V4HMjRngGgSS952TyO2XbEYXGHRJQJYK038Cpqgu0quDV3tp3O+GrLYkTHLUTDAA==
X-Received: by 2002:ac8:3559:: with SMTP id z25mr16434900qtb.336.1552073961226;
        Fri, 08 Mar 2019 11:39:21 -0800 (PST)
X-Google-Smtp-Source: APXvYqwJRLVlq+qVp6IejG3+iHhqSw87sbUg4wPIKsUjW3k/jY/xts2SOUj6zu+NcMSLL3xugMAd
X-Received: by 2002:ac8:3559:: with SMTP id z25mr16434844qtb.336.1552073960081;
        Fri, 08 Mar 2019 11:39:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552073960; cv=none;
        d=google.com; s=arc-20160816;
        b=cej7/XwY9sKQItuUGoE7ozcYxB7VyYxGk3XkupvHrpFw1jpLHtsKYywcqvY3o4fKUS
         zYFGhpY4Eij9t5yf6jpketxNItanNFFGhAGP3IIG94F+8InLnTnCkijAMu/o6C75v8hd
         F8774W6RRRpyIU18JDZ3bv1lUX9uj5Dw9eYzHsTZ0k0b7WetOJua0YDlp5LARFTP3qnd
         Y6vzPxCUOu0AbgU1txHi6o5X+u+mfQYX9SVGnMP20O7eNQgSNkItQ8FfqT4cBObkB7bJ
         W4vQcjT9XkfRAiMlgC16qlB6rl3EQT3HcnkZM68FrlsQDEd9WcRfKhyOzZVr1uoDUiD5
         WZkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:mime-version:user-agent:date:message-id:organization
         :references:subject:cc:to:from;
        bh=WLd5iabUz7fVsD25SCAIyrIkTaIch2arfngvvBG4A4k=;
        b=nxT/2vf1g9NQSVavGTbkd6uWOEJc+s0vVaNBf9uFotPYNQXVptp2lzYus8iYtHvNOG
         tviwbsxXnLCToOuYfwJTvrCak97bC0rWEkm31svryvwfeudMxZ2ix0oXTg5Ajvyag9b6
         JyQlkYUJm+PCpUAhQSG2T/6EWTLIEzisBbX1xT0Bb1sfUiTCAGM9g8lRiDeMgEzY9x4D
         I3+sB5bM1+/jAqDvWm0huwgDXu+FqgM2wZX3LFRevdBH8MRnBeTnP2VoaD1yQ8VX+X1B
         Fyf34tuMU3MMUS1Ai6yAZZcKK6vxZX0tejNycAMeJ/+SC3ehVtE2IolCojgiPTF8ERBh
         JloQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a2si5352186qvd.95.2019.03.08.11.39.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 11:39:20 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DDFF781E19;
	Fri,  8 Mar 2019 19:39:18 +0000 (UTC)
Received: from [10.40.205.251] (unknown [10.40.205.251])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 10C951690F;
	Fri,  8 Mar 2019 19:39:00 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
 David Hildenbrand <david@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free
 pages
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306155048.12868-3-nitesh@redhat.com>
 <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
 <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com>
 <22e4b1cd-38a5-6642-8cbe-d68e4fcbb0b7@redhat.com>
 <CAKgT0UcAqGX26pcQLzFUevHsLu-CtiyOYe15uG3bkhGZ5BJKAg@mail.gmail.com>
 <78b604be-2129-a716-a7a6-f5b382c9fb9c@redhat.com>
 <CAKgT0Uc_z9Vi+JhQcJYX+J9c4J56RRSkzzegbb2=9xO-NY3dgw@mail.gmail.com>
 <20190307212845-mutt-send-email-mst@kernel.org>
 <CAKgT0Ucu3EMsYBfdKtEiprrn-VBZy3Y+0HdEp5b4PO2SQgGsRw@mail.gmail.com>
 <17d2afa6-556e-ec73-40dc-beac536b3f20@redhat.com>
 <CAKgT0UcdQZwHjmMBkSWmy_ZdShJCagjwomn13g+r7ZNJBRn1LQ@mail.gmail.com>
Organization: Red Hat Inc,
Message-ID: <8f692047-4750-6827-1ee0-d3d354788f09@redhat.com>
Date: Fri, 8 Mar 2019 14:38:56 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0UcdQZwHjmMBkSWmy_ZdShJCagjwomn13g+r7ZNJBRn1LQ@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="8V13K9q11cPOiDPproSx8qZXs1NSfkUuj"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 08 Mar 2019 19:39:19 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--8V13K9q11cPOiDPproSx8qZXs1NSfkUuj
Content-Type: multipart/mixed; boundary="f4QJr4T5d62WyAt2NEZJ9Bhrbh7HvhH7s";
 protected-headers="v1"
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
 David Hildenbrand <david@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
Message-ID: <8f692047-4750-6827-1ee0-d3d354788f09@redhat.com>
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free
 pages

--f4QJr4T5d62WyAt2NEZJ9Bhrbh7HvhH7s
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 3/8/19 2:25 PM, Alexander Duyck wrote:
> On Fri, Mar 8, 2019 at 11:10 AM Nitesh Narayan Lal <nitesh@redhat.com> =
wrote:
>>
>> On 3/8/19 1:06 PM, Alexander Duyck wrote:
>>> On Thu, Mar 7, 2019 at 6:32 PM Michael S. Tsirkin <mst@redhat.com> wr=
ote:
>>>> On Thu, Mar 07, 2019 at 02:35:53PM -0800, Alexander Duyck wrote:
>>>>> The only other thing I still want to try and see if I can do is to =
add
>>>>> a jiffies value to the page private data in the case of the buddy
>>>>> pages.
>>>> Actually there's one extra thing I think we should do, and that is m=
ake
>>>> sure we do not leave less than X% off the free memory at a time.
>>>> This way chances of triggering an OOM are lower.
>>> If nothing else we could probably look at doing a watermark of some
>>> sort so we have to have X amount of memory free but not hinted before=

>>> we will start providing the hints. It would just be a matter of
>>> tracking how much memory we have hinted on versus the amount of memor=
y
>>> that has been pulled from that pool.
>> This is to avoid false OOM in the guest?
> Partially, though it would still be possible. Basically it would just
> be a way of determining when we have hinted "enough". Basically it
> doesn't do us much good to be hinting on free memory if the guest is
> already constrained and just going to reallocate the memory shortly
> after we hinted on it. The idea is with a watermark we can avoid
> hinting until we start having pages that are actually going to stay
> free for a while.
>
>>>  It is another reason why we
>>> probably want a bit in the buddy pages somewhere to indicate if a pag=
e
>>> has been hinted or not as we can then use that to determine if we hav=
e
>>> to account for it in the statistics.
>> The one benefit which I can see of having an explicit bit is that it
>> will help us to have a single hook away from the hot path within buddy=

>> merging code (just like your arch_merge_page) and still avoid duplicat=
e
>> hints while releasing pages.
>>
>> I still have to check PG_idle and PG_young which you mentioned but I
>> don't think we can reuse any existing bits.
> Those are bits that are already there for 64b. I think those exist in
> the page extension for 32b systems. If I am not mistaken they are only
> used in VMA mapped memory. What I was getting at is that those are the
> bits we could think about reusing.
>
>> If we really want to have something like a watermark, then can't we us=
e
>> zone->free_pages before isolating to see how many free pages are there=

>> and put a threshold on it? (__isolate_free_page() does a similar thing=

>> but it does that on per request basis).
> Right. That is only part of it though since that tells you how many
> free pages are there. But how many of those free pages are hinted?
> That is the part we would need to track separately and then then
> compare to free_pages to determine if we need to start hinting on more
> memory or not.
Only pages which are isolated will be hinted, and once a page is
isolated it will not be counted in the zone free pages.
Feel free to correct me if I am wrong.
If I am understanding it correctly you only want to hint the idle pages,
is that right?
>
>>>>> With that we could track the age of the page so it becomes
>>>>> easier to only target pages that are truly going cold rather than
>>>>> trying to grab pages that were added to the freelist recently.
>>>> I like that but I have a vague memory of discussing this with Rik va=
n
>>>> Riel and him saying it's actually better to take away recently used
>>>> ones. Can't see why would that be but maybe I remember wrong. Rik - =
am I
>>>> just confused?
>>> It is probably to cut down on the need for disk writes in the case of=

>>> swap. If that is the case it ends up being a trade off.
>>>
>>> The sooner we hint the less likely it is that we will need to write a=

>>> given page to disk. However the sooner we hint, the more likely it is=

>>> we will need to trigger a page fault and pull back in a zero page to
>>> populate the last page we were working on. The sweet spot will be tha=
t
>>> period of time that is somewhere in between so we don't trigger
>>> unnecessary page faults and we don't need to perform additional swap
>>> reads/writes.
>> --
>> Regards
>> Nitesh
>>
--=20
Regards
Nitesh


--f4QJr4T5d62WyAt2NEZJ9Bhrbh7HvhH7s--

--8V13K9q11cPOiDPproSx8qZXs1NSfkUuj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkXcoRVGaqvbHPuAGo4ZA3AYyozkFAlyCxNAACgkQo4ZA3AYy
ozl3oRAAia5Dz2avOmKr/a1Ev84UQjMmuObxBysvEemwv6N1ZTU+nlC7CXOk1jx5
Kk6dIaPn70vs8i4D6eZs0Uh/ocedS5bXgEUKvvxPaSyZzti4QaoG0SPUWqrbQzlr
5N6fhcaXmJsIkSNKhcMGdz7gOGXeOn7xjTICT60GAZFTECLVqY4Nh6HjAGtVCeUA
pzVydsO96pS4f7nE1+jOsAo18RIqpyrArzFHHQMVlD0STpJBGf4xoXJOWYz3D+MB
509GeqjptMe6kBAxK9ZLxFWgmvBvHKBzHnytKNLxfBHs7AuvdOzPooz6WbO5cWth
RhMb9ffIwkve7nDJGCAjK51aVoc+lajvCkzQNjFu1la+syCNihA1vAqShA4U9WSJ
TyFSYMpQ1ZoI0uJl4E2g6FxbQ/EqosMjvTmNG0QoP7zpyJ+aa8HSTbfkFSdQ6UxL
N08gXgdis1iq3q4u9N4zTL8Xzp2paF3jKpW9/NzRlR/DmPI9so30mnywT5cQcnDZ
XT3XLbhg+MxO2P3e9iDgozHDxptxYtf01KJIMJm+JFTFagQ8i1AMHVsswwg88pQc
h1xTfl1xMh+gehhxGf4gk5vJY8c7Raoq9/ZqiIdxY67xpwIy+zuGGagowvpXcBz/
kNNG4KeSUHPWBfGmb2GMg6/WhNY5RJ4deke8B/rWqRpx6dDHSSk=
=n2GA
-----END PGP SIGNATURE-----

--8V13K9q11cPOiDPproSx8qZXs1NSfkUuj--

