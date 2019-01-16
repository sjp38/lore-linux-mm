Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FB9DC43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 21:59:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A94C206C2
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 21:59:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="f/BWr3r+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A94C206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EEFAC8E0004; Wed, 16 Jan 2019 16:59:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E745D8E0002; Wed, 16 Jan 2019 16:59:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3C6C8E0004; Wed, 16 Jan 2019 16:59:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 773A38E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 16:59:42 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id l1so3720332wrn.3
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:59:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=6qIfL8Zi2BtD5K9xGzCCu2hOnxmvhp5ChjrJu31awZE=;
        b=LkwP8XyIfUnv28eOfkaPIpyW3dm6ToEfhnrmnoeSnaZWQLbwnx+/fO5ZEGnkxna3FP
         RkU0LsUhxMdWiXqK0eQbzVXHF+iDLv5j50Kw9BMSFEN12c4fLSlNpCmEFX/pyO7j/HZS
         8rgiaxlGBkyLfW9U49UTLpvYcsL8oCXZpOUGUjBEOmQ8r7G8V2qaB4asdhCWQhgvQkuv
         zb06TO+wSIZ4Qzjw/f4/n8WJWlg/KTmpIDNkUuuhZi+6pEeO7rZIF44DmkvEJMhgucXF
         CuBMTrskNa41LRK1KBk/iKQNordnmD5oqd+V9Cf0PPriod/09WR+Wh17JiN/ipfakocK
         BU1A==
X-Gm-Message-State: AJcUukcr48I0IazNSAsVxR0S8jFKFiC143IrqGl79OwsrVPh5PH7zypU
	CWwMvdDMOOqwhE2ATWjOqx/GZhQN6POp6kAD9xbBKsr+g9snKPHZO2VFFOkXdiU/81fKMGWTcRq
	LNmozhoS0zaQF2pu8sy4HPXat8cShtNm0jFIi2i7HxuG7JXnRx2w+JZgnxjq8kXxx2AYVrt1Q9Z
	lfSymNNMdyLyRXmQFV67RuhhRNvb9nEtNRKBwuuIg84sPrp4It+x6+oTZkcM+Ms8KF141ApJIbs
	6ZA6IilrMtTOY8zNzgSNVf1zSsJvKOaOumpzcyPYXHs6LAKQQlGgI3sVPZgMf3WxV/AdzgEIjYe
	VCBWuOsnS6JAx9JGRGR2ylADc5dt3MUi5dmCMBfTrD9DsqyX3HLrw9EWd3Q3W+Q8/WPQFARHnxK
	y
X-Received: by 2002:adf:9591:: with SMTP id p17mr9635089wrp.224.1547675982053;
        Wed, 16 Jan 2019 13:59:42 -0800 (PST)
X-Received: by 2002:adf:9591:: with SMTP id p17mr9635058wrp.224.1547675981366;
        Wed, 16 Jan 2019 13:59:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547675981; cv=none;
        d=google.com; s=arc-20160816;
        b=oVMaLlGR/Qm38mj2OYokPc6HPcYze3BJBD7H+Mju3U5U7Nz2oFXRjl16LjxaT6hf05
         n0pjiSC6ka5hTFB9Qt5Ul4aFNErQtPiTQ9vptedUCcL/gSCt8dqCJie1ejIE/V25jPUC
         EDuA7RJX5/4OKoHLA0Ru4IxMeXfY0/mqez4kOBgopdK2CqHju7O55UqoStoIvq0oVIho
         saTm8SsdTDjsKA/mLaK3fznFunt3mvK8XqSxCrxYeHIICNWkmv9X4iA9q0K58KvQnmK6
         VNR5IPW4bqm2ma+GfHoDGMIEZj3DlE0her702aO75h0TJB3BPRzDBzrVv8wvD521W5+l
         hg5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=6qIfL8Zi2BtD5K9xGzCCu2hOnxmvhp5ChjrJu31awZE=;
        b=sR4HYqyW1W9wdsw/JFYnG8ChBpDVcMinj/cFXW/8RPjRAOWLvfkA9GOBp0IvWVgAZX
         h70K+RBa8GmJiCI1TyAv1mcU6m3Mjl7mPQCy3Z56wFoTEwRR348aBoMQ7k5tS7MTuzB7
         TzVArH1Z60+reVPpVdA0yvX6TY8Cc582v9+y3NW7IU/NOf5mCxRf7Rk561RzNGkE+znZ
         K3mv5jw03BwBiX3ZGS2W7he35/2wh8wdo9ah3fNjplOBS9ioplrogbE4GBlY+twhECf+
         N4XTuVhAp8KCUR9Ils8f95OothjODcQrJeI6XXU+hCto6bgWRJk0Ci7LJ1m5GcoAT3oN
         ZnNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="f/BWr3r+";
       spf=pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhelgaas@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 69sor23830735wmy.3.2019.01.16.13.59.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 13:59:41 -0800 (PST)
Received-SPF: pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="f/BWr3r+";
       spf=pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhelgaas@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=6qIfL8Zi2BtD5K9xGzCCu2hOnxmvhp5ChjrJu31awZE=;
        b=f/BWr3r+8ex/j4S381sHZg6EeV8ry9z0Atj7CQIjjMV7CZ+VkFOL626b6L+T9/e8qH
         AV55WLrud4Z4wCUYOTIx70Ml2zS1spEnZ4VVP8XBn8jY5XvSwp3OoEPj+K7Bi4auqhxf
         PYbpsbR6Uhwn3TT3iH7OOzj+6mUTRGkdMWYxbpAmgVfWkXJDvOmFcAGfvI34+w5d7ieB
         QpIkx+ZHiFXH1BUhTDbv1uBfRRLvHsd2DrcWWtc1EU6tw/zlRRSrsnT0jfByq5fhujJV
         XI37In3FiNudTdvS0CgWnxzHiqTZXSzGllKziYiEvehtdcadEXf+dT9BsYM0VtfUwTFt
         YsBg==
X-Google-Smtp-Source: ALg8bN7DFQ+VFScKFhjl+kHX02LbzQtshD6fLYiI7hu9xwk9q+DRsE0s/fr3ogHGivCalOmsl3MbopOjws5wT8biNJA=
X-Received: by 2002:a1c:5984:: with SMTP id n126mr8847488wmb.62.1547675980793;
 Wed, 16 Jan 2019 13:59:40 -0800 (PST)
MIME-Version: 1.0
References: <20190116181859.D1504459@viggo.jf.intel.com> <20190116181905.12E102B4@viggo.jf.intel.com>
 <CAErSpo55j7odYf-B-KSoogabD9Qqt605oUGYe6td9wZdYNq_Hg@mail.gmail.com> <f786481c-d38d-5129-318b-cb61b6251c47@intel.com>
In-Reply-To: <f786481c-d38d-5129-318b-cb61b6251c47@intel.com>
From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 16 Jan 2019 15:59:28 -0600
Message-ID:
 <CAErSpo6xjELcvj1jZ20UZS-rEHr-kNioPFTjWR9K3CuZq8ecmw@mail.gmail.com>
Subject: Re: [PATCH 4/4] dax: "Hotplug" persistent memory for use like normal RAM
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Dave Hansen <dave@sr71.net>, 
	Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, zwisler@kernel.org, 
	vishal.l.verma@intel.com, thomas.lendacky@amd.com, 
	Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, linux-nvdimm@lists.01.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	Huang Ying <ying.huang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, 
	Borislav Petkov <bp@suse.de>, baiyaowei@cmss.chinamobile.com, Takashi Iwai <tiwai@suse.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116215928.Q1NfIyme6aTxR0yzTvla0_Q9W45HrFho3eDwYOm4Nq8@z>

On Wed, Jan 16, 2019 at 3:53 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 1/16/19 1:16 PM, Bjorn Helgaas wrote:
> >> +       /*
> >> +        * Set flags appropriate for System RAM.  Leave ..._BUSY clear
> >> +        * so that add_memory() can add a child resource.
> >> +        */
> >> +       new_res->flags = IORESOURCE_SYSTEM_RAM;
> > IIUC, new_res->flags was set to "IORESOURCE_MEM | ..." in the
> > devm_request_mem_region() path.  I think you should keep at least
> > IORESOURCE_MEM so the iomem_resource tree stays consistent.
>
> I went to look at fixing this.  It looks like "IORESOURCE_SYSTEM_RAM"
> includes IORESOURCE_MEM:
>
> > #define IORESOURCE_SYSTEM_RAM           (IORESOURCE_MEM|IORESOURCE_SYSRAM)
>
> Did you want the patch to expand this #define, or did you just want to
> ensure that IORESORUCE_MEM got in there somehow?

The latter.  Since it's already included, forget I said anything :)
Although if your intent is only to clear IORESOURCE_BUSY, maybe it
would be safer to just clear that bit instead of overwriting
everything?  That might also help people grepping for IORESOURCE_BUSY
usage.

