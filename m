Return-Path: <SRS0=vBJc=RG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9FEFC10F00
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 22:37:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7520720842
	for <linux-mm@archiver.kernel.org>; Sun,  3 Mar 2019 22:37:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Jjh466tN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7520720842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A79F8E0003; Sun,  3 Mar 2019 17:37:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07E538E0001; Sun,  3 Mar 2019 17:37:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB0228E0003; Sun,  3 Mar 2019 17:37:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id BFA5A8E0001
	for <linux-mm@kvack.org>; Sun,  3 Mar 2019 17:37:54 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id i21so5873664ywe.15
        for <linux-mm@kvack.org>; Sun, 03 Mar 2019 14:37:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=YtliewqCkw6AvjhQ1RBNtPdsYc4lcHNCvdnJ8EtyJKA=;
        b=K23TYDAR9xg7Jq07JBiesmK4HEbqANah5gkRzkGp5EIe7rLG8AAdrnDjXvKulYERhP
         oc0d6YEGRd+UCGCEQ4GsgxSVHII1VWOWgdlJrHImEHJadOHHL1Cu+j46imc0dYT6vhOv
         ima4uWaodqy13Kj11tNNvuNyPBUsXgqCFpCDImz3KuhQDwVj8YA3Im0eA2/ftk9C4X8A
         dw3vRQafuGyaYbUyerrcK7pSzIJ2SOIiUHJkWz3AF9NwD0I/F6Jde1F+RIgOxDbIyPYA
         Y8SIIbLxvjVXYItw8eNMZnI697N7K4jCzE+OU3PkAK8XO2qw4ZK16wK9Z7lcVAwuiuJM
         dYaA==
X-Gm-Message-State: APjAAAUNQy0UyiBe6QyzPfoFxMRENdohCyw4KempZIvWModEt1mkXt5G
	A8WRqXwSoQNpHL+N9bDK4XVGiw+5Ir8fyx9/ujGwl2O6eXVezacJznKZZYF1tpZJNeYxb5tmDQs
	wpkbVjzc8udiTn9fn95ChOBilQ4WuVAfssopnbrT55D1O+FaBLkGXgUEjdnCyjJPTrg==
X-Received: by 2002:a81:5211:: with SMTP id g17mr12297289ywb.346.1551652674503;
        Sun, 03 Mar 2019 14:37:54 -0800 (PST)
X-Google-Smtp-Source: APXvYqzBABl4Q91KQ/jzUbgaP2Ftq2BXqKcK/V20qvM6413KqbLAhGfeiCCZ5hujQU/1A/J0aVv1
X-Received: by 2002:a81:5211:: with SMTP id g17mr12297266ywb.346.1551652673645;
        Sun, 03 Mar 2019 14:37:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551652673; cv=none;
        d=google.com; s=arc-20160816;
        b=g3WPRjwKGm4XFaiMDRla1dzyE/e9zOgwIexYv0h79Z8bPeE+pc1ydJrgRyru6ZNru2
         VKEz09z7sC5UihnEB4BpMfp7aptXnB7WgguFZ2KQC5y9rlFoyeO+N7wKJa1axq+f6cyu
         F6AiFd9nMJJeYNP/DuhLorNxzu1TYMjtEMVOPJhIZY7RVN2VGN/xTICJzObAZ78mIkT2
         Q8W7XYyWhsnAzBg63EqxOqtdKPDYLiL6AjAEvSeu6QWpYOuPmJPjXgXk3lbzCio8HgJD
         lSSyvpqdwfX9fqg/OxIuz/HrL8rNJjZkr8bnKOu1yYT3qelF57JIocHBQ9xrrbRGsd4M
         dNIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=YtliewqCkw6AvjhQ1RBNtPdsYc4lcHNCvdnJ8EtyJKA=;
        b=Vcc9YO4rFJK/Fvv0DCcmIhNWTqNJsohl9lSbWFzVbM75LSpyFkal+wZvOTirJlf1Q8
         5UF6mNhwy3Sdh5pGE8wRT9RS4bLvfxQ7iZuh2bDhVMUsSyy+MUojoYu3+TwbrStKrrwK
         zwEZ8bvpqzyxJCZSqQvBGd298+IybZorXSAmPHt5CsmxgPcdEbyT5alDBZfhxsjtc5S7
         g5iSVvNwKKOyjz6y4IxRVAm8PAaAkm2bsQ4pFzefry/pAa23gU1Q7pYvBn47+7RK0uD2
         Wmluc7AcqYx2/6LB6jgKbPxa0CoKXum+0WGJ+jg9Kbl400S8tFeg4yyCvYsZlIoJCaYT
         3ELQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Jjh466tN;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id y2si2341353ybc.493.2019.03.03.14.37.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Mar 2019 14:37:53 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Jjh466tN;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c7c573f0000>; Sun, 03 Mar 2019 14:37:51 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Sun, 03 Mar 2019 14:37:52 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Sun, 03 Mar 2019 14:37:52 -0800
Received: from [10.2.174.18] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Sun, 3 Mar
 2019 22:37:51 +0000
Subject: Re: [PATCH v2] RDMA/umem: minor bug fix and cleanup in error handling
 paths
To: Artemy Kovalyov <artemyko@mellanox.com>, Ira Weiny <ira.weiny@intel.com>,
	"john.hubbard@gmail.com" <john.hubbard@gmail.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton
	<akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Jason
 Gunthorpe <jgg@ziepe.ca>, Doug Ledford <dledford@redhat.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
References: <20190302032726.11769-2-jhubbard@nvidia.com>
 <20190302202435.31889-1-jhubbard@nvidia.com>
 <20190302194402.GA24732@iweiny-DESK2.sc.intel.com>
 <2404c962-8f6d-1f6d-0055-eb82864ca7fc@mellanox.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <332021c5-ab72-d54f-85c8-b2b12b76daed@nvidia.com>
Date: Sun, 3 Mar 2019 14:37:33 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <2404c962-8f6d-1f6d-0055-eb82864ca7fc@mellanox.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1551652671; bh=YtliewqCkw6AvjhQ1RBNtPdsYc4lcHNCvdnJ8EtyJKA=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Jjh466tNs7neALILTrnqqdaBg5r2amMZAGGz5F57Zctna8B1vRhkkkQTlhtSKXWSH
	 jUvt0AagFbvshV/+2Wc9KckWRtA1ZgwYm2izIIjnuDYBmJH3/U4jQuH7K533MOktV/
	 Q1RlPM6jiwXv0UGWH5l57pPjR7DqQ73prR0D6xvfkiqt8N6VSYxehysA/sHYYOZ8R/
	 fFTjXxTRPGke6l7FrUsDE5u8LKqBRM9RVVYqLJX9/Ro2liCZnTTOOiU998/8xlbZDA
	 I9PpKpIccA1zCvsQbkO0wkGnzgIxv3f+W6C3D5jdn86wxddLCz/kt7gsTARrffRlbV
	 8Px7sha/qYW4A==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/3/19 1:52 AM, Artemy Kovalyov wrote:
>=20
>=20
> On 02/03/2019 21:44, Ira Weiny wrote:
>>
>> On Sat, Mar 02, 2019 at 12:24:35PM -0800, john.hubbard@gmail.com wrote:
>>> From: John Hubbard <jhubbard@nvidia.com>
>>>
>>> ...
>>> 3. Dead code removal: the check for (user_virt & ~page_mask)
>>> is checking for a condition that can never happen,
>>> because earlier:
>>>
>>> =C2=A0=C2=A0=C2=A0=C2=A0 user_virt =3D user_virt & page_mask;
>>>
>>> ...so, remove that entire phrase.
>>>
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 bcnt -=3D min_t(=
size_t, npages << PAGE_SHIFT, bcnt);
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 mutex_lock(&umem=
_odp->umem_mutex);
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 for (j =3D 0; j =
< npages; j++, user_virt +=3D PAGE_SIZE) {
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if =
(user_virt & ~page_mask) {
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 p +=3D PAGE_SIZE;
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 if (page_to_phys(local_page_list[j]) !=3D p) {
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ret =3D -EFAULT;
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 break;
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 }
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 put_page(local_page_list[j]);
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0 continue;
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }
>>> -
>>
>> I think this is trying to account for compound pages. (ie page_mask coul=
d
>> represent more than PAGE_SIZE which is what user_virt is being incriment=
ed by.)
>> But putting the page in that case seems to be the wrong thing to do?
>>
>> Yes this was added by Artemy[1] now cc'ed.
>=20
> Right, this is for huge pages, please keep it.
> put_page() needed to decrement refcount of the head page.
>=20

OK, thanks for explaining! Artemy, while you're here, any thoughts about th=
e
release_pages, and the change of the starting point, from the other part of=
 the=20
patch:

@@ -684,9 +677,11 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *umem=
_odp,=20
u64 user_virt,
	mutex_unlock(&umem_odp->umem_mutex);

  		if (ret < 0) {
-			/* Release left over pages when handling errors. */
-			for (++j; j < npages; ++j)
-				put_page(local_page_list[j]);
+			/*
+			 * Release pages, starting at the the first page
+			 * that experienced an error.
+			 */
+			release_pages(&local_page_list[j], npages - j);
  			break;
  		}
  	}

?

thanks,
--=20
John Hubbard
NVIDIA

