Return-Path: <SRS0=SV65=O7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C200C43387
	for <linux-mm@archiver.kernel.org>; Sat, 22 Dec 2018 10:28:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C60A1219FE
	for <linux-mm@archiver.kernel.org>; Sat, 22 Dec 2018 10:28:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XJEd3/JR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C60A1219FE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 204758E0002; Sat, 22 Dec 2018 05:28:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B49E8E0001; Sat, 22 Dec 2018 05:28:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07D3D8E0002; Sat, 22 Dec 2018 05:28:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id D23B98E0001
	for <linux-mm@kvack.org>; Sat, 22 Dec 2018 05:28:28 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id x3so7853248itb.6
        for <linux-mm@kvack.org>; Sat, 22 Dec 2018 02:28:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=r8vBKEndYeU/DrOpU8FPkOtgVFGveNOgt2nB62lxSg4=;
        b=VrQZsA1tBmF32lKU7PEmQR/PT8d4kQr6NRE9+ah8wZp/Pn9aYDNvLZwiLgwAAhf33H
         BlhChpN4hteIE1rogpDZLoaEEYcznW74uM6v5HIrpujEc824spREtPiugZ2gfWJP39/x
         vg7VbYtP8HSrl1jySoEkMJHJOX4VcrsOA8ZHvMwG4lgh364M+zFb35brTrqyQWGwAUM9
         NmRNCT4TbX4CXTpks739m/PCH7ZXlZVSajPc6xDM6LUlfpb1fRY8YBsOPW2cAPw1RmSD
         JwHt3RM7t19+KXJDMQBQ1LLp5c9KwGQSUOGQt0hIPxYhOd1mWA/gxmCw+dShWeJGWlGd
         ZZlg==
X-Gm-Message-State: AA+aEWYJue6eZZ+3C7P3OtbgDlZx0p/+twoyAooWFru8YQ/5mL4f5NWr
	DX++YIkuvwAMZTYPEKTyLG2J+OerhAQxBAejS0DHf9pyLRj4Bk7cLeR4hVxSfLoBePXA3QLiiw7
	kB8OnU7RI2iZ7FA7O2hGAN+rQsBE/Y3qiON2A29qV0KCWPZJBXzjtMVbzNk5iZAUYM0GlWK/YQC
	9ljzcKT6voeKzt2ftY5/RMP3SfEtiYrfC3XdJOl/idkR2J/Q3B0KdjJU8cinLQLLUZ44zmNXBdO
	LqKiFpicboCWtOFKnCpvOIxmZBWjPbqT8eOqcX0b8OYtypm/aIiiGAqdRt0h8g8Ul7cm03XeOa8
	jdC2WYK01fm4NqSRoAjyUPMvDVlEbCG3nj3thgvbbSeqfFCCcek6QKGOuEW0QL4skcsf1X60Oyu
	l
X-Received: by 2002:a02:4511:: with SMTP id y17mr3748975jaa.56.1545474508525;
        Sat, 22 Dec 2018 02:28:28 -0800 (PST)
X-Received: by 2002:a02:4511:: with SMTP id y17mr3748948jaa.56.1545474507575;
        Sat, 22 Dec 2018 02:28:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545474507; cv=none;
        d=google.com; s=arc-20160816;
        b=kRwoKtMlGblbxGLA0YmXlOh0HPTPHAZalrnbUXOxrfEhAxHll6YmEHilF8hd4oZ3wO
         GX2/h6JLG3r85RV6307NztrY9gWfp9PwD6PEZp2Ow31eQTqZAbsVHGJgE6BxwnnW0VAV
         PTKx/4oyn6rv/gHg5bkPMV0gIYiliu1bHcbM8+s3NH7axANbyz22BjL/ZPJyGwwcvbZA
         JzZhvYQ1N0RHsFUebM8knuvycWUJvEZaAmeqxVkvprfSbYUgqekUhN3k9YphrtRxHSxT
         Nkdj1MvjNLSaIuCd9MXc7QPJLFoEh9V0dXimvXk0jRMpo+Q5ROV086PaFJWeLrrZf2oL
         A9Qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=r8vBKEndYeU/DrOpU8FPkOtgVFGveNOgt2nB62lxSg4=;
        b=yW6xdRiaPalgMUYf/ZXxohZFDdFaKxSMk/DNIdn09dv0sJpxwohI6imsvuX2K98wWW
         Rh4W2GcLTYUlT1/HYRZ0ZgJomI6zMYKNYtlWeWMVUWpTCP4tDg2kVnEDeJvU2quRTp+P
         JWDQPKJ/6/Y2FWeOBvnxSZaAyZTSJGEDu3DUfSsnJ+rEagef27ZAH1YCS8z2LPEVnDlP
         di0rEF9YqmzNd7+GJgPbPmkkj6te42wqjYeb/uxCr8scPeZ8VjHiVm9bxdze3MYU2KNV
         sR0KqnJSvjrbGQIv4nZrfUPsrsKcOzX2mHyJ96WKBG82OcmCa7+QBVJ0Mq9SGRXq11J8
         IZoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="XJEd3/JR";
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t195sor4803398iof.88.2018.12.22.02.28.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 22 Dec 2018 02:28:27 -0800 (PST)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="XJEd3/JR";
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=r8vBKEndYeU/DrOpU8FPkOtgVFGveNOgt2nB62lxSg4=;
        b=XJEd3/JRYKcpsfaFCMhjf+c/InJKM0a/MTV1PNyAg+VtvktrShefknEWl8JPWIRaqw
         GWksZniiyTX63lhdE2b5yjP5FTLozkk3mSf7oQNz1YDTQtOhguQxKWiRflEKwJGJ0wsb
         ULMuU9FA5eYXlNGlDSQkXw9wlCEV2J8hqrLh48T6L/JMaeqf4moc6ltSYvclARbLQxBd
         3fjKwDNZJJdDJmwTeC6kfhNkX/S7Y92+Sk6p/H5gXMrJHJbJt1aZN+KXDJHy6DMleVIF
         GJPX+c8z9v0rViGbELJW3nJ3PNmRPyKZqUJZhbXDykGVFiucXLLCRUirQ4Q2mP+5pksR
         Nhgw==
X-Google-Smtp-Source: ALg8bN7e4exUvOevPcYnaF5H32xvUF7ZRhL2MFzq9Kpfbis4X+Oam48Guock+97CY/dMFm69fwlyQ0j0hFLUZZKr8gw=
X-Received: by 2002:a6b:c892:: with SMTP id y140mr3760449iof.192.1545474506776;
 Sat, 22 Dec 2018 02:28:26 -0800 (PST)
MIME-Version: 1.0
References: <CABXGCsPu3g8WZXV1RpggLFuL3bgofmXMs1SiPyYnPyEOW7t3Dg@mail.gmail.com>
 <CABXGCsMPjKnCb7hpuenL5q3_HJgoGW=VB9FRrBpJsZMtA7LxpA@mail.gmail.com>
 <3ffe451b-1f17-23a5-985b-28d26fbaf7da@amd.com> <09781f6e-5ea3-ccfd-1aa2-79941b089863@amd.com>
 <CABXGCsPE36vkeycDQFhhsSQ0KhVxX4W=6Q5vt=hVzhZo3dZGWA@mail.gmail.com>
 <d40c59b2-fa8f-2687-e650-01a0c63b90a5@amd.com> <C97D2E5E-24AB-4B28-B7D3-BF561E4FF3D6@amd.com>
 <CABXGCsP9O8p1_hC31faCYkUOnHZp_i=mWuP5_F9v-KPxeOMsdQ@mail.gmail.com>
 <CABXGCsMygWFqnkaZbpLEBd9aBkk9=-fRnDMNOnkRfPZaeheoCg@mail.gmail.com>
 <9b87556e-ed4d-6ec0-2f98-a08469b7f35e@amd.com> <CABXGCsMbP8W28NTx_y3viiN=3deiEVkLw0_HBFZa1Qt_8MUVjg@mail.gmail.com>
 <b3aba7f4-b131-64fe-88eb-c1e14e133c51@amd.com> <CABXGCsMJs6X+bK7NS+wPn94H3skcR5a-U9710rSByvn26vg7Gg@mail.gmail.com>
 <4a3060aa-2bc7-9845-0135-ddf27e90740e@amd.com> <fbdd541c-ce31-9fe0-f1ac-bb9c51bb6526@amd.com>
 <96c70496-ce62-b162-187c-ff34ebb84ec2@amd.com> <CABXGCsORwHuOuFT273hTZSkC4tChUC_Mbj8gte2htTR2V0s79Q@mail.gmail.com>
 <5a413fa2-c3a4-d603-2069-fd27b22062cc@amd.com>
In-Reply-To: <5a413fa2-c3a4-d603-2069-fd27b22062cc@amd.com>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Sat, 22 Dec 2018 15:28:18 +0500
Message-ID:
 <CABXGCsNoqtH0muS6JMHvSPtePam=C+CE=MOqDGhYQCSSieyXGA@mail.gmail.com>
Subject: Re: After Vega 56/64 GPU hang I unable reboot system
To: "StDenis, Tom" <Tom.StDenis@amd.com>
Cc: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>, "Wentland, Harry" <Harry.Wentland@amd.com>, 
	"Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181222102818.7GjWZtE0_oBK-7fRdpV4RigOPtpSsRpZZSoETkOWn2M@z>

On Thu, 20 Dec 2018 at 21:20, StDenis, Tom <Tom.StDenis@amd.com> wrote:
>
> Sorry I didn't mean to be dismissive.  It's just not a bug in umr though.
>
> On Fedora I can access those files as root just fine:
>
> tom@fx8:~$ sudo bash
> [sudo] password for tom:
> root@fx8:/home/tom# cd /sys/kernel/debug/dri/0
> root@fx8:/sys/kernel/debug/dri/0# xxd -e amdgpu_gca_config
> 00000000: 00000003 00000001 00000004 0000000b  ................
> 00000010: 00000001 00000002 00000004 00000100  ................
> 00000020: 00000020 00000008 00000020 00000100   ....... .......
> 00000030: 00000030 000004c0 00000000 00000003  0...............
> 00000040: 00000000 00000000 00000000 00000000  ................
> 00000050: 00000000 00000000 24000042 00000002  ........B..$....
> 00000060: 00000001 00004100 017f9fcf 0000008e  .....A..........
> 00000070: 00000001 000015dd 000000c6 0000d000  ................
> 00000080: 00001458                             X...
> root@fx8:/sys/kernel/debug/dri/0#
>
> There must be some sort of ACL or something going on here.
>
> Tom
>

Tom, which Fedora version do you tried and with which kernel?
I am tried several kernels from old 4.19-rc2 to fresh 4.20-rc7 and
every time when I tried run `# cat
/sys/kernel/debug/dri/0/amdgpu_gca_config` I got message that
"Operation not permitted".
I try understand difference with our setups. If you use default kernel
it means that kernel options between our setups are same. Difference
only in hardware and mounted file systems.

P.S. I am also tried ask how to manage ACL in debugfs in
platform-driver-x86 mail list, but no one answer.

--
Best Regards,
Mike Gavrilov.

