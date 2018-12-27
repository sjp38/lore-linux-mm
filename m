Return-Path: <SRS0=02aR=PE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C946C43612
	for <linux-mm@archiver.kernel.org>; Thu, 27 Dec 2018 05:13:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA484214AE
	for <linux-mm@archiver.kernel.org>; Thu, 27 Dec 2018 05:13:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="YIikThvL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA484214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E58818E0011; Thu, 27 Dec 2018 00:13:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E075D8E0001; Thu, 27 Dec 2018 00:13:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCFE88E0011; Thu, 27 Dec 2018 00:13:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9D03B8E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 00:13:53 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id h85so12599520oib.9
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 21:13:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ftfuiarJULp6LGAC1L+YMAmCWxT2Y+iCGWC6BJNMoXo=;
        b=lYhqaK3rlcEMWmmq9QMWt9m2rTmLq56zFdsbyqiD+l2U0v48hKPhHagvGOkhrl2YtT
         Ym3NJ8WslLTvqY/Jubf6wTXxNDuRo40POZ3ciEDKSRHvQoyaF7DQSGi4XD+0lk85Sixy
         MKOSBq5sQvU7QGFex4UGQ/ffP4mRAKlCusE9UXSENl5cRfWCxvpu1A1aHrdfkM10n5hw
         23tFOwKanB52f/5ne998SW5tJhIa6F5kuO5HhGhcKawci8RX/S2zqdhe0UBgGqVnr02N
         p7TskInumdhujYmI7DvbdAiwQ6Vq6iinA90YzrFXmBTXAHty0U+NqS2uYj7Dz8fGSmy0
         w3FQ==
X-Gm-Message-State: AA+aEWbt2kBnx1D9hQhOho5mWH0Bv0gBBU2KVBkLMGvv+j8/F0Qt4caa
	tWRVf3xuDFZWblBfH8OTMCrZ6hOCkvCA55VzkttGBB3giGz/QRKOzgbzj9kXfcTnxke+arDcFxZ
	zPuICN/aW6u+VBwB47FK4oqdqT0d90zd49Wfgx8XnnDvLR6NH5USZjHxPFjruNDMNTB6Xz/5r1L
	pGhDg/+31PJLiTeCxc3jcqhDDw3jsrYuuFvpN72lHRWfl+sXouh0pV2joD5mJPgrRPW4mVxpLsu
	rlwr9XSaNedcbb54GEvSm3zhNBokERFb3VmViepIa+SBdNvdM3+VbaDfsrCAEoYPefsAJTcAwOj
	BMbKrgzb+BuNyu7jTmB0QiixkwKRjIpHfmkMPB27Q2GTg8Y6iaxff4cGXctSdWOjLKWD7yMdKUb
	6
X-Received: by 2002:aca:a9c8:: with SMTP id s191mr14454061oie.73.1545887633375;
        Wed, 26 Dec 2018 21:13:53 -0800 (PST)
X-Received: by 2002:aca:a9c8:: with SMTP id s191mr14454043oie.73.1545887632627;
        Wed, 26 Dec 2018 21:13:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545887632; cv=none;
        d=google.com; s=arc-20160816;
        b=eaPNb1IglqJ6dVNz6+ENWNUGjAz6Y00zOoedhwpuSvzLXUqmGYA/GEFiqBvt8248VU
         d+nt4gN9uFcZ4gxJ5hLaH1hL02YBw2R7NScTpLisQraZwKS0HZ6ywzTNozq5FQSXe/9d
         uojxFqwvtQYbRwJ1gFghy7LQgWTdBCbUH6xuaDACXpavObqfMh8siUqTBO1BfPmQg3y5
         qFnQ9ocKBUgRAoBwWXvZgK2CTi05Nz3zAMEy/L6i+AjIJ5yKzn6N7z5QiH4f5a6RxwQi
         vxkJn7glgff6UY3KdcT2u16cE+ceV6otWosrdME3a3W3359QEVJNDc7C3Ub/4Y7fD0XH
         7fKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ftfuiarJULp6LGAC1L+YMAmCWxT2Y+iCGWC6BJNMoXo=;
        b=Q5cYWazZMO7fpPOhXZS5ZJfeoTz+CHMs3CXH+gwbOBR51DMBLoM3/wL7/pkGvq2G8b
         KzKC8WtkW7gw9CXw5L7nnMPiiLjhyvCSprOkKEJPdBfk6seLikymWI8MHwFtH0+ohIw9
         XdiT5Q3jkT98neumix1RD+Tz1NmGGHF62PP9sNwE4hnyRSf2ksMjV4vCnAD71M+1VVUW
         Zlo1FgxLou/VxKZDflQDiNewukF6/iBHyniQwD7sWUd87ruHfcNvnvRkqwIzyIZd46kH
         JOC9mB8wyNtNM+4EknoXa/NY8YOy3lxB63V7L2eneiXreJZgbrwoHezQvw7LlFjHXRo2
         w1ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=YIikThvL;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a96sor23608023otb.28.2018.12.26.21.13.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Dec 2018 21:13:52 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=YIikThvL;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ftfuiarJULp6LGAC1L+YMAmCWxT2Y+iCGWC6BJNMoXo=;
        b=YIikThvLQ8IAZpHYpIhHe29MuKFyMl7UkFM4k4x03s8/UTgokT39mAcnWeWrfjejGT
         +bR4zVFoLG3Ki81dw/+0Fscg0HG9n1uZT228sCoeV77peVYuV6dXMti4nLzxbDmrSR52
         QjRbQbRUEZaakYYBEujqD///8n9dfsrXvL1qZzdNtnx8NocSTIWZSd4QpyZejOJ0HRaz
         W+2ahbcJIYS7RMwEBOCnzaoi8igwnpnfQY5sqBoZkpKCBi1KTVFEJCF27KCIDJaPcFP7
         IAb/w0ce6b7+5A7w0qQRAdd32TUMK/Fgvy0IApu7yMHCPUGGI8ujRdfrnq6fGuVIPP20
         49aA==
X-Google-Smtp-Source: ALg8bN6Dxet1e8l14A8HQYdHaiIuWMpqBmLTwhbymWcx5qe0/GbeewX38xDJMTNKauZxJps/A7yeR/FdC+aeyPO9jco=
X-Received: by 2002:a9d:6ac2:: with SMTP id m2mr14682282otq.353.1545887632331;
 Wed, 26 Dec 2018 21:13:52 -0800 (PST)
MIME-Version: 1.0
References: <20181226131446.330864849@intel.com> <20181226133351.106676005@intel.com>
 <20181227034141.GD20878@bombadil.infradead.org> <20181227041132.xxdnwtdajtm7ny4q@wfg-t540p.sh.intel.com>
In-Reply-To: <20181227041132.xxdnwtdajtm7ny4q@wfg-t540p.sh.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 26 Dec 2018 21:13:41 -0800
Message-ID:
 <CAPcyv4hBBvcHiUSU4ER6WV7Po_GEwDjFcJy2aE3VW5Nwiu+Qyw@mail.gmail.com>
Subject: Re: [RFC][PATCH v2 01/21] e820: cheat PMEM as DRAM
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, KVM list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, 
	Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, 
	Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, 
	Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181227051341.ou-1DxL9OwhXoLMENyJmb8rHgRef9lOIwCkpwzqXYOQ@z>

On Wed, Dec 26, 2018 at 8:11 PM Fengguang Wu <fengguang.wu@intel.com> wrote:
>
> On Wed, Dec 26, 2018 at 07:41:41PM -0800, Matthew Wilcox wrote:
> >On Wed, Dec 26, 2018 at 09:14:47PM +0800, Fengguang Wu wrote:
> >> From: Fan Du <fan.du@intel.com>
> >>
> >> This is a hack to enumerate PMEM as NUMA nodes.
> >> It's necessary for current BIOS that don't yet fill ACPI HMAT table.
> >>
> >> WARNING: take care to backup. It is mutual exclusive with libnvdimm
> >> subsystem and can destroy ndctl managed namespaces.
> >
> >Why depend on firmware to present this "correctly"?  It seems to me like
> >less effort all around to have ndctl label some namespaces as being for
> >this kind of use.
>
> Dave Hansen may be more suitable to answer your question. He posted
> patches to make PMEM NUMA node coexist with libnvdimm and ndctl:
>
> [PATCH 0/9] Allow persistent memory to be used like normal RAM
> https://lkml.org/lkml/2018/10/23/9
>
> That depends on future BIOS. So we did this quick hack to test out
> PMEM NUMA node for the existing BIOS.

No, it does not depend on a future BIOS.

Willy, have a look here [1], here [2], and here [3] for the
work-in-progress ndctl takeover approach (actually 'daxctl' in this
case).

[1]: https://lkml.org/lkml/2018/10/23/9
[2]: https://lkml.org/lkml/2018/10/31/243
[3]: https://lists.01.org/pipermail/linux-nvdimm/2018-November/018677.html

