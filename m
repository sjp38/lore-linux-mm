Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87B23C46460
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 10:41:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4FB012083E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 10:41:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="oot9uwD2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FB012083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D05896B0270; Thu,  6 Jun 2019 06:41:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB5DC6B0271; Thu,  6 Jun 2019 06:41:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA3906B0272; Thu,  6 Jun 2019 06:41:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 97E066B0270
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 06:41:32 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id w80so164589itc.1
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 03:41:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=YZz9VH+++n/ml8QwihoeTjKhf7ccky00th8eHkY3Vfc=;
        b=jOqOVBcdRx4Bm2TEtkS8GXVuz6KtM5xUoi53gAl1DsSuJ7IO4UAP5LOPQ5XoWvjwD2
         LocTBmpw9lvCclCkkQIAJVtiDi1tYgtojUiMPqy578WUgbvfIB8xT2qbbOWb1HCmU89o
         C9GVOnEt9k6sVIeKd1vMS6wU0KT8dhJsifpCrWwANTDDIEXQEiO6KQd5VJjrElvBBUA1
         5znLYt+3LMhVwrBtckgphaFLBiD/RU0+rbOWnCldiiZl5+Z8FqH/iZMdrcsZT0ajajoU
         s+RbY01l+FEN7kLSnsckndvyh0VOjf8cXfLNYw+Iam85nRi1XYgpW6X5zB0vfRfmwBsQ
         E+7w==
X-Gm-Message-State: APjAAAVcAiGyWN+7kDWVk1JmyaJhBxtd4I5hogPX7obKdb/0o7lYeSVq
	ZseOjwdsO3ZW0g1oSOk8yNNszMnci67oD2Vg/iq+WJIvzrq66wxFHLUpahYcUv5RKYjD8YGcHhA
	gkGkWgYwvBl+7e3ypdgEwZxURd/OwwU5iiNEFqhh+jD7ccc+F7hIgq5PoV8eG81S+7A==
X-Received: by 2002:a5d:9550:: with SMTP id a16mr2719248ios.106.1559817692056;
        Thu, 06 Jun 2019 03:41:32 -0700 (PDT)
X-Received: by 2002:a5d:9550:: with SMTP id a16mr2719217ios.106.1559817691207;
        Thu, 06 Jun 2019 03:41:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559817691; cv=none;
        d=google.com; s=arc-20160816;
        b=lWG0woBxCYgIkNzJHkwfGZWer+Kkmf5JoBlXmCYtIaCgHR/IYBfi6onsEZMFrxANQR
         mbR73FN+EsS7PKq+dQwxxa/3zdOcxwY/kRov1VblGdFBqSV/CeGFIeULcFvlKRhi3mig
         Z34uyjqWpulPB8u3WFCIY0KNHr/f875z6jgZnScvhKOsJVfch9TIq4AlBOjOEB4k+psU
         fhwPHOu9KC5cvg1mf1nCogFIJ/vcNJiPP0UEcLPjcBd3zJPFGz2QmwlKEyPNOxgDDpcH
         8Y9CrUKCpBkAZd3W4amrK/1+gFPY3OkAlLjxUYGYquzevYEn2H8zu1Jnm/f0HLlV8viL
         iu7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YZz9VH+++n/ml8QwihoeTjKhf7ccky00th8eHkY3Vfc=;
        b=xxoZ2acqC2WGx7I5DPwQmm8vIBCNRpDp27RkSVbvG6PLmNpfmxgO6x5mW4Slpc1grW
         xHZ7zzVFEIONkpVdPen0/ZHOgo7KnbP/7LyzOMyIxRZYEYXhwWp1PRYB90EZt69d0uLN
         j+iqAxyNytNxGLJ9I/jXsgSo3sr03D33RvgVYt4rk8WnSm4ZieJlYhdcGn2WYt9MRrS3
         ImjYnfX6zQg/3kjzmaXKQZyDvUc4Cs3I5j8yPLEPDJFYr7Trkl9op+SLKqjYgNHR/rwq
         21LJDgGnfkNygaXJAg8GE1jG4Oc+oZ5HE0SzXC5J7AO2Puwa088IrVAB+Gl6eZDqt9dx
         T3gw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=oot9uwD2;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q5sor782250ioq.99.2019.06.06.03.41.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 03:41:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=oot9uwD2;
       spf=pass (google.com: domain of ard.biesheuvel@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ard.biesheuvel@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YZz9VH+++n/ml8QwihoeTjKhf7ccky00th8eHkY3Vfc=;
        b=oot9uwD2GIpRoIuiprplBae2RMkW7KHHuPXHbgBj1Zt1IPLHAzmAkeTV2A8L3H6kbE
         VMITsJ3j1aP5tPlEBV5gwgwKMPxdeZziwToVkctXyoxGl+yY0AkPbnIWvUYup80/H0NX
         HFoxUK484DU5KeF4HHdJL4D9xn0wDWMZaZ67j3I91i/b5sOYSmRAxdvpR7Be07dZftDk
         IahAOMUqupe11t5rWpUgRweVeJ2OZQAzrW1KnW7Nk/R4ZcGRq9MY3VbhmMg1r82MfFHZ
         9rCjSz5txBMtwphptFvApsmk9GG73EU0SgZk56kRNPbypGjefr5xI3xEwJwvhjetPsUx
         Uamw==
X-Google-Smtp-Source: APXvYqwaJmD1w0iqf+JJabWNMhpH1dQz4fhXhzeUXTh/S05TOrPkTAmbtOEly66HV1vfKvkRhB1R5D3CqSbES520EyU=
X-Received: by 2002:a5d:9d83:: with SMTP id 3mr25670814ion.65.1559817690897;
 Thu, 06 Jun 2019 03:41:30 -0700 (PDT)
MIME-Version: 1.0
References: <20190604233434.nx5tXmlsH%akpm@linux-foundation.org> <a4bfdf4c-de88-31a2-8f8d-f32c1ebdbd02@infradead.org>
In-Reply-To: <a4bfdf4c-de88-31a2-8f8d-f32c1ebdbd02@infradead.org>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 6 Jun 2019 12:41:17 +0200
Message-ID: <CAKv+Gu9=b1ewM8p9y8T7zCiQi=qYEA-webkFns-hg5rhu6=26g@mail.gmail.com>
Subject: Re: mmotm 2019-06-04-16-33 uploaded (drivers/crypto/atmel)
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mark Brown <broonie@kernel.org>, 
	linux-fsdevel@vger.kernel.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Linux-Next Mailing List <linux-next@vger.kernel.org>, mhocko@suse.cz, mm-commits@vger.kernel.org, 
	Stephen Rothwell <sfr@canb.auug.org.au>, Tudor Ambarus <tudor.ambarus@microchip.com>, 
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-kbuild <linux-kbuild@vger.kernel.org>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 5 Jun 2019 at 20:56, Randy Dunlap <rdunlap@infradead.org> wrote:
>
> On 6/4/19 4:34 PM, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2019-06-04-16-33 has been uploaded to
> >
> >    http://www.ozlabs.org/~akpm/mmotm/
> >
> > mmotm-readme.txt says
> >
> > README for mm-of-the-moment:
> >
> > http://www.ozlabs.org/~akpm/mmotm/
> >
> > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > more than once a week.
> >
>
> (problem seen in mmotm, but this is not an mmotm patch; it's from linux-next)
>
> on x86_64:
>
> ld: drivers/crypto/atmel-i2c.o: in function `atmel_i2c_checksum':
> atmel-i2c.c:(.text+0x1b): undefined reference to `crc16'
>
> because CONFIG_CRC16=m and CONFIG_CRYPTO_DEV_ATMEL_I2C=y.
> The latter selects the former.
> I don't know how to make CRC16 be builtin in this case. ???
> I changed the 'select' to 'imply' but that didn't make any difference.
>
> Full randconfig file is attached.
>

CONFIG_CRYPTO_DEV_ATMEL_I2C was lacking the 'select' entirely, but it
has now been added (as a fix to the crypto tree)

