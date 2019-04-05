Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DF23C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 11:08:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDF99206B7
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 11:08:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YjQQyc0v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDF99206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 77DD96B000E; Fri,  5 Apr 2019 07:08:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 703AD6B0266; Fri,  5 Apr 2019 07:08:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F2096B0269; Fri,  5 Apr 2019 07:08:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 36AE76B000E
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 07:08:13 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id 62so2385067vkx.16
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 04:08:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to;
        bh=aNIE+vTdHVNNwkQKeXlvGCPDjyzvwN94yT8EdXPvcDk=;
        b=cJWvaVo9N60Ila8Y06lwd1gseHe9OQlHnGnQ0D8omp1XyMq0DpFyR69UKLskQU4p1I
         we/Nfe3mJch1zcpQnK0dS2OGNPPQs2twhAKZyFrzMt2CfTO52tUmxT20gnaeAjyks+VP
         itDHdrR6l/yVU4j3vMvDjugHsfIJjwBoRUOszKvI9Y7gQ7SVqzcPEKuBoDmGuTxkkMKd
         TSf1e7CSEuDYJGR5pZ1ABXkD6xwuEK0Suwhoqcv0ok+PY1j3ptO97gs+MCxMuWDBROfp
         NdX/Nc2m/sSLN9LijyzleYlM09W3aFXtjXtNynOSXYgtYodGKAT3pyWdX++eWGLqaacl
         NiDw==
X-Gm-Message-State: APjAAAVBAKD9r6frJhSbQ0Ovs3ThofsWQEJgW8tlkHB+sU9ZqjRa3Tt8
	dqjNPLHixzDGzvtB4iwPxCvuxUwuJb1uxHxvGWxSHy24gVt7tNAJ+c4w7C5CBWA5uwbAuv3SPEC
	q9iNSxKnWh1sLFRSBSxXRQELVmPmb+kNktZe8HVmthVh9B0LYtsPBDwoBMUrD2Iv7Cg==
X-Received: by 2002:a1f:32c7:: with SMTP id y190mr7604096vky.15.1554462492873;
        Fri, 05 Apr 2019 04:08:12 -0700 (PDT)
X-Received: by 2002:a1f:32c7:: with SMTP id y190mr7604038vky.15.1554462492024;
        Fri, 05 Apr 2019 04:08:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554462492; cv=none;
        d=google.com; s=arc-20160816;
        b=F3f+WU72UXVUNBpwJtEICODTuHs8Z2eltMq/Zszl+9b7SAS2bBquvMytaJ8eRxor5D
         er9eLGcXaszBvtzS6EclfsvgkvlIUNsWD8SP0rqkS9PZ1XSv8ooOnGrQlLjmJOdybZpO
         tBIid9j2zcKuKATZZ4EDuQBAxKL+ezdYOsP5CmvVyqQ5lWR8Tj25bfSeQTF+czuy+e/N
         h6KInhGZnWSx6QoA7Zb2SU7fJhiAhAB6YxZHv1Dc4sB//ulIKYOV2slPPLOPxol9n54a
         DOMeyoJSIedwAdMNvYTscF3OZ0chFotNj6a+KnIECGET8jejZDoGb07T+eziSn5Z/TSx
         EpfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=aNIE+vTdHVNNwkQKeXlvGCPDjyzvwN94yT8EdXPvcDk=;
        b=FtlF8RJLVuOH4pcCqgC2C2FjV1r6sgiJK38pC337wu4otIejHlOKAxBA85RtkOBWzh
         ouJ57bNJxtt6q+T6VZf5usiM1EFoe+UPEb6OBs+lLyHXCuOXZQdU4XOXxrQGcNUDDXwf
         0HOikRo43vY0VASOcIDU50o5pyAT49E/2Az96svBSlBp41e/jAU4M1zzMCRZx5kXsPiC
         oxS2qiP6gX28+1yvsnT9FXm2+n3HfX2FQTf5OkqdfvCdNyzK/u/NuR4kWMxV3wV4HMHe
         fHpxVlP+GbJ89sZ5bBy3aVyLRyS9R/B2ldOVsy657XWyciT2mMuN7Txv0XW8r7uDhaOq
         7lBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YjQQyc0v;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g12sor13156594uak.39.2019.04.05.04.08.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Apr 2019 04:08:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=YjQQyc0v;
       spf=pass (google.com: domain of pankajssuryawanshi@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pankajssuryawanshi@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to;
        bh=aNIE+vTdHVNNwkQKeXlvGCPDjyzvwN94yT8EdXPvcDk=;
        b=YjQQyc0vH/iTzn9q9KH4Ho6nf2qoWGMMi7Oj2okeFUJ1uJU3WSghTMeMC7CRaOajTa
         7HT+R8WaKGJzCUNszqG7rfPNhZ/Dki5wuVbxn9GknapEo5DZZzbKbAUzdR2GVhlWTcaj
         K5kPoEj3SKg0Is52+CEvjWY5KJRvYoLgg4d3eujSMNBRTIG0ma2UBxJSyyq/d8xlv6Jm
         3lTJ507s1T7/YwOBGjqPN51jw6wkk1nF713OeiwkKuRAqvDQvfExbdzGe3N/nInJAOEa
         wbbPu7qIN3FVJJjr4oqzt0H6jrI5Lw6LGYy3jNdA66P/IZIIMxHKzKXyTyuuO1Yc/0Q1
         P7sQ==
X-Google-Smtp-Source: APXvYqwaiwZeI5Pbozfipwhzg/uzyeylVwqaQSeQvDHIXpBJrPCNsye7bbu9JkawWF9KOTKx27Fgghj9VCBsQ1CAONE=
X-Received: by 2002:ab0:3419:: with SMTP id z25mr7274184uap.102.1554462491569;
 Fri, 05 Apr 2019 04:08:11 -0700 (PDT)
MIME-Version: 1.0
From: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>
Date: Fri, 5 Apr 2019 16:37:58 +0530
Message-ID: <CACDBo56p2=Gh=dLENGukKz4zHq31v0pAdNHweNy+XJWkKi4CnA@mail.gmail.com>
Subject: How to calculate page address to PFN
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	kernelnewbies@kernelnewbies.org
Content-Type: multipart/alternative; boundary="000000000000a074ac0585c680c7"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000a074ac0585c680c7
Content-Type: text/plain; charset="UTF-8"

Hello,

I have PFN of all processes in user space, how to calculate page address to
PFN.

eg .

page address :bf05febc in kernel space.


I have PFN no for user space processes as below.

8a81b
69da0
88cf4
88d06
88d07
9549f
952d0
9734a
87c7d
87ca0

How to calculate/match page address to PFN ?

Regards,
Pankaj

--000000000000a074ac0585c680c7
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto"><div dir=3D"auto">Hello,</div><div dir=3D"auto"><br></div=
><div dir=3D"auto">I have PFN of all processes in user space, how to calcul=
ate page address to PFN.</div><div dir=3D"auto"><br></div><div dir=3D"auto"=
>eg .</div><div dir=3D"auto"><br></div><div dir=3D"auto">page address :bf05=
febc in kernel space.</div><div dir=3D"auto"><br></div><div dir=3D"auto"><b=
r></div><div dir=3D"auto">I have PFN no for user space processes as below.<=
/div><div dir=3D"auto"><br></div><div dir=3D"auto">8a81b</div><div dir=3D"a=
uto">69da0</div><div dir=3D"auto">88cf4</div><div dir=3D"auto">88d06</div><=
div dir=3D"auto">88d07</div><div dir=3D"auto">9549f</div><div dir=3D"auto">=
952d0</div><div dir=3D"auto">9734a</div><div dir=3D"auto">87c7d</div><div d=
ir=3D"auto">87ca0</div><div dir=3D"auto"><br></div><div dir=3D"auto">How to=
 calculate/match page address to PFN ?</div><div dir=3D"auto"><br></div><di=
v dir=3D"auto">Regards,</div><div dir=3D"auto">Pankaj</div></div>

--000000000000a074ac0585c680c7--

