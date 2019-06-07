Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD42FC468BC
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 12:04:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A52D52089E
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 12:04:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="shBn+/bZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A52D52089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FCBE6B0007; Fri,  7 Jun 2019 08:04:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AD5C6B000C; Fri,  7 Jun 2019 08:04:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29CAB6B0269; Fri,  7 Jun 2019 08:04:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED0E56B0007
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 08:04:23 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d7so1285810pgc.8
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 05:04:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=7J7o7uQ9LJadOWTjygndomDcwWjz9mufJXpnzLuwVGc=;
        b=QxHQdfz4gQCNjxrIvDJH3m5C7zy9UISeyJmLMfmJaInMQclCAlr5SDDB/ARZNj2tJU
         OGjYYlAWQl0gP600GyqI2BBCbS9/+ApclZL+n2NUeolGxKRKhx4e3XNW/cDikKWoAH+M
         YllxMTe5Nb05LAJAGEBSA4k+qXRNCe2a4gVXLlT7U7M3qd8VKoGKI+baDqo1CpU0IjM9
         Y2YdxqnrDUBH4aaWfrYplTwhud4wwsedOqS6YfdbP70vIGu4jCCkp9KfWUsyqwab7AwN
         Onh3elLBOaYeehcb8Z/X8et+SmmeW8ju8W0DO+5PA9NNQ/veS10MvqB5SXcuuVYGzjGA
         1qEg==
X-Gm-Message-State: APjAAAXskSQwzlOup3JVloG1pfZv2sZnqmidtwG6KUU7pX1ock3q88S6
	+/fUGatFHc2jNx58WNpVp6RTBTBbQD1G94Qzxs3MJxDHBKs3n3GprYTNhYylAclADShjSCQNU/D
	5JgYeoXWdR64cvusY0dVag2LoNjMF2FDOLeh3daYtKi7Yzihgay3i5GUAE2ByUwVzcA==
X-Received: by 2002:a63:af44:: with SMTP id s4mr2343329pgo.411.1559909063489;
        Fri, 07 Jun 2019 05:04:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/5W8wl48PpJRD4I6gbgJUfTWFNJ5zWAnc1Q21GuJj6rsL2aVk29jJZZkac9lAaYiV7dQf
X-Received: by 2002:a63:af44:: with SMTP id s4mr2343277pgo.411.1559909062669;
        Fri, 07 Jun 2019 05:04:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559909062; cv=none;
        d=google.com; s=arc-20160816;
        b=zXnQaUwjuuDKC5ew7nP3DGb205if07db9Uv1tHuin3ZmvJvPbSvb/mhnNInLR/0ZxY
         B1Xy8wM3jdx206symnGMgStaclJ1TbviZnfipm976M7iAPP3FvRQYkNlfv4XHXeLaCmh
         U++IdR5F15dVu/BVMchfdwJKjBHTXFsTZlgIop48xpGaaAVIQb/JypxIVlkfFm18XH1U
         QK4RadBzW/Y0vwSuQvsi/3ij4CyM/AFF6BA8Rpj7XQqLNPTk88wy0fQpnSqUYt1Ky50p
         /JC7rDAEQtpcgbTwBTrKaHT15dLVgKsDqoihrzSrL4GgQG14bdYXHqrD6rLn0QxKnTVI
         9uyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=7J7o7uQ9LJadOWTjygndomDcwWjz9mufJXpnzLuwVGc=;
        b=Ydvq8HGKKtQf0OWvPVKqgYzldHipz42xhkZzCAIE3E6LBXw/bhBg5HtqJ/UORNVdfg
         7PofEWwkTjxIGAoSqDtKISJwjnixlsUM58JhFPex9/ZVAecGEgVIvWVgaqz5v0cSSDwR
         LUQVoth3nJnrjDcdoSRDE50hEqEtozQyJLgusWSCOEBDBu7tiTtOBzocNS6ZtHRIQAQ5
         GMWHJng8MqkYPDnCwwGQCYe/9ah8CzckffDxx61QEiXCnulbgJhDt5jLU0gp9LQ6KWYK
         4CjFZlwDPWlj48PEW3puJS32XOmXqelrjHat+lmwLX1mqd+s7xrnPdnSQdF3HXDjW3ml
         h9Ug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b="shBn+/bZ";
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id cj13si1666643plb.162.2019.06.07.05.04.21
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 07 Jun 2019 05:04:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b="shBn+/bZ";
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45L1Qt4FFfz9sNd;
	Fri,  7 Jun 2019 22:04:06 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1559909057;
	bh=SVse233ZP/gfWiwAkphdAiPtrWGA02EH5CK05uTxdco=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=shBn+/bZp4+i7ILKYT0rkicAc6qcmmQP1VlZ3saK03LKB9zc/NDFJ5cjhXqlEHyPz
	 2nllWsT+DJ6D5zDFTOmqEnjXbNpqikUY4YWSMMSeJwu5ucFQSEtL4eZUc6HVdKK4TE
	 qeoWLj3UUE4M9QEUmDXWh2ARrdai0SPhHQww77UvDoWOKjYJt4Bb67lNhTHgNKLPBy
	 6p7Lz1Bv/DqsVATPnHpr/EbevipmxUHrPDNyWaHhD6m4citn/ZVKw/Yu0UerC8T4Bm
	 d5uAfepi6bZG8PmazXKqBSrkpabcAFZqyXErnjGLWQxR8X21ypmE9ZV6+vmRkEQUdV
	 qL0IogG/ZPB0Q==
Date: Fri, 7 Jun 2019 22:03:26 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Matthew Wilcox <willy@infradead.org>, Mark Rutland <mark.rutland@arm.com>,
 Christophe Leroy <christophe.leroy@c-s.fr>, Andrey Konovalov
 <andreyknvl@google.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul
 Mackerras <paulus@samba.org>, Russell King <linux@armlinux.org.uk>, Catalin
 Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Tony
 Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Martin
 Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens
 <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>,
 "David S. Miller" <davem@davemloft.net>, Thomas Gleixner
 <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar
 <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, Dave Hansen
 <dave.hansen@linux.intel.com>
Subject: Re: [RFC V3] mm: Generalize and rename notify_page_fault() as
 kprobe_page_fault()
Message-ID: <20190607220326.1e21fc9c@canb.auug.org.au>
In-Reply-To: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
References: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/f4dkIceQ5ZrfVlbLmfAkblH"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/f4dkIceQ5ZrfVlbLmfAkblH
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Anshuman,

On Fri,  7 Jun 2019 16:04:15 +0530 Anshuman Khandual <anshuman.khandual@arm=
.com> wrote:
>
> +static nokprobe_inline bool kprobe_page_fault(struct pt_regs *regs,
> +					      unsigned int trap)
> +{
> +	int ret =3D 0;
> +
> +	/*
> +	 * To be potentially processing a kprobe fault and to be allowed
> +	 * to call kprobe_running(), we have to be non-preemptible.
> +	 */
> +	if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
> +		if (kprobe_running() && kprobe_fault_handler(regs, trap))
> +			ret =3D 1;
> +	}
> +	return ret;
> +}

Since this is now declared as "bool" (thanks for that), you should make
"ret" be bool and use true and false;

--=20
Cheers,
Stephen Rothwell

--Sig_/f4dkIceQ5ZrfVlbLmfAkblH
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlz6Uo4ACgkQAVBC80lX
0GwAlwgAndGNjcRg/+OZtSy1kiUIeIc3sDi7Ok5AjcBz7eTGTC6rACK7/CqF74Ff
Hw76yMUeoSjtJWLlhqmY0XI4ib30yQJSvSSWJyDvZpmgkDbNO69BK4rT4CO/d2YX
sCodILuUU462hNmmfr9N6uWJGSeDWdEvbfitkR2PEzQAUSsQacEA8UB+bqf+zQ13
xwBTJEE0YFg5UCqOcsE3bSTh/e+p7djYHrQIiZX0ntJOra+nJZuz/GfJQUmx4WYn
AHgcP+Marnv0/MW4JDWYDtetq+Fmr96wk01Ex4gMytm7TcpL0asnQ0IEVwljvVr/
HFKp+ZJLlwZP8lyt90zY76EEDgViPQ==
=7Lk0
-----END PGP SIGNATURE-----

--Sig_/f4dkIceQ5ZrfVlbLmfAkblH--

