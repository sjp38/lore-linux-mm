Return-Path: <SRS0=o7Ai=QB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEED7C282C0
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 21:19:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6F9E2184C
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 21:19:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="POgGCmzE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6F9E2184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32C758E00F1; Fri, 25 Jan 2019 16:19:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2DD0B8E00EE; Fri, 25 Jan 2019 16:19:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F1EF8E00F1; Fri, 25 Jan 2019 16:19:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id B6ACE8E00EE
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 16:19:02 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id 129so2240930wmy.7
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 13:19:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=mQzzqQ3+UzMnix9yquvbg7D8EhyAlAxFx9vArkHnx4w=;
        b=fZpPn6OyRmqmeWsukMNaiwzc8SyIGu7opDiyKYrnbHVzBPpcV46WidABvLMDlsqkFb
         q020/tu6Px44RhuxrpfGtDsU011ZLGyy2XDtga0O2Nu8s1fByfcEg7yrEM30ClGDVpKV
         G7Qrv3Fvtx6+VXGy9M0m/iBT3wCn+wbBWGjb6C/Joej2WepZDzIdrJxcPBTz+mKT/ksC
         49K8NEllb3ODargslO97Ux+pGMLFnrMiKDO4FJjzFS+MIeK6qAgvNC4wuIgfpMbwgmUK
         L3qxRS9bk5sA5tCKlbitNCP0D0FIiS0L4qDYDlYHJuh2rlm8OsaZvv/1ubeUjPuvGA13
         lhhw==
X-Gm-Message-State: AJcUukfuOxmUIubitV2hrcpY2TvM5vYvDvlxHGH/pz23nw0W76Hy3z8e
	ov1aoaC4+ru8mHJnxOQhPlB8+X+AS0IrvfXV04rbE4rjpqH5LKH9IyRDUc1mBt57/lbg22wMwwq
	cUwjaSi+l+dZfiEsjW4ESolpps8j8tPqMyXSAaDffJrxq+8LRdtlQjDcTEZIY4HSLXBme870+ad
	jdIgLnocFginXXy7nuuAe7MzlKpl/iwia9K43xqt0TZsNE8S7N1WUEoZHaRZsftH8bZrG24KOso
	z+AGYq9CN+cXeVwbzVuP0v0IWxsWhuhjc29JhGb0A9ESHHin1mxYi4iz6RtOjHzWmCntK9iLvhR
	ZPg9aM72s47bJi/OVNbRXZvrYTohCgZba19/J0VzyOh4z5UVt0L9YRyKfg4qb75r48w/85Buq4t
	l
X-Received: by 2002:adf:9083:: with SMTP id i3mr12815985wri.124.1548451142157;
        Fri, 25 Jan 2019 13:19:02 -0800 (PST)
X-Received: by 2002:adf:9083:: with SMTP id i3mr12815957wri.124.1548451141295;
        Fri, 25 Jan 2019 13:19:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548451141; cv=none;
        d=google.com; s=arc-20160816;
        b=NDvC0Sk3kBaDKPm2fXrkrgKBV1bPA12Ejb/KtSaPNX4vL0al54JRqyB7cU/JdYbADk
         u0pfzNQfLSSo1B+04ZcO7tZDczIT2T2Kv9dVl/66U3AnOnODh56WJUJya8sqrK4jVISd
         3HEKM0dIS3yalCzngrnTc4Si746HA4rJUaTP5Ia+K0jVFeyCTxCj7OMWp/4TuL6V+suV
         4qStcni0awHmmz6mZKop3uYrhA9YKvGDvR3PTuDBg9zVt2m3BRRhsFVHPKtcsXrBopfn
         Z/sv77bOn+nHj3w9Gejk5f7+OCUEFC0P6iTOE9vA734OHhDBYucCk/pptOkyMf2qEKDA
         8tPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=mQzzqQ3+UzMnix9yquvbg7D8EhyAlAxFx9vArkHnx4w=;
        b=vZsubfb06dloSfuG3mVufj5fHNIY1foPdgCOePBaVb1mvOx5g8zsFrITah/5KJTMvM
         YLc1m25aus4zWNelfLjzR16ffqEBOvix8r11JqtwBzBH4SBsmjXlKqCG7Z7DpL6v+T07
         AxKWWyx7krt4lAC9WfPBmy0GI/D6GYjBl3UrJDVNU2oaAq5FX5Tt5/G2Fsn+VifLt6Fw
         bhFME1+hyBG9872X3hMV8xwH0zEUiPX1X8Mfn10JtRzKaIDXgyGMGf/0+djpibl+unVj
         SK38tIEeTu8n867nCf3gecY7JsyxHqaqf+MP51rp/L/dKQsvpTblsdXU7NtCljqmVVTg
         ZOAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=POgGCmzE;
       spf=pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhelgaas@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b5sor39947530wmc.5.2019.01.25.13.19.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 Jan 2019 13:19:01 -0800 (PST)
Received-SPF: pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=POgGCmzE;
       spf=pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhelgaas@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mQzzqQ3+UzMnix9yquvbg7D8EhyAlAxFx9vArkHnx4w=;
        b=POgGCmzE8XS4i5eE3CynQ43OOX3OZIiQQ0nJX6EPCn8yYU6aBbg1fvNAYgUlIkCJCU
         zko869Ky5+A13BTKZTH9WGyiB3S/iPol1z+b4ZkwwMcx5cW1pdNXrzN8n17Nkc0CnPP5
         uK4RNlx6fKMXdcJJGmiyWMFgrPZdcoqewEXtEZcWs2xhr9yyytpbZ6zD8R+FcSlGlsji
         86h3en5V8qXGKs9ams7SXRThulxZsrnRPXObK/gRetalRcKOtfn8YldiV00Th535qgAW
         0pCeZ8Jh4RQjv6JV96afmHOZv3DNQvz8bC/JuR56nnjwf9arT+h2F3NDBFqOrzSaw3WK
         zUKw==
X-Google-Smtp-Source: ALg8bN7irm/L6gQp/8x2VZvHpdIzHgEuxgsBUwQrPhnrokaxn4XixZGoXgbUmXLRSAjP0ncqw25NVUTTJ0lEtI2k6KU=
X-Received: by 2002:a1c:4046:: with SMTP id n67mr7847962wma.123.1548451140658;
 Fri, 25 Jan 2019 13:19:00 -0800 (PST)
MIME-Version: 1.0
References: <20190124231441.37A4A305@viggo.jf.intel.com> <20190124231444.38182DD8@viggo.jf.intel.com>
In-Reply-To: <20190124231444.38182DD8@viggo.jf.intel.com>
From: Bjorn Helgaas <bhelgaas@google.com>
Date: Fri, 25 Jan 2019 15:18:49 -0600
Message-ID:
 <CAErSpo4oSjQAxeRy8Tz_Jvo+cRovBvVx9WBeNb_P6PxT-A_XhA@mail.gmail.com>
Subject: Re: [PATCH 2/5] mm/resource: move HMM pr_debug() deeper into resource code
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, 
	Dave Jiang <dave.jiang@intel.com>, zwisler@kernel.org, vishal.l.verma@intel.com, 
	thomas.lendacky@amd.com, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, 
	linux-nvdimm@lists.01.org, linux-mm@kvack.org, 
	Huang Ying <ying.huang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, 
	Jerome Glisse <jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190125211849.4tkyy9VAZro4MrtAUnTz0cCZvRUP8SU6zCB9XCygGJs@z>

On Thu, Jan 24, 2019 at 5:21 PM Dave Hansen <dave.hansen@linux.intel.com> wrote:
>
>
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> HMM consumes physical address space for its own use, even
> though nothing is mapped or accessible there.  It uses a
> special resource description (IORES_DESC_DEVICE_PRIVATE_MEMORY)
> to uniquely identify these areas.
>
> When HMM consumes address space, it makes a best guess about
> what to consume.  However, it is possible that a future memory
> or device hotplug can collide with the reserved area.  In the
> case of these conflicts, there is an error message in
> register_memory_resource().
>
> Later patches in this series move register_memory_resource()
> from using request_resource_conflict() to __request_region().
> Unfortunately, __request_region() does not return the conflict
> like the previous function did, which makes it impossible to
> check for IORES_DESC_DEVICE_PRIVATE_MEMORY in a conflicting
> resource.
>
> Instead of warning in register_memory_resource(), move the
> check into the core resource code itself (__request_region())
> where the conflicting resource _is_ available.  This has the
> added bonus of producing a warning in case of HMM conflicts
> with devices *or* RAM address space, as opposed to the RAM-
> only warnings that were there previously.
>
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
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
> Cc: Jerome Glisse <jglisse@redhat.com>
> ---
>
>  b/kernel/resource.c   |   10 ++++++++++
>  b/mm/memory_hotplug.c |    5 -----
>  2 files changed, 10 insertions(+), 5 deletions(-)
>
> diff -puN kernel/resource.c~move-request_region-check kernel/resource.c
> --- a/kernel/resource.c~move-request_region-check       2019-01-24 15:13:14.453199539 -0800
> +++ b/kernel/resource.c 2019-01-24 15:13:14.458199539 -0800
> @@ -1123,6 +1123,16 @@ struct resource * __request_region(struc
>                 conflict = __request_resource(parent, res);
>                 if (!conflict)
>                         break;
> +               /*
> +                * mm/hmm.c reserves physical addresses which then
> +                * become unavailable to other users.  Conflicts are
> +                * not expected.  Be verbose if one is encountered.
> +                */
> +               if (conflict->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY) {
> +                       pr_debug("Resource conflict with unaddressable "
> +                                "device memory at %#010llx !\n",
> +                                (unsigned long long)start);

I don't object to the change, but are you really OK with this being a
pr_debug() message that is only emitted when enabled via either the
dynamic debug mechanism or DEBUG being defined?  From the comments, it
seems more like a KERN_INFO sort of message.

Also, maybe the message would be more useful if it included the
conflicting resource as well as the region you're requesting?  Many of
the other callers of request_resource_conflict() have something like
this:

  dev_err(dev, "resource collision: %pR conflicts with %s %pR\n",
        new, conflict->name, conflict);

> +               }
>                 if (conflict != parent) {
>                         if (!(conflict->flags & IORESOURCE_BUSY)) {
>                                 parent = conflict;
> diff -puN mm/memory_hotplug.c~move-request_region-check mm/memory_hotplug.c
> --- a/mm/memory_hotplug.c~move-request_region-check     2019-01-24 15:13:14.455199539 -0800
> +++ b/mm/memory_hotplug.c       2019-01-24 15:13:14.459199539 -0800
> @@ -109,11 +109,6 @@ static struct resource *register_memory_
>         res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
>         conflict =  request_resource_conflict(&iomem_resource, res);
>         if (conflict) {
> -               if (conflict->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY) {
> -                       pr_debug("Device unaddressable memory block "
> -                                "memory hotplug at %#010llx !\n",
> -                                (unsigned long long)start);
> -               }
>                 pr_debug("System RAM resource %pR cannot be added\n", res);
>                 kfree(res);
>                 return ERR_PTR(-EEXIST);
> _
>

