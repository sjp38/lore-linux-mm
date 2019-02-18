Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94D35C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 13:44:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18B7E217F5
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 13:44:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=bofh-nu.20150623.gappssmtp.com header.i=@bofh-nu.20150623.gappssmtp.com header.b="drdfA6Ux"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18B7E217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bofh.nu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAEBA8E0003; Mon, 18 Feb 2019 08:44:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A35A08E0002; Mon, 18 Feb 2019 08:44:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FCD28E0003; Mon, 18 Feb 2019 08:44:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5FD6F8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 08:44:11 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id f15so14883013otl.17
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 05:44:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=wFz5T/gKS4sQKCfoA+LnrdX7HOe7jBqNz1iE1oIU+e8=;
        b=lrgfqmfjbt2LDESLlZamgbqsXAVmYq/mq9/9XhkE83tRjKdw+uVU0f3p16E8/6jRPE
         +jSXeRFv/ysCP0k+CQtTZnzRYpGJjPu3SS5olGj9yJFl5eCr5IjjKv0d1T0XPqjaj4e2
         cbv4u9aatoQCngvnRMkC8Tb+OzraQdEOAMOesrQmbIw5QHWDlCVbGaPnGtl2Z/qbgCFJ
         +v6x/ETyHpP3IGIioUePEalnytJClISNYfOaF88lzJB6gG5sTh4WyKQXE+7oOLbj4bWF
         lFw2KPwF8J2gCRZFNKv1QuTe7Z/FKp6zIlY6BwzFYHTbwNLrhVMYPDPbuGPx3fz5CHUI
         EOFA==
X-Gm-Message-State: AHQUAuZXv/b/vrjTd5hb84WaD2ftaS60nlwxndg1L/PrExOxJHG4yjjy
	T1vbP2zLy66luJR5lVYlnDmmBS/K3RvX8dCe1sF4KmlRYgd8FfRPwUCFaGlFH/fNAig3NVHF3fN
	EoO/P3DAJ7K1x3p87AeYroUODNtV6rWFPoICp33KGOe3skDYGx7+6lE3D38waaNwqYIFlzi1iID
	SkQFY3c0NsGnjxCvFgwc5478EMbCD8JJf639Ie+2jGo2CS1LQUrtn1bIX1cEuiDdqJ40xmjilTG
	zDw0wx8BT72C3AO60dDTNNqF/tnDlyh+JLIcilq3xp+vvT/d59gEPm3hoCi/tU0AnmQMiAw2UDL
	y1Vuos6hzFdHwCnvsb5nK2qJkZOh+PNgqSPCf/QYgu4GQ/HdA1Aj7OLBE+kARFZStpYGuPur6iK
	e
X-Received: by 2002:a05:6830:100b:: with SMTP id a11mr14028320otp.75.1550497450854;
        Mon, 18 Feb 2019 05:44:10 -0800 (PST)
X-Received: by 2002:a05:6830:100b:: with SMTP id a11mr14028295otp.75.1550497450157;
        Mon, 18 Feb 2019 05:44:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550497450; cv=none;
        d=google.com; s=arc-20160816;
        b=lz4bF/BZmBt4lx29kKMEHQnYC4S5JkQWXbBZd7FPWAI3nz4x/cpY66UMySpeYHgPAq
         6hWACPi+xeLvMazNe0V01MvJvIf+1k4V2fU/FI8ruxkbrNEAEEs9WrItItSTZSUoXVMx
         BxlX3h6mlk5+HawngVnS92X76XYnaOsB8pEt7wznIFjowtHMP1PKwsTOaiF5cNMdBxMP
         59+oViXeZG9y91I8tQeg59q5i7KNjGze35XGQHnvSk/1+Q+FM2XS1x05I6UrObh35ZWs
         t0sbLe7aWMYKVooie/qv51EHTlMPyPBgVDNTZyKpEVKVaODSrbRWw2qDEbkXbVsXR4Lq
         wOBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=wFz5T/gKS4sQKCfoA+LnrdX7HOe7jBqNz1iE1oIU+e8=;
        b=dpwCuZw0GDkXqh7NguWaKPTAmsoEdzTi2W2qYFJCyyWpmUshMK2VURMLiQdfuQOohx
         FnbhSpzW4Pts51sDhwQoTQQx8umala8pgehpxUBFyayLG0/R2Jc6O3+MDAcxWpzfTEei
         x5QFASqb3eWuEq5OEKI3Z6aGaOt4L2Pwgu/c0NnaORDhoKtXoMuIJtZDuHEI6ZkMjw2t
         fxQu4zc8+ijnLSXOU4r08jgo0lfhRGDT0k5CUfGL4yozYENEbG8v9SWWPenr3JPdEsld
         jrJMc3nXoToz0OR6dPMq/zN4ODdbWI2YGywTceUv1J2nceFxO+o5AUsztYlo85px9aj2
         g0uw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@bofh-nu.20150623.gappssmtp.com header.s=20150623 header.b=drdfA6Ux;
       spf=pass (google.com: domain of lists@bofh.nu designates 209.85.220.65 as permitted sender) smtp.mailfrom=lists@bofh.nu
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e11sor7091768oiy.62.2019.02.18.05.44.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Feb 2019 05:44:10 -0800 (PST)
Received-SPF: pass (google.com: domain of lists@bofh.nu designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@bofh-nu.20150623.gappssmtp.com header.s=20150623 header.b=drdfA6Ux;
       spf=pass (google.com: domain of lists@bofh.nu designates 209.85.220.65 as permitted sender) smtp.mailfrom=lists@bofh.nu
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=bofh-nu.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=wFz5T/gKS4sQKCfoA+LnrdX7HOe7jBqNz1iE1oIU+e8=;
        b=drdfA6UxeMOkGPRrukDac0Pfot+RfjI7X4llH+DqvnrjuMY14f/nJfGe9lu88QsPA/
         ZG+V3FrYSD0bDqmCdl24m/ZWWYDoA8rp728t/jWwPlfuS1GTSCKeidWlo71ssgQE47iL
         PyKI7cSnwttBv0anKgfK/L5qrEGekLuWaV3xKcgGv89ZcatVbOQzWTF6QNJU/4+vqlxb
         O/3Tq4j8ZHvn4VTXW7JRzwh54XLEo4u5JwT6MXn4ZfgH3jH8ch+uDCje+Fxe2Q1OR5+d
         sGz9crjI6+erc0Q9MNo0UseeJgH+u4Y8TnhOL5l7m1g9FRAnZr7PmPvs6//v8lcxwust
         sTgQ==
X-Google-Smtp-Source: AHgI3IZdX+BaKD9r8NSRj2jb9ncPlX8I5T5KiNHlt3XTaZjkEcj2TuEK74CefWHQLOWud5almRRl1Nk45eigelx5Kck=
X-Received: by 2002:aca:fd4c:: with SMTP id b73mr14874883oii.33.1550497449575;
 Mon, 18 Feb 2019 05:44:09 -0800 (PST)
MIME-Version: 1.0
References: <eabca57aa14f4df723173b24891f4a2d9c501f21.1543526537.git.jstancek@redhat.com>
 <c440d69879e34209feba21e12d236d06bc0a25db.1543577156.git.jstancek@redhat.com>
 <CADnJP=vsum7_YYWBpknpahTQFAzm7G40_E2dLMB_poFEhPKEfw@mail.gmail.com> <997509746.100933786.1549350874925.JavaMail.zimbra@redhat.com>
In-Reply-To: <997509746.100933786.1549350874925.JavaMail.zimbra@redhat.com>
From: Lars Persson <lists@bofh.nu>
Date: Mon, 18 Feb 2019 14:43:58 +0100
Message-ID: <CADnJP=t25=AcVq7z3w8iG1+ywnSNN4Vbow3-7tOai+qnyD5ACQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm: page_mapped: don't assume compound page is huge or THP
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, lersek@redhat.com, 
	alex williamson <alex.williamson@redhat.com>, aarcange@redhat.com, rientjes@google.com, 
	kirill@shutemov.name, mgorman@techsingularity.net, mhocko@suse.com, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000015, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 5, 2019 at 8:14 AM Jan Stancek <jstancek@redhat.com> wrote:
> Hi,
>
> are you using THP (CONFIG_TRANSPARENT_HUGEPAGE)?
>
> The changed line should affect only THP and normal compound pages,
> so a test with THP disabled might be interesting.
>
> >
> > The breakage consists of random processes dying with SIGILL or SIGSEGV
> > when we stress test the system with high memory pressure and explicit
> > memory compaction requested through /proc/sys/vm/compact_memory.
> > Reverting this patch fixes the crashes.
> >
> > We can put some effort on debugging if there are no obvious
> > explanations for this. Keep in mind that this is 32-bit system with
> > HIGHMEM.
>
> Nothing obvious that I can see. I've been trying to reproduce on
> 32-bit x86 Fedora with no luck so far.
>

Hi

Thanks for looking in to it. After some deep dive in MM code, I think
it is safe to say this patch was innocent.

All traces studied so far points to a missing cache coherency call in
mm/migrate.c:migrate_page that is needed only for those evil MIPSes
that lack I/D cache coherency. I will send a write-up to linux-mips
about this. Basically for a non-mapped page it does only a copy of
page data and metadata but no flush_dcache_page() call will be done.
This races with subsequent use of the page.

BR,
 Lars

