Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B188DC282E3
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:02:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C17721850
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 17:02:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="J6E7gPFq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C17721850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 170D46B026D; Fri, 24 May 2019 13:02:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1219C6B0270; Fri, 24 May 2019 13:02:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 038816B0271; Fri, 24 May 2019 13:02:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB1206B026D
	for <linux-mm@kvack.org>; Fri, 24 May 2019 13:02:17 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id k66so3818578oib.20
        for <linux-mm@kvack.org>; Fri, 24 May 2019 10:02:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=uxIEMvL9NPIZt76HNNKGot2fHQFb8ScQQVFnfVEGVdE=;
        b=bdoL6txCZao/2IMilZ9gbGk8F4qdIimmWQAUFVq+EwJ3zbez+tlSr0bE09Gg5ZMxhD
         2DQv0vnVl3bjCqMIDXbw6f9w0s5R4aK+3v32e53SdrrbIFP5H8l13ON9eyJ5gKlKrSi3
         GMNquL2q6qtMYMEQjn+HaLstfkDHdJjnc3slXfxLgUGKdBYeUCbOE23jG2Bgm1AUOFdy
         V7Zmlo2W1Y39rXwJmPdnjUiz+x7X7wicxV83ZtZIuyMyrY16+JTy4V2TpeP6vNRPWH7C
         HAvxica2gDz/+bo7Zyp0X5vv5RAvtKDB7sJjBjpXIp9HQV8XL2BsLyrbtwaBQ5jA/Ewa
         FnSA==
X-Gm-Message-State: APjAAAWmDHFVq9KHbjpu6ZMu0YQRpE6LqVBodlgyJRBEJonxABlyHoVT
	FHxbXamMROuiHbO3HyiUFawPC1GYcikjbaKhmM/lyDug026558vBIQjIVoFwRH8Sz9yddz+gHlm
	0sMcHVExGnec44yBgzHQLzQn5+k0u/SAR9ff4B3n8INl9cilMt14T5Me48qOVsu9dfw==
X-Received: by 2002:aca:4e87:: with SMTP id c129mr7082438oib.130.1558717337507;
        Fri, 24 May 2019 10:02:17 -0700 (PDT)
X-Received: by 2002:aca:4e87:: with SMTP id c129mr7082390oib.130.1558717336787;
        Fri, 24 May 2019 10:02:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558717336; cv=none;
        d=google.com; s=arc-20160816;
        b=g8yx6cT2ZL8e6Ziur+H2T71cVliOQ/w0A+yNQV6wmxCaki9cPoNfm6hURSF1PC5YQh
         DW6U9nzR4Zb6AqSOXiga7ynPKy5BCseTdEjQ7vC0NkOcAE8GkNpLXIANccJ7WbieOPQ7
         jRxCu1NMoH3XG0iqCGuK6i6jG09oljgid5cQO5p6ghvdR6/5d7lsIFg3cWCRFtktbkNd
         14oU13oXqrd4omNHzdMJt8whxdIV6VVcmkh4wuB/DnAidpD2oQIWrksg6XIdHZ3CbCum
         b/niw8I5XwQ3PwLk6XXaCzNRG1iDbp8NAvwHk1Z2ylur1PcLesnTxrdQBsMLSbM4fAHw
         hJYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=uxIEMvL9NPIZt76HNNKGot2fHQFb8ScQQVFnfVEGVdE=;
        b=esrp0dTTJ9X3e2VQyKj+6JhXhTkboVvKEP8ClNaHXl8f6k+GNxAc91mM07waP9cOKO
         NLMdVk3NUcCIPPpWa+7ERhwF2M4s0PiQ0RjxUCqseAzSUXsZyNEZwAiP07zOLbpFPaGn
         EueKbFFeZVutnV0eWFdmyi5AOZ0Y25CpPTC9kvHMp1eG75mwra5P3BB2FWQBEehSA0R7
         yuwkM2Wbc3Fr6lSkI79uaIruLv/5N7B184JhZs8SqMc4WjDzrJLT5lRcVS0/Fu54vuPw
         /zx0MpwtBVlb2ZErwpfD1Jw+TrhkgTUYVArTHCBV9dkuvxjsc4hcf3ZebJ1SyY5WdEPW
         DzAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=J6E7gPFq;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s15sor1393871otq.5.2019.05.24.10.02.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 10:02:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=J6E7gPFq;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=uxIEMvL9NPIZt76HNNKGot2fHQFb8ScQQVFnfVEGVdE=;
        b=J6E7gPFqhGjQkK6F3GbGp2bqy4JZqM2JGDp4Q4363sxZZKkY1eebXwTOzadjVyNxa/
         AwEmFnD2OnTGLyCOsb4EVByimH7YKeH+ofbH0xOkO83ECfI0kA1wzco1g7dCyhxMmqn1
         lAjQLIEU87kbYcXgUjMEft09EG/s78/uSMvtXR561r30xuSwzTQgeEs/f23iRNxDK0Oq
         iv1DfXdnUJiXSNllUJOnrj1nEQzbEEh613meCgyIzDBkPavcXHBSW8mDbIRUarQv5EPB
         dh51oEmUu1WNnPiJZf+vDq4g8Yp9QXZQJUaZzJ7lJ/aNehbHAk4st7jpd1AxQslcrFO3
         kCKg==
X-Google-Smtp-Source: APXvYqxVRQpBpCep9TCI1kPQh1cOH82JFn3Gk+gMokzzTN7nj9KB6DFm/LKWbO3WZKAfI141c5e4MkYQ3VfCFR+tiNo=
X-Received: by 2002:a9d:2963:: with SMTP id d90mr14793834otb.126.1558717336323;
 Fri, 24 May 2019 10:02:16 -0700 (PDT)
MIME-Version: 1.0
References: <1557417933-15701-1-git-send-email-larry.bassel@oracle.com>
 <1557417933-15701-3-git-send-email-larry.bassel@oracle.com>
 <20190514130147.2pk2xx32aiomm57b@box> <20190524160711.GF19025@ubuette>
In-Reply-To: <20190524160711.GF19025@ubuette>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 24 May 2019 10:02:04 -0700
Message-ID: <CAPcyv4hkocsPQLQ6sfF8SuwVoot_uXge_bTZtuM-6f4XxwFVhg@mail.gmail.com>
Subject: Re: [PATCH, RFC 2/2] Implement sharing/unsharing of PMDs for FS/DAX
To: Larry Bassel <larry.bassel@oracle.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Mike Kravetz <mike.kravetz@oracle.com>, 
	Matthew Wilcox <willy@infradead.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 9:07 AM Larry Bassel <larry.bassel@oracle.com> wrote:
> On 14 May 19 16:01, Kirill A. Shutemov wrote:
> > On Thu, May 09, 2019 at 09:05:33AM -0700, Larry Bassel wrote:
[..]
> > > diff --git a/mm/memory.c b/mm/memory.c
> > > index f7d962d..4c1814c 100644
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -3845,6 +3845,109 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
> > >     return 0;
> > >  }
> > >
> > > +#ifdef CONFIG_MAY_SHARE_FSDAX_PMD
> > > +static pmd_t *huge_pmd_offset(struct mm_struct *mm,
> > > +                         unsigned long addr, unsigned long sz)
> >
> > Could you explain what this function suppose to do?
> >
> > As far as I can see vma_mmu_pagesize() is always PAGE_SIZE of DAX
> > filesystem. So we have 'sz' == PAGE_SIZE here.
>
> I thought so too, but in my testing I found that vma_mmu_pagesize() returns
> 4KiB, which differs from the DAX filesystem's 2MiB pagesize.

A given filesystem-dax vma is allowed to support both 4K and 2M
mappings, so the vma_mmu_pagesize() is not granular enough to describe
the capabilities of a filesystem-dax vma. In the device-dax case,
where there are mapping guarantees, the implementation does arrange
for vma_mmu_pagesize() to reflect the right page size.

