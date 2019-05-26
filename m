Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8ECACC282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 15:29:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3702C2075C
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 15:29:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kKoUrZ2o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3702C2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B48096B0007; Sun, 26 May 2019 11:29:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD35A6B0008; Sun, 26 May 2019 11:29:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C0536B000A; Sun, 26 May 2019 11:29:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 34D5E6B0007
	for <linux-mm@kvack.org>; Sun, 26 May 2019 11:29:07 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id h132so2195220lfh.23
        for <linux-mm@kvack.org>; Sun, 26 May 2019 08:29:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qXOd2iUL8Vuyw7Dh9qDlig9ZR56JHg5RjBcBtcLh+YE=;
        b=FpEKGrT4OnzleUiMO+ffZWskitn2QAUVmmEZ9uHxn9aVxNFW9GZWGdgmOK7+2TiKkh
         AxwYQeeP0SGxHSFrKIzIwnN4gNoWUOO6dv6TUfUYWQbnpGuKIjfWgod5NrJfZ86HMExu
         yVO1eBgXgUWAC3gKM7BIzSX5laMPG/6sR2QU5GnEVM63TSD2t+b5QoAA9a6FNeJtTLHC
         k0v4F7EPvQ5RmzS0oGHDdf/wnsxxvpNEYC8qDXfbhwGHUeqG6WRKbnggskjiPlIF7CmJ
         H3Prp7hoL+SnheYZI/1skR+wlJkPlsqzGQdlfwawjLbgYDOzJSnrJUrJLOaAybPOSoAV
         VyyQ==
X-Gm-Message-State: APjAAAVFVlBeVToqcHZBDO0YBAvK4VeE1/er9cUiQnFMLATrNk3gpnrB
	6vSRUdWKSvpVLOAeYIWUzjf2k+p5Kvfqu/RkZ+bwRDhhtYWB0CfgSOlvDP6TAtJuVdCWUQo/QSG
	1Xag1PVQAiTPz5I2AGWrKVMvSoESucRv+oqUOYJdHsjjrPJPHf25MiQ1lk7dzKkt5UA==
X-Received: by 2002:a2e:91c6:: with SMTP id u6mr41376332ljg.143.1558884546591;
        Sun, 26 May 2019 08:29:06 -0700 (PDT)
X-Received: by 2002:a2e:91c6:: with SMTP id u6mr41376306ljg.143.1558884545806;
        Sun, 26 May 2019 08:29:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558884545; cv=none;
        d=google.com; s=arc-20160816;
        b=upRdVu56/QRGOUsj+FAS+dBnpwdaafEUfyvN4E8CvMpIOgUg2E6H2aT/dc+6TdoV+u
         1mW0VKsRwGtKmcyja03hZS49/TKpKhMeIwYEbYI9H7/buOm4xcF4vTIiFBACm3wDYnSJ
         K3q/x/fyDSWTUGZyT6wz9JdQuB0gLOZUlHvjwfic3Wk+I81ZoybUU8Ux7AmtRMtH+0cf
         0LiopGKBDfkqpUlqk48XNnFMl85i5FM6eF3QrdD93P3QE7Ssgz8pcegd5QhVFEviwzym
         TXP9Rmsd2i7Mu9f37wenY9e8WD3gKi3fxc9doM2b59Erf0sUHbGrKvd4aVkhuU6T/UnT
         7BiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qXOd2iUL8Vuyw7Dh9qDlig9ZR56JHg5RjBcBtcLh+YE=;
        b=O6D0leNj96H67v4ZxySYoxW4QukFQQz7cr3OMcCbPgnt4JgxSaszEdSTxom+kdnv0j
         ydd4K91xSbIvCQPHc4rINKltp9S4yzeVwlP3XDAwAlgTmAHF6uJzqOInazAUSlDiWr+C
         oBjKhOhS6845+rSPnD+banelPKgQbX+0X13o9dXzQiYjWKx+aO3J6CC166UC82+F/axz
         ClI/FMkmT8c57AHyb4/+WNhp6xDtryqbzqCYZXXyJlmY1NaKqeFgMzp6tGWxZ3dgDtjQ
         n0rtWSjZQWjLJqOetfCr/1flkqrZw+YhV8POCGnZCpJLugYZbM792atgMRGE4MSMGJ7f
         BX0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kKoUrZ2o;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c19sor3889212ljk.34.2019.05.26.08.29.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 26 May 2019 08:29:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kKoUrZ2o;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qXOd2iUL8Vuyw7Dh9qDlig9ZR56JHg5RjBcBtcLh+YE=;
        b=kKoUrZ2o201/2fW6MsChCXxIdVjcmwaGdrSgv1eVVaTQxB1Quh8wXPay062+XEnJ/L
         6rWUePcWigT6ndiPOaNOY52bNsLvnEU3Q8Tb/8RhS7IUBbNlFrl4r9CPBNF9gKOXfMV+
         MIW1Gov9mSdRbvILv8afvG9PZEzhQ5VJWCIEVAnA98YGV9D7s3XfvfVBRla628mA0+eJ
         h+Uvzq87gkjjWtG+bfn98PsrcXvYA8/CfGqMVZ0heFlpTbSGyQ+/ry7OawT1oIhgrXM2
         2nFjBvuWBDToQxGT+D/+cDrwowrC3VwisovTVplkHIJW0WDArgka16Y+KVAB2uz4wtGn
         9rUw==
X-Google-Smtp-Source: APXvYqyF1C4+A9JjK1+VifBki6qYZIgjsnQEeF6SlJLZBtafGuL2y5JGWwzNJLh81OdzbAGmDpFNc+hyhq7CQnXv+Hk=
X-Received: by 2002:a2e:2c17:: with SMTP id s23mr5762237ljs.214.1558884545455;
 Sun, 26 May 2019 08:29:05 -0700 (PDT)
MIME-Version: 1.0
References: <201905261747.2U99rlcY%lkp@intel.com>
In-Reply-To: <201905261747.2U99rlcY%lkp@intel.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sun, 26 May 2019 20:58:53 +0530
Message-ID: <CAFqt6zZbZBhbsZNJj23DjyANfJHFLNQ_hG2bytd0EbHuHkrhEA@mail.gmail.com>
Subject: Re: [kwiboo-linux-rockchip:rockchip-5.1-v4l2-from-5.3-v5.1.5 77/88]
 drivers/media/common/videobuf2/videobuf2-dma-sg.c:338:8: error: implicit
 declaration of function 'vm_map_pages'
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Jonas Karlman <jonas@kwiboo.se>, 
	Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Jonas,

On Sun, May 26, 2019 at 2:59 PM kbuild test robot <lkp@intel.com> wrote:
>
> tree:   https://github.com/Kwiboo/linux-rockchip rockchip-5.1-v4l2-from-5.3-v5.1.5
> head:   478d6e4e03edc3c39e4e9096777533a65b2714d6
> commit: d86645f8d79fcc8209e0ec9367a9170e51900938 [77/88] videobuf2/videobuf2-dma-sg.c: convert to use vm_map_pages()
> config: x86_64-randconfig-i1-05231812 (attached as .config)
> compiler: gcc-6 (Debian 6.4.0-9) 6.4.0 20171026
> reproduce:
>         git checkout d86645f8d79fcc8209e0ec9367a9170e51900938
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
>
> All errors (new ones prefixed by >>):
>
>    drivers/media/common/videobuf2/videobuf2-dma-sg.c: In function 'vb2_dma_sg_mmap':
> >> drivers/media/common/videobuf2/videobuf2-dma-sg.c:338:8: error: implicit declaration of function 'vm_map_pages' [-Werror=implicit-function-declaration]
>      err = vm_map_pages(vma, buf->pages, buf->num_pages);
>            ^~~~~~~~~~~~
>    cc1: some warnings being treated as errors

Same here. Looking into
https://github.com/Kwiboo/linux-rockchip/blob/rockchip-5.1-v4l2-from-5.3-v5.1.5/mm/memory.c
vm_map_pages() API is missing which is merged into 5.2-rc1.
Is the below patch merged into https://github.com/Kwiboo/linux-rockchip ?

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?h=v5.2-rc1&id=a667d7456f189e3422725dddcd067537feac49c0

>
> vim +/vm_map_pages +338 drivers/media/common/videobuf2/videobuf2-dma-sg.c
>
>    327
>    328  static int vb2_dma_sg_mmap(void *buf_priv, struct vm_area_struct *vma)
>    329  {
>    330          struct vb2_dma_sg_buf *buf = buf_priv;
>    331          int err;
>    332
>    333          if (!buf) {
>    334                  printk(KERN_ERR "No memory to map\n");
>    335                  return -EINVAL;
>    336          }
>    337
>  > 338          err = vm_map_pages(vma, buf->pages, buf->num_pages);
>    339          if (err) {
>    340                  printk(KERN_ERR "Remapping memory, error: %d\n", err);
>    341                  return err;
>    342          }
>    343
>    344          /*
>    345           * Use common vm_area operations to track buffer refcount.
>    346           */
>    347          vma->vm_private_data    = &buf->handler;
>    348          vma->vm_ops             = &vb2_common_vm_ops;
>    349
>    350          vma->vm_ops->open(vma);
>    351
>    352          return 0;
>    353  }
>    354
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

