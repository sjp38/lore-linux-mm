Return-Path: <SRS0=euUm=P7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 030C5C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 12:09:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 842F621848
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 12:09:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TdmruNmZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 842F621848
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E4B188E001F; Wed, 23 Jan 2019 07:09:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF8428E001A; Wed, 23 Jan 2019 07:09:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC0E58E001F; Wed, 23 Jan 2019 07:09:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id A205C8E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 07:09:40 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id w124so951168oif.3
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 04:09:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=ozDKIbwcmYuyejXGARNO3jJ/EJ1dH91BZQgRlXa0NVc=;
        b=GF1b7zPi/Xg6OcY1MQZAbaFIaM6vQZRpFRNhjGzK72URCZ1Rlqh+5GAMNgfJHhzmWZ
         12boSygmrW978hF7OWX3xtjc2gXlPWPo5ZQMTvxtUJJsmwvchJZY8ceZZRuPv6L7SgZ8
         1fzOywFOCfVYcb3qYiqla5jq+fWVuHxX7uWOOZDTct0/0+PbLZKyatfnUBXF5Jd+AZ0d
         5TawOj+jLqn3DY889HaBbTtCu9m3OC2qg1CrjoZ2j7nnOHd1ism6JXOyZYVr3aBd2G8B
         Bh0usa9iDRMF9zUih6JMBNbAlWb/+kdLgD7WQrRLrUIvo87DfaSyWxxWkUFwMwQr0z3e
         SMzA==
X-Gm-Message-State: AJcUukc86UEnQI77VW5i476lMgTEtn+cVOOCQXJYXd4Z8mjEp/0dTslU
	w59QyNH0uP6DMBu2K2lRstPhMXgEUsjMBqE/kg5aIUHp0wdh3HhZ6kYcUxk40wl8bEKiSdAjoF6
	O2mCk7WnBsjbXmVmidxEfBKK0dTRVEnhAh1XqzVj+odezuHSm+uQvk9iYlsLJJoV7jTLYAH3pu7
	SCviEX/LGy2bQ+2iwZxFuhc976VFAh4d6GTfuC5HXAhpfP201vcxp1UtynoflnFF6yzPTAei9Gl
	8bvdGDf26Y6YgArUMnzGvs8RnWsPoqFI5Gt5Rp1u/ZY5NRED7c43E/KcYWxSy6uQWmm10iAHwja
	nx9/Dt5DACwDgPQibLfph+cQeT92g6SAOfaB/VgstgI7M5GlSU7+e+V7Zpfh3E7/psh5YPr+6V8
	Q
X-Received: by 2002:aca:c4d8:: with SMTP id u207mr1210504oif.30.1548245380322;
        Wed, 23 Jan 2019 04:09:40 -0800 (PST)
X-Received: by 2002:aca:c4d8:: with SMTP id u207mr1210481oif.30.1548245379723;
        Wed, 23 Jan 2019 04:09:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548245379; cv=none;
        d=google.com; s=arc-20160816;
        b=rKzE2kAh478XHA7M4LiDdn8aSnPz/O8ZVaOJG5EYWDSG3xkOhUj9ZW+cOQ1VDpxLsT
         ELJ9xkNu4EP01U9nr4ldH5NY5yt8ZF9vouPAPaBSyyrPlIomPpj6JEN8qrDZ817Mbks3
         Zle1FbIGDDu77nelrQj3hG3K6htL0CH8F8X84sbjLaqoRxu3AzyYM42Il7kKkuorgvCq
         oXLo+b9mIDANFpGT2s5uhvxbSwUADgxWwnxN73XAe9j0M8WN+voOH+xog7EM28y4V+7A
         nRWUKGmillXerCCum6MpU/UEM5Zq5EUgtHxwJgzNxsiNlIGWpjKxX01zYA9+GhFpCSM2
         HNLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=ozDKIbwcmYuyejXGARNO3jJ/EJ1dH91BZQgRlXa0NVc=;
        b=NgZc2b6IV+Xu8m6v8hyp34gVS7X8erJD84rQViTHjGanIeJNyTHH9AFIoXtmeQuL3+
         J8HPIw9XJ12ygkhegLeG0G+hpGMz9bgxQrlIAg8jhvqz/PG/Sk6fGp1ApUnK2LOTADj5
         Atjz+KPbR7R0E0UzIrFi1VM+8j1ey5zFCLwONnFKn/C48sD8JCP3Ajm8adyKb8xxDDfl
         UQS9o2NM1UOA9Ul0HfGLm/J73QrWqkqGgNKt0EGTW9XhsSbK74mwK7nM0UoGx08teUbZ
         OYaGkDYyS7HBJzBwV1YTaiXketXcn0EdJqnjnLeraWfgR1wbV4PIm18LXw8XBxGt9Zay
         zNEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TdmruNmZ;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n8sor9518504oia.75.2019.01.23.04.09.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 04:09:39 -0800 (PST)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TdmruNmZ;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=ozDKIbwcmYuyejXGARNO3jJ/EJ1dH91BZQgRlXa0NVc=;
        b=TdmruNmZ40rRcOmr5c75vEIE9p7sNtcssBxrB6bd1v49wN7GdrM8dCdTjsFQkdwWpn
         swJtemBXQ8ZfNyCa1SflX10bZDRPmJb8tjwU7YUSHbALC+X1sn7gMgElfhG0yulEtun3
         dI6EjQ0qoKfuvzWguCcBeFpT2cvANhqJOLW8brHwqybryRKfXMLt2jCo+c3z0h0u9cs+
         DwJAHlcaYLhJSTROVF0VfKwLWBxSkwFrqjVe5od1op4Pncf0bV9yiTfuJ+VyvjAwTZBa
         D5nZZ6vI/i6CDyC16YUTSU53EeDC1Pc5YlFAA/BNIwJPdl/R6qmYspFi9kUVWRDYLnSU
         eOng==
X-Google-Smtp-Source: ALg8bN6kOaeSQwPD4LE50phMTwZkQl9VC4fJho1QUCrFhsQiioas7XmkfUH+8ap4a9ntepudRb3YAWzJRoOY/bTa4Q4=
X-Received: by 2002:aca:c43:: with SMTP id i3mr1280767oiy.157.1548245379171;
 Wed, 23 Jan 2019 04:09:39 -0800 (PST)
MIME-Version: 1.0
References: <20190123110349.35882-1-keescook@chromium.org> <20190123110349.35882-2-keescook@chromium.org>
 <20190123115829.GA31385@kroah.com>
In-Reply-To: <20190123115829.GA31385@kroah.com>
From: Jann Horn <jannh@google.com>
Date: Wed, 23 Jan 2019 13:09:13 +0100
Message-ID:
 <CAG48ez2vfXkr9dozJiGmze8k49VOXfs=K7M8bv0aQsDDpzrEFQ@mail.gmail.com>
Subject: Re: [PATCH 1/3] treewide: Lift switch variables out of switches
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Kees Cook <keescook@chromium.org>, kernel list <linux-kernel@vger.kernel.org>, 
	Ard Biesheuvel <ard.biesheuvel@linaro.org>, Laura Abbott <labbott@redhat.com>, 
	Alexander Popov <alex.popov@linux.com>, xen-devel <xen-devel@lists.xenproject.org>, 
	dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, 
	intel-wired-lan@lists.osuosl.org, 
	Network Development <netdev@vger.kernel.org>, linux-usb@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, dev@openvswitch.org, 
	linux-kbuild@vger.kernel.org, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190123120913.OBfImxJMpKheKJjMy6Kh_IoOo-vStyiZnjGQbl8ASxA@z>

On Wed, Jan 23, 2019 at 1:04 PM Greg KH <gregkh@linuxfoundation.org> wrote:
> On Wed, Jan 23, 2019 at 03:03:47AM -0800, Kees Cook wrote:
> > Variables declared in a switch statement before any case statements
> > cannot be initialized, so move all instances out of the switches.
> > After this, future always-initialized stack variables will work
> > and not throw warnings like this:
> >
> > fs/fcntl.c: In function =E2=80=98send_sigio_to_task=E2=80=99:
> > fs/fcntl.c:738:13: warning: statement will never be executed [-Wswitch-=
unreachable]
> >    siginfo_t si;
> >              ^~
>
> That's a pain, so this means we can't have any new variables in { }
> scope except for at the top of a function?

AFAICS this only applies to switch statements (because they jump to a
case and don't execute stuff at the start of the block), not blocks
after if/while/... .

> That's going to be a hard thing to keep from happening over time, as
> this is valid C :(

