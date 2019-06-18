Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14C52C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:17:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB55220873
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 12:17:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB55220873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 749716B0003; Tue, 18 Jun 2019 08:17:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F8F58E0002; Tue, 18 Jun 2019 08:17:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60EC98E0001; Tue, 18 Jun 2019 08:17:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B7706B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 08:17:27 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id n1so7698770plk.11
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 05:17:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version
         :content-transfer-encoding;
        bh=tnjzGnwe6QgwQjMSV8tVdjPgpnluZItAB104RoUOl60=;
        b=BDEk0IkWskeJbhfevVQsy+Hcl+GYBDodYu56ibo3WMdvL4+SGD07SluZydoC8XL7BU
         MZPlQuTyIlQ5oR4E8aurQbo8oO6HR2KgR6uqgkLx7uiPq/zCi94AoR3MzC3CE/GncpOc
         3J8Bp2Nf2l/LnFYFoyCnQvAPtBzg1qzRAu8vXbA4V/xYaN5Fu9BlafLI+Ul0koxOkNcp
         AUZ/o2OvrbPvT9fTnqlq+aySDPqy+CruHl+XVQjwuy8ZbXhvf3XmBML2uDH9ZCA/YCqO
         FWt2SAeqyeW2G4QqDAWpw1CEM0kLCM+Dorr4Z1k+f9XcNQrBsyUnofavOdyCA5a2+Px9
         8Ocw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: APjAAAWTqBKrDhvNkq1kbL82wM2nT+QCofZ9IUXRZO6w65LlpJOpdLwE
	8Mo6ladeoOynZpoykzl3+ugAPBjgdul5RDhx+m3l+bEt9SagREmvlU+DGKO+uZIvArF+LiAQhgp
	kXIisXmvaaDrm5LxvwP3+bsp+b3pIjNfuVOd+VPAJvSPI8u6IjngxKsuEL0hjB2g=
X-Received: by 2002:a62:1bd1:: with SMTP id b200mr94341560pfb.210.1560860246697;
        Tue, 18 Jun 2019 05:17:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlhHmgwlLUCKQPeoK/MQ66kEGQWGm2S1i/X4X+Y9on4m/CLiH/fdYbeSJuzi0wPrhdPRrh
X-Received: by 2002:a62:1bd1:: with SMTP id b200mr94341495pfb.210.1560860245986;
        Tue, 18 Jun 2019 05:17:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560860245; cv=none;
        d=google.com; s=arc-20160816;
        b=yKdJKqzgW51ohxNElLbANJiODR7Vfkl8c10WkseHEn/8CqX6o824Wzv9EZXjfA1JBL
         cnOkT3T3CBTYnBjE1hoEqPP2zpb6g+BlMIsH7S04YBetv7/8SbScZ5WA5C2nvM3Ydy7W
         YMtcdAVlzCaYgOBLV7AXoQlSOpKMK2dNeGQgbkdpBaPxLKFsAZYSKbEtbLSV+MdhSNGQ
         fK5HrUuQR5aBZuKe0mleI6VojjVlhsfWUCRiOoL+LazCWAkAZwfM+bitoXBWogobHf4d
         S95WaoRo3lxZy/UA2kpUOItCz426s7qY3wfUKuAYUU8cffGvj0qqcsZSwKmNi/s4Kixc
         AoqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:references
         :in-reply-to:subject:cc:to:from;
        bh=tnjzGnwe6QgwQjMSV8tVdjPgpnluZItAB104RoUOl60=;
        b=zzUU2d0cQq91BQd0HvfZQVZLUXnnlm1AEl96pMGkga0Za6y5wbjlArKCY6nBq2l4/T
         bFW0qo7NsO8v+IrkhBpeX29gzV4RR78C/4h3R69ANlibyaqKXjHnhmIn75l/aGVc6p4N
         f87ng4d4BxXRp3OpboXXzYYhwU0sboWGLwUA9oZeh2uPILecIV2PGQo3ex/3Cy0F8S84
         PLIYdo//fpiWY+93EokXziGYdSz4TqCCceMMVYfhFPYmCV9Ehdv9EpNR7x9g/WGPh+BS
         /fP5JnHS2WiqXR+VUtZuCnMrnYZuwFbYQilNukqx+p0vswSi5SFXnJWIZlCbTM9i/6LB
         K+7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id f17si71269pgv.338.2019.06.18.05.17.25
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 18 Jun 2019 05:17:25 -0700 (PDT)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45SnC6001Qz9s3l;
	Tue, 18 Jun 2019 22:17:21 +1000 (AEST)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Andrew Morton <akpm@linux-foundation.org>, Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-acpi@vger.kernel.org, Baoquan He <bhe@redhat.com>, David Hildenbrand <david@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, Arun KS <arunks@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Dan Williams <dan.j.williams@intel.com>, linuxppc-dev@lists.ozlabs.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v1 1/6] mm: Section numbers use the type "unsigned long"
In-Reply-To: <20190617185757.b57402b465caff0cf6f85320@linux-foundation.org>
References: <20190614100114.311-1-david@redhat.com> <20190614100114.311-2-david@redhat.com> <20190614120036.00ae392e3f210e7bc9ec6960@linux-foundation.org> <701e8feb-cbf8-04c1-758c-046da9394ac1@c-s.fr> <20190617185757.b57402b465caff0cf6f85320@linux-foundation.org>
Date: Tue, 18 Jun 2019 22:17:19 +1000
Message-ID: <87pnnbozow.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@linux-foundation.org> writes:
> On Sat, 15 Jun 2019 10:06:54 +0200 Christophe Leroy <christophe.leroy@c-s=
.fr> wrote:
>> Le 14/06/2019 =C3=A0 21:00, Andrew Morton a =C3=A9crit=C2=A0:
>> > On Fri, 14 Jun 2019 12:01:09 +0200 David Hildenbrand <david@redhat.com=
> wrote:
>> >=20
>> >> We are using a mixture of "int" and "unsigned long". Let's make this
>> >> consistent by using "unsigned long" everywhere. We'll do the same with
>> >> memory block ids next.
>> >>
>> >> ...
>> >>
>> >> -	int i, ret, section_count =3D 0;
>> >> +	unsigned long i;
>> >>
>> >> ...
>> >>
>> >> -	unsigned int i;
>> >> +	unsigned long i;
>> >=20
>> > Maybe I did too much fortran back in the day, but I think the
>> > expectation is that a variable called "i" has type "int".
...
>> Codying style says the following, which makes full sense in my opinion:
>>=20
>> LOCAL variable names should be short, and to the point.  If you have
>> some random integer loop counter, it should probably be called ``i``.
>> Calling it ``loop_counter`` is non-productive, if there is no chance of =
it
>> being mis-understood.
>
> Well.  It did say "integer".  Calling an unsigned long `i' is flat out
> misleading.

I always thought `i` was for loop `index` not `integer`.

But I've never written any Fortran :)

cheers

