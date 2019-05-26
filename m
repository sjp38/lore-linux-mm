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
	by smtp.lore.kernel.org (Postfix) with ESMTP id F280AC282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 15:25:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95E7C2075C
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 15:25:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qjaGSYuL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95E7C2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E57B86B0003; Sun, 26 May 2019 11:25:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E37DC6B0005; Sun, 26 May 2019 11:25:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF66A6B0007; Sun, 26 May 2019 11:25:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D1996B0003
	for <linux-mm@kvack.org>; Sun, 26 May 2019 11:25:58 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id r8so2404279ljg.6
        for <linux-mm@kvack.org>; Sun, 26 May 2019 08:25:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=slFK3r0tBYBAVRLT6Qgwzki2ozzQkZw9piCWF9KxCQk=;
        b=iGIJYNM9Nk1HKoAoUsA0x8aj60rKo3XKgKL8HvzyAwv/Kb6fOCJ2UMl0bMh/1SNe9Y
         vjNbCIj4OuRCSFmRalfc3QOHHgL1YKEuKEmGAIJyqrTCRz74VJRin5vbVyTOSBP6yMP/
         ltVTamIN6YhqWtTg8gp97ufRks3WQ9iw6U/JSnZLAeGS8zk6KZIrZ3fQ3v9RY3kl/DuW
         4kfICM6/ceieEv0r7s1/rR1MpDuJR7vv14ma8lL8/MU1K7kltcsxxJ2V2FooVQqf4c9W
         yCRDUZXVoTd74M5QWcOzCLaTe27cqH8dGD0mpvRWiHJDL27G/ra3Gc4b/sPj6gEwiAuT
         7sNA==
X-Gm-Message-State: APjAAAXss1PHfsy1qYOMe76NUZFEd+rIwCtjvVTuU3bh8CdAf0Y47oJ5
	gb6wiDTaVjoWaK0wRMZfY9NkSqApjoQIt1vJSPmnETt+XHOGcJhGDtpflLs1RcV2vQ/B82siWpI
	Qw7ccNn/9HPbeM5fw0cwKTSTWrj+ByKld7sieBE8k02MHRvUCKY6DlM40SHD5ih3FUw==
X-Received: by 2002:a19:f60f:: with SMTP id x15mr5542052lfe.61.1558884357529;
        Sun, 26 May 2019 08:25:57 -0700 (PDT)
X-Received: by 2002:a19:f60f:: with SMTP id x15mr5542031lfe.61.1558884356421;
        Sun, 26 May 2019 08:25:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558884356; cv=none;
        d=google.com; s=arc-20160816;
        b=HC1HFg3qTA5oOm2+dC9U8WhnecuOlSO5Zs0jGdit7QT30Sk0IpsPXBBy/84greXwEp
         lgHwLptM+RROHNx2N2BLd69AGr5WnHQBooO6LPNzdwHT0RUEqic8Stvyyqzq6RoNcu6S
         p0g70+pi5V3H0RxJ3E5y3lk5foRATYDZ5VU0qmozWxTJgr7k2Y2N1OptlWS0Pijt84Dn
         n3cx1KyQrlHW8DyZviZtHQjkUnzhm50QWNq2KiAsAkw4b1ZDsD5UWogydldXQoYrG+by
         bw4q8w14ij8UD6lu9U3E6jHG7lN91adnG2a3LVzP16kkIa+s6fcIqUk91rQmPZ5VbyEq
         ajDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=slFK3r0tBYBAVRLT6Qgwzki2ozzQkZw9piCWF9KxCQk=;
        b=BVXMs+mXpyoI29fwDiIrZI2a8tyBdNFblUo56nA2930FvbZ9MkjCGjnzpqfnSa/OoN
         u+cF/NcZ86ICnHCzGHOlBwKlFCIKBnmrRIihUtz8PiYQRaFg1W5Y7HwjwXVFXzKijScw
         216n7pMQl9SrBBTQKwmorBVkje4qpIMu5QzFmtUWgum/BdK7pe8Qs/qxcvROJXYyUDVN
         ewWqsHl3teyKDZecNPCd9ck8M1qEDF/NT7ZA1Qy6w7ENJCEMDC8vpPhX3RW3/10g6lKI
         5dvnMrdG61lR4umusEVDty9XMNn7wKVtm1TP/YUcihQrWfGM52Xq97VVyMP8O5B0Fc1m
         ty1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qjaGSYuL;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a23sor2059000lff.32.2019.05.26.08.25.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 26 May 2019 08:25:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qjaGSYuL;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=slFK3r0tBYBAVRLT6Qgwzki2ozzQkZw9piCWF9KxCQk=;
        b=qjaGSYuLTq680/eqk/RqGI10CHlxrLWQ5dwUIjO0a89OavRPbeldigcvAnMrsKYemM
         qXieIlTQNevattgPzlmYKPpB7J9QRxgFCZpys8qJJjjWrjiUOQY2v6LY40i/v5Rt7RAq
         f4EorM0+NoBgG+ZHWlFmLjrtZTtsHF85Gnd8GBlO15KvgibtYLzE7rBAq7DiAngqIALP
         Mm0VHu+uk18FLG0JcTh2+uUkKpB1hgXgtmLwFxbmFt3gt2CCQw0kZpLlfSBd61Dn+meU
         TZpdXfyAVyUN/y6BluNS7wsBqle8iC0DRIJUYh0xmnFwx8pRWlAiauIvcd7JltsebByK
         16pQ==
X-Google-Smtp-Source: APXvYqwGxPdQMZNi+c3qSQIrfvcZyfCGYMau/JvE4wxGAfRzS7ctjzVv1ctgtOITnpTY8B20+KCSTd063/dKN5/Twl8=
X-Received: by 2002:ac2:50c4:: with SMTP id h4mr37601885lfm.105.1558884355473;
 Sun, 26 May 2019 08:25:55 -0700 (PDT)
MIME-Version: 1.0
References: <201905261855.ag29CM2I%lkp@intel.com>
In-Reply-To: <201905261855.ag29CM2I%lkp@intel.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sun, 26 May 2019 20:55:43 +0530
Message-ID: <CAFqt6zYC0vGozczTTtU0YiM-PiREj-VYuq1PexQCPCpn0OwKVA@mail.gmail.com>
Subject: Re: [kwiboo-linux-rockchip:rockchip-5.1-patches-from-5.3-v5.1.5
 83/106] drivers/gpu//drm/rockchip/rockchip_drm_gem.c:230:9: error: implicit
 declaration of function 'vm_map_pages'; did you mean 'vma_pages'?
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Jonas Karlman <jonas@kwiboo.se>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Jonas,

On Sun, May 26, 2019 at 4:29 PM kbuild test robot <lkp@intel.com> wrote:
>
> tree:   https://github.com/Kwiboo/linux-rockchip rockchip-5.1-patches-from-5.3-v5.1.5
> head:   622dad206e3b82c53acac1857f8a6ff970c0d01b
> commit: 4004964b0854f3258032a723627d487882a74380 [83/106] drm/rockchip/rockchip_drm_gem.c: convert to use vm_map_pages()
> config: arm64-allyesconfig (attached as .config)
> compiler: aarch64-linux-gcc (GCC) 7.4.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 4004964b0854f3258032a723627d487882a74380
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.4.0 make.cross ARCH=arm64
>
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
>
> All errors (new ones prefixed by >>):
>
>    drivers/gpu//drm/rockchip/rockchip_drm_gem.c: In function 'rockchip_drm_gem_object_mmap_iommu':
> >> drivers/gpu//drm/rockchip/rockchip_drm_gem.c:230:9: error: implicit declaration of function 'vm_map_pages'; did you mean 'vma_pages'? [-Werror=implicit-function-declaration]
>      return vm_map_pages(vma, rk_obj->pages, count);
>             ^~~~~~~~~~~~
>             vma_pages
>    cc1: some warnings being treated as errors

Looking into https://github.com/Kwiboo/linux-rockchip/blob/rockchip-5.1-patches-from-5.3-v5.1.5/mm/memory.c
vm_map_pages() API is missing. vm_map_pages() merged into 5.2-rc1.
Is the below match merged into  https://github.com/Kwiboo/linux-rockchip ?

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?h=v5.2-rc1&id=a667d7456f189e3422725dddcd067537feac49c0
>
> vim +230 drivers/gpu//drm/rockchip/rockchip_drm_gem.c
>
>    219
>    220  static int rockchip_drm_gem_object_mmap_iommu(struct drm_gem_object *obj,
>    221                                                struct vm_area_struct *vma)
>    222  {
>    223          struct rockchip_gem_object *rk_obj = to_rockchip_obj(obj);
>    224          unsigned int count = obj->size >> PAGE_SHIFT;
>    225          unsigned long user_count = vma_pages(vma);
>    226
>    227          if (user_count == 0)
>    228                  return -ENXIO;
>    229
>  > 230          return vm_map_pages(vma, rk_obj->pages, count);
>    231  }
>    232
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

