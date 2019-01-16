Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BBC0C43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 20:38:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19CB6206C2
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 20:38:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="JCWldirx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19CB6206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A951B8E0003; Wed, 16 Jan 2019 15:38:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A45A08E0002; Wed, 16 Jan 2019 15:38:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 932FE8E0003; Wed, 16 Jan 2019 15:38:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3DBD18E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 15:38:36 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id f193so1781246wme.8
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 12:38:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=EXENUcZQeQc4GpVOepu2JqCrBL5FekqSojjxZTgabJE=;
        b=qAVPc8AMP88ruGa1j7mkRS2W1qyggvLPEN7g4u5l+R6UDM95Aa0QCMee35nsyHsXzb
         aNSogiMiD9IojpUi6UgsJ9pH38yO5P6YVhKWRjngFNa0Kami410k+EJHhw6cUH7fGTWc
         3eCT8oEw4AySHU1a9kOb33QxCEoilHlMPvz7SqNsh+nQhlceP7kT+5tB8bQv3a09GbcY
         TBg6O8whRUy5PvUkQhJterdlu7GkLES1YI18xBayFFMs9TXt8rw0SWpYjgw5eoDH/cxo
         xsOILAcdhdp7s1/LLOvobagYRsZf+7iF678rz5BqN8lQYcXbl6SK4h+z5+dBjUk3LuJN
         9u6w==
X-Gm-Message-State: AJcUuketcSkOGAnEo+hQEKvO90snhbQlet1+DmGiw3WACNBI4joUOpXF
	c7CGfmDh7cYucYuyrcKUVMDQ4r/Rw3td0GsQgDArV8E/xdHzj5B/Fy7rp/l3nG0RQDqTMd8xoL0
	gwwicWfdwS6XlQFnwUyPKDA1v7evZZcs+QlneJUsh/npgcvrKe9kNkWljJ0MHVLrSNs2DyEy4LV
	A3rx01XqA53BUZJHWcAx0h/Idc9JDT4sgQml2XhV4KZlR+k8zNxZ9vfdjuxofQ/7vcdyP9Iynsm
	ZZv2mrdyqI93DpMn9elw9jRorMI5ni0X/8smrHhQ4OMXN3Mlb4ANrFc813MXhs3A1XBnMyAkyk6
	TXky9IIAtMA1peQOezua1/OQR9x3Jz2t1iphHjNEmPQMvfIT/PlT0JxB1KledAxGJhx4Eb99G0U
	P
X-Received: by 2002:a1c:c181:: with SMTP id r123mr8984826wmf.8.1547671115723;
        Wed, 16 Jan 2019 12:38:35 -0800 (PST)
X-Received: by 2002:a1c:c181:: with SMTP id r123mr8984790wmf.8.1547671114741;
        Wed, 16 Jan 2019 12:38:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547671114; cv=none;
        d=google.com; s=arc-20160816;
        b=DFvo/5VKKyuQQQ6rQhRY4cvjrClfsWfHQR4XL5moG8kw6ktFfddgXi+mU/47BdZFP9
         Crgluw+vEBkguzcdsr9D9aGmFUr1pbD1ATFPiA9tuiN+2YlQ+URWuxjXATzl61GNaxBv
         jGAsdLkh1wQj3vCgyR63zS5QX5bQGZL4e7cBxS3TSYwa/jiARIlUDpLWzKuj5vcSEYAf
         FKeufDeL3/Mg1QRcRZGOeR588B/77nYQPW4F+RxKi644P2aI9UZdWtxrEIV7asyuPGuw
         0QOYgvStxdM1ZI1ubLlDTjc01wpRBuYApoju4IXHKgKVQurqd9S56gJacX1f9yYxbz2n
         xk+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=EXENUcZQeQc4GpVOepu2JqCrBL5FekqSojjxZTgabJE=;
        b=RbBWKj8kCq5p++QHSUH8PNOA9ITzSM+k8DR3nWHLmEnHG7/QMuwRfgH2NfO7Swabrz
         iWB6K3AD+JjOJcA4dLqRdFUSkkLCSqhvU0lmRUNTqrgBZwVQh9mHpfAIp+X2wSA4wfyX
         k2g2J/G+o9OX8fXf3QMnchKzwsw0r1QRrGQ8TulSHiakMdzF5ngGg3mBSgylTVicGf5L
         NxIiOmL9fiNEvqnQz9gGRgM9TUEQsuCRcSumdk5k1F10E2ELvXDgdzEmuSj6DTeNtrGt
         Cn6BLOju3JgkjE6unbAO4t7GK0DGGh/a/L0AW6a7uvN72Crsv2CvU9JCspIhaVCbS7eB
         IQsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JCWldirx;
       spf=pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhelgaas@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n203sor15950886wma.16.2019.01.16.12.38.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 12:38:34 -0800 (PST)
Received-SPF: pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=JCWldirx;
       spf=pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhelgaas@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=EXENUcZQeQc4GpVOepu2JqCrBL5FekqSojjxZTgabJE=;
        b=JCWldirxMg//hUX4ioKgbonPMZuWXWN6HEC9HdxBMzSAWVFoVoWJFm2Y1KiskwlPZW
         itiYT++UShcarFg/zFJy8KfTI6HqbRYAx+Evx7qIm3jOSs5MIbE4O0B4BNrPyARXDOuh
         KYtUN/4omxn44KaN83fCPBSMxtFKU26Cpa7PSMnCyXCyFIvYoGWRLqWdhqFnCvNYz6R2
         bhyLV3sWl+Ry+Iavnwp1Y9cl8CTO0T6Yyf7rx7fXds+A3Q63fKpeqMH4+NiVCakFGIEa
         ukB4vm2Kzt9V0x/tHozpZDaq1KyFXdiu+LTze5Kf7P66vr1MMeZPfYZh+5FLzMfPMuRF
         ulJw==
X-Google-Smtp-Source: ALg8bN7gpC1zQUf/Ur28gfRRSuGlQu5VnHpLdE4eoVuPZp4DpLFxmDk6C1d/4OcIeclkzK7A6gnxawWFV23BB9YbhG8=
X-Received: by 2002:a1c:8d53:: with SMTP id p80mr9476229wmd.68.1547671114168;
 Wed, 16 Jan 2019 12:38:34 -0800 (PST)
MIME-Version: 1.0
References: <20190116181859.D1504459@viggo.jf.intel.com> <20190116181901.CAF85066@viggo.jf.intel.com>
In-Reply-To: <20190116181901.CAF85066@viggo.jf.intel.com>
From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 16 Jan 2019 14:38:21 -0600
Message-ID:
 <CAErSpo63av+jnkSY-V_ZNKy1LDX7rGZ6rK1bWbTf3fgrhXqrwQ@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm/resource: return real error codes from walk failures
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: dave@sr71.net, Dan Williams <dan.j.williams@intel.com>, 
	Dave Jiang <dave.jiang@intel.com>, zwisler@kernel.org, vishal.l.verma@intel.com, 
	thomas.lendacky@amd.com, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, 
	linux-nvdimm@lists.01.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	Huang Ying <ying.huang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, 
	Borislav Petkov <bp@suse.de>, baiyaowei@cmss.chinamobile.com, Takashi Iwai <tiwai@suse.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116203821.eC4AUN97WX1ThdkLeu6uzcczXPe8eXdKGtKisNB49Ns@z>

On Wed, Jan 16, 2019 at 12:25 PM Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
>
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> walk_system_ram_range() can return an error code either becuase *it*
> failed, or because the 'func' that it calls returned an error.  The
> memory hotplug does the following:
>
>         ret = walk_system_ram_range(..., func);
>         if (ret)
>                 return ret;
>
> and 'ret' makes it out to userspace, eventually.  The problem is,
> walk_system_ram_range() failues that result from *it* failing (as
> opposed to 'func') return -1.  That leads to a very odd -EPERM (-1)
> return code out to userspace.
>
> Make walk_system_ram_range() return -EINVAL for internal failures to
> keep userspace less confused.
>
> This return code is compatible with all the callers that I audited.
>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Dave Jiang <dave.jiang@intel.com>
> Cc: Ross Zwisler <zwisler@kernel.org>
> Cc: Vishal Verma <vishal.l.verma@intel.com>
> Cc: Tom Lendacky <thomas.lendacky@amd.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: linux-nvdimm@lists.01.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Fengguang Wu <fengguang.wu@intel.com>
>
>
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> ---
>
>  b/kernel/resource.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff -puN kernel/resource.c~memory-hotplug-walk_system_ram_range-returns-neg-1 kernel/resource.c
> --- a/kernel/resource.c~memory-hotplug-walk_system_ram_range-returns-neg-1      2018-12-20 11:48:41.810771934 -0800
> +++ b/kernel/resource.c 2018-12-20 11:48:41.814771934 -0800
> @@ -375,7 +375,7 @@ static int __walk_iomem_res_desc(resourc
>                                  int (*func)(struct resource *, void *))
>  {
>         struct resource res;
> -       int ret = -1;
> +       int ret = -EINVAL;
>
>         while (start < end &&
>                !find_next_iomem_res(start, end, flags, desc, first_lvl, &res)) {
> @@ -453,7 +453,7 @@ int walk_system_ram_range(unsigned long
>         unsigned long flags;
>         struct resource res;
>         unsigned long pfn, end_pfn;
> -       int ret = -1;
> +       int ret = -EINVAL;

Don't you want a similar change in the powerpc version in arch/powerpc/mm/mem.c?

>
>         start = (u64) start_pfn << PAGE_SHIFT;
>         end = ((u64)(start_pfn + nr_pages) << PAGE_SHIFT) - 1;
> _

