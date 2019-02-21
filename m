Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDBA3C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:25:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A73512083E
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:25:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A73512083E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34D538E00A6; Thu, 21 Feb 2019 13:25:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FD0E8E00A5; Thu, 21 Feb 2019 13:25:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 213058E00A6; Thu, 21 Feb 2019 13:25:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id E5AE08E00A5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 13:25:00 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id b187so5982389qkf.3
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:25:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version:sender;
        bh=wmfr8FacwMoJUV00LvUw0BsowycJx3sCnzcuQcWz/Lo=;
        b=K95ivi7S/wtHgAWxOTOoJI9Vd2dMM8IG+9fR6B+ou299cJPsyN46CjqxFQtR6lLfOe
         chGID7K7xtF/z0UkV9HlPuB85VsnOMXvJy0OcudaJen/9OuFG9n+Z3VwbnXlcOYIOS+d
         C3jb87zsgITnGp+KJyHEfmbpHjmiJij+HmfZqv9kQmJ6OykmxtszEmSQSjH0IcdygwjM
         gdAA8NWLsRI7feEN7Dt5KQp0L93V6N7XVyF4FkBUrVT6d45bPCzDXDywuCb8SvRnqCSD
         hKw36tsLxazcdzB/z0A7x40Hr9tkfhOvDCKew9Fpwm+mcjSt891G+DcXXj2DSIbOjdMR
         JEHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: AHQUAuYLhExzvvyDcR7PVk1mPL1XXe18ODZuyfzXjffGRskmkCDkBN9M
	VXuLUZhirQGMfUreAKb1WGSdKaSpeiodojLxpJqwCCT+3pnbtcfqUEQ4Su/7fIVYrOZ9gG27jtD
	+FlOY4wajDXS9s08ejhBHpOqrkafgqa67GPKfpF4+1+YM2Y0JIpU7eE7PbcxppP8A3g==
X-Received: by 2002:a0c:9848:: with SMTP id e8mr11390874qvd.80.1550773500733;
        Thu, 21 Feb 2019 10:25:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYqfRlJVxjWK7vl1eSuVxEviDcOWcs6K4cKsnQaHO1YQboE9m5g/8IjMtLzb/4KxT2jXnmg
X-Received: by 2002:a0c:9848:: with SMTP id e8mr11390847qvd.80.1550773500194;
        Thu, 21 Feb 2019 10:25:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550773500; cv=none;
        d=google.com; s=arc-20160816;
        b=Yz9p/pwp3b7Be9LBJZ0TzAtqpBuYu25fGNsgCjVPn9Zv3+YpQ71EFao1TM3QQnNt2v
         vrOxVz7JrUfmrA76/qJCYt/d3qrsINeVJ0SCgJCezi+tldsc3sZo387HYdaHoHYo5GGY
         3hsWY878EFqZLfnYQLGFq8hmiYvP1+dv3SjdUcHwdcq2alpxI7vMUO4ep46HwraAT929
         oiahqmjMYpl1BfDiDgBkd5ZA8hB+JO9tDmKpEjNZED8vKcQ8Tt9AzGlkCWB4t7WzMp5Y
         a2a9cIVVsDKFXib84gpxYhh8Ikt+ogRQdSJv6nhscR5PCqDY5sK87aHc1GNE5zzxfgdn
         awKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:references:in-reply-to:date:cc:to:from:subject
         :message-id;
        bh=wmfr8FacwMoJUV00LvUw0BsowycJx3sCnzcuQcWz/Lo=;
        b=1E64ESF0j0ydFV9vM4mK8BQCPl1VpWTxM62CyBy2cnCyCq80dpUDMJ1Jjsh1KNocBF
         B+omL+7pzO89oJpC6ogNPjYZ2Gnf57ymWpA/PrJQSygn+QoXmjjAyorA13Sqf5eaKOqK
         SrtuaB/H5RxnYFxxyzxOZWK7Yk0YiDsHmq2myNC6EhTr/4O7kfEx6wykD01VAZwORhix
         aLFWpyn6WQw6GYtcOVKvl3ykQpZU1QU0hdx7H4X5dI6g303Uz+dMGqMSggOnHRzbcyOT
         L/N66SLtteI69JPm+tqOQoQ2DCtjY+o83X5pf++ehNIStb2x3aqF/EsjC6/4mERBihbi
         SfMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id c32si251326qtc.169.2019.02.21.10.24.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 10:24:58 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.91)
	(envelope-from <riel@shelob.surriel.com>)
	id 1gwt1m-0001IZ-Ap; Thu, 21 Feb 2019 13:24:58 -0500
Message-ID: <3057d2336e88897309756a9c0e10727856589965.camel@surriel.com>
Subject: Re: [Lsf-pc] Memory management facing a 400Gpbs network link
From: Rik van Riel <riel@surriel.com>
To: Christopher Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org
Date: Thu, 21 Feb 2019 13:24:57 -0500
In-Reply-To: <010001691144c94b-c935fd1d-9c90-40a5-9763-2c05ef0df7f4-000000@email.amazonses.com>
References: 
	<01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@email.amazonses.com>
	 <20190219122609.GN4525@dhcp22.suse.cz>
	 <01000169062262ea-777bfd38-e0f9-4e9c-806f-1c64e507ea2c-000000@email.amazonses.com>
	 <20190219173622.GQ4525@dhcp22.suse.cz>
	 <0100016906fdc80b-4471de43-3f22-45ec-8f77-f2ff1b76d9fe-000000@email.amazonses.com>
	 <20190219191325.GS4525@dhcp22.suse.cz>
	 <0100016907829c4c-7593c8e2-1e01-4be4-8eec-a8aa3de00c18-000000@email.amazonses.com>
	 <20190220083157.GV4525@dhcp22.suse.cz>
	 <010001691144c94b-c935fd1d-9c90-40a5-9763-2c05ef0df7f4-000000@email.amazonses.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-cM7bD1nFXBXadBEnK7oO"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-cM7bD1nFXBXadBEnK7oO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2019-02-21 at 18:15 +0000, Christopher Lameter wrote:

> B) Provide fast memory in the NIC
>=20
>    Since the NIC is at capacity limits when it comes to pushing data
>    from the NIC into memory the obvious solution is to not go to main
>    memory but provide faster on NIC memory that can then be accessed
>    from the host as needed. Now the applications creates I/O
> bottlenecks
>    when accessing their data or they need to implement complicated
>    transfer mechanisms to retrieve and store data onto the NIC
> memory.

Don't Intel and AMD both have High Bandwidth Memory
available?

Is it possible to place your network buffer in HBM,
and process the data from there?

--=20
All Rights Reversed.

--=-cM7bD1nFXBXadBEnK7oO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlxu7PoACgkQznnekoTE
3oMKBwf/Vuaa+Er8IEtq9p3gu8N/rkg1G6f+4aqOD0vr1fEER4lEWBaB7hwI1pzg
Ho/EwTNhnR6/9d1NhFBDNld2VyLZA/7VMh5MCBT13U2VKKe8njReZLJGinpkNZKl
i4d0Uvv0AGD01MeuTv6LpEzxVthEsxJN2qtR9w0r+m3DggKTxe8riBwWM0dh6V7i
xpqAAZQ6PwFLgs+AKzSpy+wp82XDJsKwF5ZjkNrw7KNC9H2qwyP6NGC25OHFtSYk
EBD6KBirQVzYJTyuPAoVOUnjoioIO8lecq+OMLIr0g004yePCAU+nm4uJ3HFIjhN
fEPd0JiN3MK7j3a8n4AiG5r3i2UR7Q==
=33Hu
-----END PGP SIGNATURE-----

--=-cM7bD1nFXBXadBEnK7oO--

