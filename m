Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD24AC28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:02:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C268248D6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:02:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="WxopflXf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C268248D6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 186126B0266; Mon,  3 Jun 2019 13:02:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 136166B0269; Mon,  3 Jun 2019 13:02:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F40426B026B; Mon,  3 Jun 2019 13:02:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8E5016B0266
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 13:02:30 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id a2so848602ljd.19
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 10:02:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=O+yPhSShogh4P3ENVap3W5oMkAXveVWtK8AHmfJ6K4g=;
        b=tjb7JHpF1hTbf+ZApTICnqCfsRJnkbazR0k56ZE9nHx7Kx1mbfplrf9iVTuo5qs+zm
         mGhmVi5JQ9JrEn2Ze5powuirfjDMfK3DZTrnLxNe+rXLbIjKiSCAxZoct4RbE/wTPPjZ
         1zNppTMZ0M9sfnftlhSpXod8XzLL1PB3OdqbSGNI72jEiwRSnxw3cWqh+it3OD4QAVyR
         TVx2/EquJlL8h9oHv4yMdEUeRfopxf8TPRaouUuiUmhYq9wUOUUYMSqkXPVfRuhnqTql
         pPOCDh53tvcUihu+2siLuZ9lSWMegjqVCQB4t7Os55EuRthKduCBdLx2l00vt8VBWNSh
         PDoA==
X-Gm-Message-State: APjAAAVfZ5KPN1RRBte5ylhQQ1tSrjvytcj9WMGKfetxqANo2CbiWHJ1
	3PXdqBk7K7j3ekMaW5XCzO/zkks9wAvEwhap08OHRlOI1Vpb24FoZs35/4qCapJlsdh1R6lvd4g
	vLxPVi8IVR/oHDyBRj3e/QLCHfFYSF+MVPWgWf+tq7MfHNQ22yFG6DdY79kqenY86+w==
X-Received: by 2002:ac2:495e:: with SMTP id o30mr14315739lfi.140.1559581349748;
        Mon, 03 Jun 2019 10:02:29 -0700 (PDT)
X-Received: by 2002:ac2:495e:: with SMTP id o30mr14315683lfi.140.1559581348705;
        Mon, 03 Jun 2019 10:02:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559581348; cv=none;
        d=google.com; s=arc-20160816;
        b=O7/ElcucyvNprvjDX23+vwbpnS+SF34nmWJUkGvCpm6ZMSpUy4W5bXblj61tiFFQCb
         kKZE6keVlo+tw7i8PVYR2pRzwKf/tUtn65P82PyOSHjslcyev3mNXRgOTDgnvtgD3Fpu
         u7PqChOl7DoIVb21899h1a80lHESiCzE/uGyfpahLrZCiWT8JUAUKMlSTfooV4AHLqmP
         gOXeIH7wFMw/265yWpPFYRTRZaBAMCbM8sW8UjqlscqjDTGn9zLpM3JT5nWcdDK5MMzA
         qwDnNqKJigwHNlJ8KrFtzxTx+kx/ZPqAaCBhry75wAO7wE2cqtHBPnSTR0w8Q12FaN8X
         /sXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=O+yPhSShogh4P3ENVap3W5oMkAXveVWtK8AHmfJ6K4g=;
        b=EPs8KHePBhe+1CbSRq8cZhCJUoiaxEO26TnkpHEs/vy97zozZiXuXFidOf84eYJlFz
         EyzT8JTz75vvDAXP+PzyhOEfgNwPqxViyB/TSXjDflz6688jv7eIVUVfZHXPy3zXtvK5
         cuyN9lBqasQ9rEOJqS5bNRC3F/703JkcYVI+IV1VfML1+xXENeKWPNkLSFdRf8gyeNBl
         jTe1chDX0wzG5f2ipK0XVdlc0EDvIK/EmDyQh08vMiAWXktqqGhKIKRuuJFV/0YXnaAg
         kLR/ZoK2idG4GF5AoXkNumHv46M5BZkDObx/9Qp/7Bn+FqyO6YYZAQMdk7OyvTA0O5gJ
         RMng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=WxopflXf;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t26sor3983311ljj.2.2019.06.03.10.02.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 10:02:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=WxopflXf;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=O+yPhSShogh4P3ENVap3W5oMkAXveVWtK8AHmfJ6K4g=;
        b=WxopflXf16/Ij+BgtcycHtZ4Hmf9aaeOSPmXtzqGSQ8pDwEzPIMOBMYFkAoo4wEYeT
         8VeRq+J0v+JDAfheb+586kInV+Sa1f85J5zB8gURyeRKoOLNnlPfX9pmOGSsXGwefMUi
         0J3B6sJE1Hr8n5WVFsXQ5gn72CRPCxqM1IM0U=
X-Google-Smtp-Source: APXvYqy57hnTPVCTVK4FlbOpE/p3QefHy0RntoO6yMgA+qZBw0BK74iPpULQ+957E/1J4WIuLTyboQ==
X-Received: by 2002:a2e:3a1a:: with SMTP id h26mr14351197lja.156.1559581347748;
        Mon, 03 Jun 2019 10:02:27 -0700 (PDT)
Received: from mail-lf1-f41.google.com (mail-lf1-f41.google.com. [209.85.167.41])
        by smtp.gmail.com with ESMTPSA id c8sm3302492ljk.77.2019.06.03.10.02.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 10:02:26 -0700 (PDT)
Received: by mail-lf1-f41.google.com with SMTP id a9so12764431lff.7
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 10:02:26 -0700 (PDT)
X-Received: by 2002:a19:2d41:: with SMTP id t1mr13904609lft.79.1559581346039;
 Mon, 03 Jun 2019 10:02:26 -0700 (PDT)
MIME-Version: 1.0
References: <20190601074959.14036-1-hch@lst.de> <20190601074959.14036-4-hch@lst.de>
 <CAHk-=whusWKhS=SYoC9f9HjVmPvR5uP51Mq=ZCtktqTBT2qiBw@mail.gmail.com>
 <20190603074121.GA22920@lst.de> <CAHk-=wg5mww3StP8HqPN4d5eij3KmEayM743v-nDKAMgRe2J6g@mail.gmail.com>
In-Reply-To: <CAHk-=wg5mww3StP8HqPN4d5eij3KmEayM743v-nDKAMgRe2J6g@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 3 Jun 2019 10:02:10 -0700
X-Gmail-Original-Message-ID: <CAHk-=wjU3ycY2FvhKmYmOTi95L0qSi9Hj+yrzWTAWepW-zdBOA@mail.gmail.com>
Message-ID: <CAHk-=wjU3ycY2FvhKmYmOTi95L0qSi9Hj+yrzWTAWepW-zdBOA@mail.gmail.com>
Subject: Re: [PATCH 03/16] mm: simplify gup_fast_permitted
To: Christoph Hellwig <hch@lst.de>
Cc: Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>, 
	Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, 
	"David S. Miller" <davem@davemloft.net>, Nicholas Piggin <npiggin@gmail.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>, Andrey Konovalov <andreyknvl@google.com>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, linux-mips@vger.kernel.org, 
	Linux-sh list <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, 
	linuxppc-dev@lists.ozlabs.org, Linux-MM <linux-mm@kvack.org>, 
	"the arch/x86 maintainers" <x86@kernel.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 3, 2019 at 9:08 AM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> The new code has no test at all for "nr_pages == 0", afaik.

Note that it really is important to check for that, because right now we do

        if (gup_fast_permitted(start, nr_pages)) {
                local_irq_save(flags);
                gup_pgd_range(start, end, write ? FOLL_WRITE : 0, pages, &nr);
                local_irq_restore(flags);
        }

and that gup_pgd_range() function *depends* on the range being
non-zero, and does

        pgdp = pgd_offset(current->mm, addr);
        do {
                pgd_t pgd = READ_ONCE(*pgdp);
...
        } while (pgdp++, addr = next, addr != end);

Note how a zero range would turn into an infinite range here.

And the only check for 0 was that

        if (nr_pages <= 0)
                return 0;

in get_user_pages_fast() that you removed.

(Admittedly, it would be much better to have that check in
__get_user_pages_fast() itself, because we do have callers that call
the double-underscore version)

Now, I sincerely hope that we don't have anybody that passes in a zero
nr_pages (or a negative one), but we do actually have a comment saying
it's ok.

Note that the check for "if (end < start)" not only does not check for
0, it also doesn't really check for negative. It checks for
_overflow_. Admittedly most negative values would be expected to
overflow, but it's still a very different issue.

Maybe you added the check for negative somewhere else (in another
patch), but I don't see it.

                Linus

