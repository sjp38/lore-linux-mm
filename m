Return-Path: <SRS0=ZpWy=TT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A9FEC04AB4
	for <linux-mm@archiver.kernel.org>; Sun, 19 May 2019 16:31:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C634521850
	for <linux-mm@archiver.kernel.org>; Sun, 19 May 2019 16:31:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Luuod+ac"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C634521850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22EE16B0003; Sun, 19 May 2019 12:31:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B6FC6B0006; Sun, 19 May 2019 12:31:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0806D6B0007; Sun, 19 May 2019 12:31:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id CF12B6B0003
	for <linux-mm@kvack.org>; Sun, 19 May 2019 12:31:00 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id h4so6619811otl.7
        for <linux-mm@kvack.org>; Sun, 19 May 2019 09:31:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3ZWjYi0LKYa7s2y9DAZ3jQd7Kh/YEvIwC4LalouLic8=;
        b=cnEL6Y4xTfTZLlq8mHMQZipeNnxLc5k2kgCC9ychpmXaLKgnDx6ULZtQlkIYYxNyGW
         LFTPsYrLZ/Eb+n2l6lcFC/CsLf6FDMetJ5vYXFTQgiDYJDdIV3u575Ay7/S3kIMwnvCJ
         NAI6jdgMe08OJXKGMJUDvFAw/ms5Q4US66Ur7n9OihR2alGRYYNFNZJUL3S+pUm6oSff
         +gDzo22hdFZ3q3UZSl3OVTilkLYukKIZTYCRfDvzIQBz0NEngvwWEDQ24LSbBYuyeoFk
         ohHsoS0M0LFp9Hpt2cSw5eJNKQ2tM3JhqpY4j2niX/Dc55fkpVX1D/RCuGFamBvj903+
         f7pA==
X-Gm-Message-State: APjAAAU7cyB5g3N+XZpNAU+Y2dzwluisY6sm5vAKlIjrGtBm5vMO4Jk4
	GzqQmadmTPnTxYUH3bc7DIBXxzpvNN9GGACXiTU6g8KlaSAAASPylSh/R/CoqdXei+nI1LQ/Nhv
	aAoobab/bMYtef0wFIDi3XDlKSsdwh6I3g1uHKv31WA4CBlKMUfzQKXxuH1hbOMY2PQ==
X-Received: by 2002:a9d:6a14:: with SMTP id g20mr21703937otn.310.1558283460455;
        Sun, 19 May 2019 09:31:00 -0700 (PDT)
X-Received: by 2002:a9d:6a14:: with SMTP id g20mr21703899otn.310.1558283459704;
        Sun, 19 May 2019 09:30:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558283459; cv=none;
        d=google.com; s=arc-20160816;
        b=ARbu22LKFbIkT+jm9L2zoLOuqypadDSCx0nv2TU+gQv3FbVnTG/TwUcKjDopVfGUF8
         DYS+HrjEYwniOlPA4IDX2J5f22cJAVM+meKPnHRLXjPWhA/QQ6A4xbosgnqtomJroY8o
         zwKHKPm+ftX1RCMvlVsGa1c63ewjGq6DMM1DnzcOLrWUyyT2ukn9Lx5RrORfMRgaMSTZ
         w6oLqQFJLuuvvLMMX025PCX8a8DE2OvI2KsEunicrDFv6AVxzH45P1dy5rjzkE7k485f
         1i25fNXFfu2dXK9AqxWpSEd9uG5SvLIjEzVcVuvWTJ7OdoGKdOtVkVaJQOj+hEYOlNfX
         hdPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3ZWjYi0LKYa7s2y9DAZ3jQd7Kh/YEvIwC4LalouLic8=;
        b=WVVYrt0GpEAyj1fdEU5vevTjI5RbkcNehkGibw25ZvLS0BCmTU5ihZ3C16EXwKqVZe
         Qarz60Wpp8o2gnq1m8gnjolcrh7AN1TVuyMNbF9hQdazUdZMzWNRvGiFvtZb8Jk/Mf5+
         PqHWnJQG1eNOqQZpCmqlgl1AbHpHkZaG8O1Dnhm+2qYyAwq1uA88LdNSjhsn1UmmT0A9
         QYZZL557NWoK6TExu6Mk+tZZX7BwqVewf5L6QIPo6kXfd0hDVvpTkeu+hrlBE+bE1DuI
         81i1kSRkSn3fZ0DsYTfRxJV/j6wYxIVcjU2KowjQCtI2p11mviIt5NTO3+5eANvpGsO4
         JXgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Luuod+ac;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q64sor1157367oig.68.2019.05.19.09.30.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 19 May 2019 09:30:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Luuod+ac;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3ZWjYi0LKYa7s2y9DAZ3jQd7Kh/YEvIwC4LalouLic8=;
        b=Luuod+ac+cqT9612W1nKRVgtB2LCgQKBs4NJlcDhy7HrGiNNQGf06d5rORVlwN3CGB
         TaIc5OzVLB1sEgK0QSO+hZ+ZbfxQnarzygNSBmOeuvHYKmPQKz55rOkdjeeLhAduS0Cl
         Whv/M5f1dYJdSHAL78VZajSJTtn8JmnyMbIkOBTip/JQMIf7Eo+idAAA0WrwM00f2gAs
         EZC/QNGgD+1dWOdVNkCsvgOrImn7T9hBKRkg6QD+Bg1Mn6a2yRnuwls9seQDdaKtCJwr
         Wyehk1PTvrLaRBvI4oZSU81sqAOHaiA8/Kzt/nRBBJ9hthyaBW7x78DGfxHBlEP0Ddg7
         0eRQ==
X-Google-Smtp-Source: APXvYqze7m+x1bk2ET/L1T1uLmwbLuZSspl+N/0zleTMGx5P4BoJcD1BBPDyS5Y4fzLP6m16+hvJ3Kgei0XNRfLkQjU=
X-Received: by 2002:aca:b641:: with SMTP id g62mr18495979oif.149.1558283457874;
 Sun, 19 May 2019 09:30:57 -0700 (PDT)
MIME-Version: 1.0
References: <20190514025449.9416-1-aneesh.kumar@linux.ibm.com>
 <875zq9m8zx.fsf@vajain21.in.ibm.com> <de5cbe7d-bd47-6793-1f1a-2274c5c59eb5@linux.ibm.com>
 <87sgtaddru.fsf@linux.ibm.com>
In-Reply-To: <87sgtaddru.fsf@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 19 May 2019 09:30:47 -0700
Message-ID: <CAPcyv4gi3NR4NFCQYYg2_Mpb7+qWGMsRodpf8sK1Pnz3+dCe3A@mail.gmail.com>
Subject: Re: [PATCH] mm/nvdimm: Pick the right alignment default when creating
 dax devices
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Vaibhav Jain <vaibhav@linux.ibm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 19, 2019 at 1:55 AM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
>
> Hi Dan,
>
> "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:
>
> > On 5/17/19 8:19 PM, Vaibhav Jain wrote:
> >> Hi Aneesh,
> >>
>
> ....
>
> >>
> >>> +   /*
> >>> +    * Check whether the we support the alignment. For Dax if the
> >>> +    * superblock alignment is not matching, we won't initialize
> >>> +    * the device.
> >>> +    */
> >>> +   if (!nd_supported_alignment(align) &&
> >>> +       memcmp(pfn_sb->signature, DAX_SIG, PFN_SIG_LEN)) {
> >> Suggestion to change this check to:
> >>
> >> if (memcmp(pfn_sb->signature, DAX_SIG, PFN_SIG_LEN) &&
> >>     !nd_supported_alignment(align))
> >>
> >> It would look  a bit more natural i.e. "If the device has dax signature and alignment is
> >> not supported".
> >>
> >
> > I guess that should be !memcmp()? . I will send an updated patch with
> > the hash failure details in the commit message.
> >
>
> We need clarification on what the expected failure behaviour should be.
> The nd_pmem_probe doesn't really have a failure behaviour in this
> regard. For example.
>
> I created a dax device with 16M alignment
>
> {
>   "dev":"namespace0.0",
>   "mode":"devdax",
>   "map":"dev",
>   "size":"9.98 GiB (10.72 GB)",
>   "uuid":"ba62ef22-ebdf-4779-96f5-e6135383ed22",
>   "raw_uuid":"7b2492f9-7160-4ee9-9c3d-2f547d9ef3ee",
>   "daxregion":{
>     "id":0,
>     "size":"9.98 GiB (10.72 GB)",
>     "align":16777216,
>     "devices":[
>       {
>         "chardev":"dax0.0",
>         "size":"9.98 GiB (10.72 GB)"
>       }
>     ]
>   },
>   "align":16777216,
>   "numa_node":0,
>   "supported_alignments":[
>     65536,
>     16777216
>   ]
> }
>
> Now what we want is to fail the initialization of the device when we
> boot a kernel that doesn't support 16M page size. But with the
> nd_pmem_probe failure behaviour we now end up with
>
> [
>   {
>     "dev":"namespace0.0",
>     "mode":"fsdax",
>     "map":"mem",
>     "size":10737418240,
>     "uuid":"7b2492f9-7160-4ee9-9c3d-2f547d9ef3ee",
>     "blockdev":"pmem0"
>   }
> ]
>
> So it did fallthrough the
>
>         /* if we find a valid info-block we'll come back as that personality */
>         if (nd_btt_probe(dev, ndns) == 0 || nd_pfn_probe(dev, ndns) == 0
>                         || nd_dax_probe(dev, ndns) == 0)
>                 return -ENXIO;
>
>         /* ...otherwise we're just a raw pmem device */
>         return pmem_attach_disk(dev, ndns);
>
>
> Is it ok if i update the code such that we don't do that default
> pmem_atach_disk if we have a label area?

Yes. This seems a new case where the driver finds a valid info-block,
but the capability to load that configuration is missing. So perhaps
special case a EOPNOTSUPP return code from those info-block probe
routines as "fail, and don't fallback to a raw device".

