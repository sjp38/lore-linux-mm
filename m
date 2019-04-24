Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE164C282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 17:13:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B72121903
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 17:13:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="bVeZzqyv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B72121903
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E74446B0005; Wed, 24 Apr 2019 13:13:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E23186B0006; Wed, 24 Apr 2019 13:13:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEAF26B0007; Wed, 24 Apr 2019 13:13:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id A35966B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 13:13:28 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id n63so11121998ota.2
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:13:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=YZeSR7Aq2N3w70JEnXehtiOMPIO6rUu44DEBTQu+WpA=;
        b=VWNRehv5+8WTFpT6PQPPClXictmox6XvK7FG6RQaA3G7i7T1QtDX4207qIK+/8FA6z
         qex7YPDTktfbisrJ9sUJea7ErqB6yACKULHhAPFhP0GLAQDKYPS49ed5U7cadixQARGR
         4yF7SaJDBkfaiJQCxw3NugaJADLWTaPB7qAjmQiS+L/IoAJ4gP6d6LuiJ7RbGoy1st5w
         ZdX6iKsrLd5Lx9MK6ihGoUwTnNp+aAbd+MJVM2kvQETEeyR1qZh0SUlqO69aL1/+x5pf
         0U+3dB6/TsePn8Hg3N+6bQy5u+dP5xRZ4MfzhBYPxxId3wcZOeyHJIUsZpSjCfei062X
         HPpA==
X-Gm-Message-State: APjAAAXU5Aa9S+3vxGFt8Hd6/y4wJU06+/wYTOlUyu6t/Z/SOBs0vahT
	wE8Jl7gSwzWkEaoNkipb60uzOY2hW/a80qDmw2ylYO9Xx0nkr9TUlW3jVPfZNWWXXdonhoH2ZZq
	/AdSF2Ml9mr/jzmvlgAGcWX0GV6Wh9khp8KwKrIZDLqqiCQ45rRYsiqklOcxbLlWFDA==
X-Received: by 2002:aca:305:: with SMTP id 5mr63237oid.117.1556126008102;
        Wed, 24 Apr 2019 10:13:28 -0700 (PDT)
X-Received: by 2002:aca:305:: with SMTP id 5mr63187oid.117.1556126007177;
        Wed, 24 Apr 2019 10:13:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556126007; cv=none;
        d=google.com; s=arc-20160816;
        b=CnH99LLXRIpMkGtNRVNXwSoJviNM1tINoM2U1CPgYgdOOpf/DeJfD+3YejqvFfgV9q
         XpbQQ97LOi/McP9iUirlzjx98FYn0v4GeMG8vxKMUonA6gkwUZjr6CLxv4m4tqTOynKo
         JqVAqbqHAuOqJ0iFS+ZF4kG9DUjwiRUIA6yPLe/HRcXDv5fWzTNXlDsjFEzIbnGjd2FT
         V0kyrADP+Vw/CPhrhCKkS6Xb7/TWKEesSmZDWc36TKVhsntZDnG0J9bkLgWPoy++Meuz
         JU/PEYNPwLjbYhqWQik51mi8xbiJdeQA5tb6pFS3w0ben8kJPMHMNZ1/x08f4okOG9B+
         dvcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YZeSR7Aq2N3w70JEnXehtiOMPIO6rUu44DEBTQu+WpA=;
        b=feCEaUG3bDoWoR2reL9PzooFsFl5F88uE1dzUqFvVEUzwqgBM/v5oX0Tc8F7qdcxL2
         VQpZ3eS4jOBuX4AYiIIdDU7M1/idgmT3Eonyr1vhxirdelxgwlyc13rQw7F7pNFgFV1z
         X+ccBkp0hfnMAEUY+PlPpsGZzatgP5zV6c3mkrCWyL6QQVSNE5oVg8e6Q2Y5H3/6UjpW
         Zw1kn6n3rK+fzeztkJQ09hLYxBTYcQARq4I+6mbUDeAqKP9MyrWWLyeQGUTPEZ1CqR15
         ejW11Yo2l0xWgIzRRloEscVCM92ww5RA26neg0EcqNqoeZqM9DdOZnRLHbC0rHRkp41E
         xbjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=bVeZzqyv;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x26sor8858330oto.110.2019.04.24.10.13.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 10:13:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=bVeZzqyv;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YZeSR7Aq2N3w70JEnXehtiOMPIO6rUu44DEBTQu+WpA=;
        b=bVeZzqyvtMg15/SBGydnDu1sXE6MZGRTmM2pih0vek44kQ5MId0FnVGWw8pRW9DqTX
         susgUEtmP3XX5dNw/C5QC7xeWgf9Ebqi93lYw94PFApni0MtwW6QTlj4cRoFXfNvPus8
         6MfCk27RfL410sz3Nhpeu4z2YEQqI5Q9xtpYKJH55HLvipT5F2eANwQMcD/LktuRs8O1
         lwW9ZuhSPLPpsaTe40pd3tMM0EX5JraP6nthTyqFTJXXXqXBhT58nq1glsmP0uALnl2h
         fYnHxV4KsEvOJaeZdKgshSlj5+S5KxuA5tRMe3+XCQgl64KHuzrAiwRUJOcrVv4z2n7s
         vEJA==
X-Google-Smtp-Source: APXvYqzn34MhQI1QA5M+++qBzaGXTmfd/hleC1MMSfBitQmWj6xxPvxkYHEvfFH6xTpugoQEtfYFKXxMawNxKlCVUTM=
X-Received: by 2002:a9d:19ed:: with SMTP id k100mr1957702otk.214.1556126006611;
 Wed, 24 Apr 2019 10:13:26 -0700 (PDT)
MIME-Version: 1.0
References: <20190402115125.18803-1-aneesh.kumar@linux.ibm.com>
In-Reply-To: <20190402115125.18803-1-aneesh.kumar@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 24 Apr 2019 10:13:15 -0700
Message-ID: <CAPcyv4hzRj5yxVJ5-7AZgzzBxEL02xf2xwhDv-U9_osWFm9kiA@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Fix modifying of page protection by insert_pfn_pmd()
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, stable <stable@vger.kernel.org>, 
	Chandan Rajendra <chandan@linux.ibm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 2, 2019 at 4:51 AM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> With some architectures like ppc64, set_pmd_at() cannot cope with
> a situation where there is already some (different) valid entry present.
>
> Use pmdp_set_access_flags() instead to modify the pfn which is built to
> deal with modifying existing PMD entries.
>
> This is similar to
> commit cae85cb8add3 ("mm/memory.c: fix modifying of page protection by insert_pfn()")
>
> We also do similar update w.r.t insert_pfn_pud eventhough ppc64 don't support
> pud pfn entries now.
>
> Without this patch we also see the below message in kernel log
> "BUG: non-zero pgtables_bytes on freeing mm:"
>
> CC: stable@vger.kernel.org
> Reported-by: Chandan Rajendra <chandan@linux.ibm.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
> Changes from v1:
> * Fix the pgtable leak
>
>  mm/huge_memory.c | 36 ++++++++++++++++++++++++++++++++++++
>  1 file changed, 36 insertions(+)

This patch is triggering the following bug in v4.19.35.

 kernel BUG at arch/x86/mm/pgtable.c:515!
 invalid opcode: 0000 [#1] SMP NOPTI
 CPU: 51 PID: 43713 Comm: java Tainted: G           OE     4.19.35 #1
 RIP: 0010:pmdp_set_access_flags+0x48/0x50
 [..]
 Call Trace:
  vmf_insert_pfn_pmd+0x198/0x350
  dax_iomap_fault+0xe82/0x1190
  ext4_dax_huge_fault+0x103/0x1f0
  ? __switch_to_asm+0x40/0x70
  __handle_mm_fault+0x3f6/0x1370
  ? __switch_to_asm+0x34/0x70
  ? __switch_to_asm+0x40/0x70
  handle_mm_fault+0xda/0x200
  __do_page_fault+0x249/0x4f0
  do_page_fault+0x32/0x110
  ? page_fault+0x8/0x30
  page_fault+0x1e/0x30

I asked the reporter to try a kernel with commit c6f3c5ee40c1
"mm/huge_memory.c: fix modifying of page protection by
insert_pfn_pmd()" reverted and the failing test passed.

I think unaligned addresses have always been passed to
vmf_insert_pfn_pmd(), but nothing cared until this patch. I *think*
the only change needed is the following, thoughts?

diff --git a/fs/dax.c b/fs/dax.c
index ca0671d55aa6..82aee9a87efa 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1560,7 +1560,7 @@ static vm_fault_t dax_iomap_pmd_fault(struct
vm_fault *vmf, pfn_t *pfnp,
                }

                trace_dax_pmd_insert_mapping(inode, vmf, PMD_SIZE, pfn, entry);
-               result = vmf_insert_pfn_pmd(vma, vmf->address, vmf->pmd, pfn,
+               result = vmf_insert_pfn_pmd(vma, pmd_addr, vmf->pmd, pfn,
                                            write);
                break;
        case IOMAP_UNWRITTEN:


I'll ask the reporter to try this fix as well.

