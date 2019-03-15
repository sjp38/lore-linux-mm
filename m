Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 375D1C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 17:33:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7E25218AC
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 17:33:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="UZ/EUy5U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7E25218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75E266B0297; Fri, 15 Mar 2019 13:33:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70DC96B0298; Fri, 15 Mar 2019 13:33:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FC726B0299; Fri, 15 Mar 2019 13:33:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CEEA6B0297
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 13:33:55 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id h123so2688060oic.5
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 10:33:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=KbOPCLGH615rzHUJ58dlndK4nolZ2OflZPgnP6NqsWc=;
        b=rweqKe5KMS3jlQVv9dsgojmvWOMIiZ88Z+sn7R/oQvmsy7jSHbOpPK6QbjV+YkUx0I
         jYPc2axyxhEMIyq9hbCQ2SS5StMva0amq/jDUaDFZU/UzYChgK/2MwiW+ptjTw4NSE+b
         JOCJSNtENqJ4QuK0j6FesyblaTygaVFUEvtuCY1/TtlWYh1Eh1t/CKTT5Wg5gB32QtH1
         EbVCjx5QuihtGV85Gh3/DKlSF0JbdLEc8B7mjNUtbsIROtmujd9wBm2Q2bVsS9fJFrrv
         xiKzowWQOysRqiz6hcGMNBiZg5aCq+WXJHy9r2iPoT3AZbxiNLp2ekJE6KzobZlNbqI5
         3h1A==
X-Gm-Message-State: APjAAAV7rM8jt03SSIM359BGoZ+9BZHB0guVbKnA5gOv24A1vA68Gd9/
	eX5oP6+idIm37bSlAPXJ+kLiS2OxQ9VlO9rXEciRzCqEz0tdWikcH8H2NuT0HscaLqO8SzONbMN
	+D7zA8rpqyBU/3UyLK5h3/Kaib6b3WOTNi7wOrZ+bX1uqSNIEr3rYhv0L1dihU2JL7w==
X-Received: by 2002:aca:c002:: with SMTP id q2mr2145584oif.145.1552671234732;
        Fri, 15 Mar 2019 10:33:54 -0700 (PDT)
X-Received: by 2002:aca:c002:: with SMTP id q2mr2145544oif.145.1552671233715;
        Fri, 15 Mar 2019 10:33:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552671233; cv=none;
        d=google.com; s=arc-20160816;
        b=XuJxdiB7Xi2sXB4M4ttLUnMqM4UT+vrdnk+JhwOQQFQ9X6vXAxKox0GzulFocLvVSg
         kgrINVXWjpWxe1M/qJwMkGXp3X67hOO8CDf71DQDyyUTPnvIOfau8Pk5qFeBzsaQ916b
         eSp2ZU1E/DUoNMq5hzkyPes1PLN0H7PALGgxnc0Vxl75oAnr9fqdLQ48JNCoVZtlv4kU
         RBXnkl+uRdZBWBdG6PML8ohxBiZ5ds68b6ven8QLELb1MfsO3bkukKsgw3F/0jDAPSOo
         8cYYQ5L+zhTLDOgU7AzKx3FkNGSAOm9pCMULwpijJ8+1Xhjr2cHsD/CS7TGb2UsgATba
         kTew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=KbOPCLGH615rzHUJ58dlndK4nolZ2OflZPgnP6NqsWc=;
        b=zZ1poOspAbH1uaedAsq1hsk2VJmMO9nM1SJBwXXSvbkNwHQoqomUdW7H3Aprp8KhNt
         5A0VYPlYZXYZ0xOIlgXuYXkLrRUxwWZgLGTmlHMTICGqMckCA8Gz6cLxOZgBF8wgDtAc
         OENqCnBgfwN4GJxxh1bJ5/S4/Z5MoNC3bXp1cUKOYD3m4TEyxuOILlWwnaCKsMe8lsS4
         kHY4mui3onT8zp/1NPRIhT9+ZIS3G+g9UfoiZONDavqcLCIpT98v2eqQe+n9fTM7g7wS
         CK73ej35JpTM2jPUCr/ciKUPg7OZ5mhjKpiPuqAQmj4VZIe2LVpmtNpk66k6DyLiifUb
         xKtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="UZ/EUy5U";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l82sor1443478oib.81.2019.03.15.10.33.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 10:33:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="UZ/EUy5U";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=KbOPCLGH615rzHUJ58dlndK4nolZ2OflZPgnP6NqsWc=;
        b=UZ/EUy5Upo9VPqGw6mzjs/HX3bsCxRl6Q1QwlY+UPQS1NYfI3Ssh5KtVm5yps/0APD
         I9wur5s5LRgFE2oMVJVh2oJUcZjjJfdtrN6jvCsnGfNJNuQneS3+v8yylqoSK7ej/9mt
         hhMuRP9sDxWYsS17phPcuOO46l7QrcDA6I8k0cV/4K+6R0vqQ+PSbRtAMiZvm5FERdeJ
         Ro6e8pmoqf/NtZEq2PxjuKhOwQ6WwOUi9Xexw5Ems+jxIS3sn07q4UAvgkbL42PbjefE
         k+5qbEBC1zqzNfOVjR6JCByhM0oNSRiUbVMatHHEc6PWD9tK/321E5QtxTDt3F+FNsJB
         rYQw==
X-Google-Smtp-Source: APXvYqzTpDg/na3VtIyOako/c4bGiTvqvf5i8gtF287Ago1Xz7ZKyg00WEzH0Jg30fjR8evDl6LdTMDv19Kji+AcjXg=
X-Received: by 2002:aca:df57:: with SMTP id w84mr2379057oig.105.1552671232790;
 Fri, 15 Mar 2019 10:33:52 -0700 (PDT)
MIME-Version: 1.0
References: <CAPcyv4he0q_FdqqiXarp0bXjcggs8QZX8Od560E2iFxzCU3Qag@mail.gmail.com>
 <CAHk-=wjvmwD_0=CRQtNs5RBh8oJwrriXDn+XNWOU=wk8OyQ5ew@mail.gmail.com>
 <CAPcyv4hafLUr2rKdLG+3SHXyWaa0d_2g8AKKZRf2mKPW+3DUSA@mail.gmail.com>
 <CAHk-=wiTM93XKaFqUOR7q7133wvzNS8Kj777EZ9E8S99NbZhAA@mail.gmail.com>
 <CAPcyv4hMZMuSEtUkKqL067f4cWPGivzn9mCtv3gZsJG2qUOYvg@mail.gmail.com> <CAHk-=wgnJd_qY1wGc0KcoGrNz3Mp9-8mQFMDLoTXvEMVtAxyZQ@mail.gmail.com>
In-Reply-To: <CAHk-=wgnJd_qY1wGc0KcoGrNz3Mp9-8mQFMDLoTXvEMVtAxyZQ@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 15 Mar 2019 10:33:41 -0700
Message-ID: <CAPcyv4iUxDj26_6neOVEg7b6_2SLHKpohv9o6jv95R_RhV1S-g@mail.gmail.com>
Subject: Re: [GIT PULL] device-dax for 5.1: PMEM as RAM
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, 
	"Luck, Tony" <tony.luck@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 5:08 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Mon, Mar 11, 2019 at 8:37 AM Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > Another feature the userspace tooling can support for the PMEM as RAM
> > case is the ability to complete an Address Range Scrub of the range
> > before it is added to the core-mm. I.e at least ensure that previously
> > encountered poison is eliminated.
>
> Ok, so this at least makes sense as an argument to me.
>
> In the "PMEM as filesystem" part, the errors have long-term history,
> while in "PMEM as RAM" the memory may be physically the same thing,
> but it doesn't have the history and as such may not be prone to
> long-term errors the same way.
>
> So that validly argues that yes, when used as RAM, the likelihood for
> errors is much lower because they don't accumulate the same way.

Hi Linus,

The question about a new enumeration mechanism for this has been
raised, but I don't expect a response before the merge window closes.
While it percolates, how do you want to proceed in the meantime?

The kernel could export it's knowledge of the situation in
/sys/devices/system/cpu/vulnerabilities?

Otherwise, the exposure can be reduced in the volatile-RAM case by
scanning for and clearing errors before it is onlined as RAM. The
userspace tooling for that can be in place before v5.1-final. There's
also runtime notifications of errors via acpi_nfit_uc_error_notify()
from background scrubbers on the DIMM devices. With that mechanism the
kernel could proactively clear newly discovered poison in the volatile
case, but that would be additional development more suitable for v5.2.

I understand the concern, and the need to highlight this issue by
tapping the brakes on feature development, but I don't see PMEM as RAM
making the situation worse when the exposure is also there via DAX in
the PMEM case. Volatile-RAM is arguably a safer use case since it's
possible to repair pages where the persistent case needs active
application coordination.

Please take another look at merging this for v5.1, or otherwise let me
know what software changes you'd like to see to move this forward. I'm
also open to the idea of just teaching memcpy_mcsafe() to use rep; mov
as if it was always recoverable and relying on the error being mapped
out after reboot if it was not recoverable. At reboot the driver gets
notification of physical addresses that caused a previous crash so
that software can avoid a future consumption.

git://git.kernel.org/pub/scm/linux/kernel/git/nvdimm/nvdimm tags/devdax-for-5.1

