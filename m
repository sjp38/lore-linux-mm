Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3447BC4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 03:59:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D88C02070D
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 03:59:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Kkh8QnWI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D88C02070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 748CA8E0003; Thu, 27 Jun 2019 23:59:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F8FD8E0002; Thu, 27 Jun 2019 23:59:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60DDF8E0003; Thu, 27 Jun 2019 23:59:42 -0400 (EDT)
X-Delivered-To: Linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 43F368E0002
	for <Linux-mm@kvack.org>; Thu, 27 Jun 2019 23:59:42 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id r27so5090597iob.14
        for <Linux-mm@kvack.org>; Thu, 27 Jun 2019 20:59:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Cs/BCNc/RCyeiUvf3Dd7XA6XNw70/7ZfOeMlzKTDfTw=;
        b=NtlgFi+Xp5i+wABcTCS7kKbwPgzi7KH64XDJ5beC0cp0qaNYSfmkONk/q1OMvyaCmf
         SNfwR6nr4PrnT6xQRp27UPZCUAsWsINHP5H0ht6GGLywLkj6c0A4H7LNJOYl2FlnezPX
         Z5+UK4mekb8FXyZxteFGNjyBoAFGBlpjVtOinmg5LJdIIpoAgck5r0+AjGDCOdnLZMVJ
         UYEsHXiVVnvZT93UjKmiTqJ7Q8b7g7XkxLwGsiy6zBi1MpwudM7p1oCRzCHEvbDXqrzP
         hNVp3/C0Fzc3KaM5Bi9nQ5vE6rvtEPfzmg3HktADqw3vGxfPdlznWjm/bLZdAjMB/oml
         670w==
X-Gm-Message-State: APjAAAUS9nGEC6WN3FTXa6ZkTlS9gllEBL1yPReSIloF3r5h/02vu9Iz
	8qCvZ1fzElnQSsH5xOpqp/mCTvv30q9d5SImthAiPfeeR8P9LFwzvXx5VQCT0ZJdmabWL+smAGS
	GlGYJku/KnS65Sj760iNQ4/SQw13R1WnYap8aurFkxNuQCGTckhbHDvKEpBknfhZyIA==
X-Received: by 2002:a5e:c00a:: with SMTP id u10mr8445749iol.24.1561694381981;
        Thu, 27 Jun 2019 20:59:41 -0700 (PDT)
X-Received: by 2002:a5e:c00a:: with SMTP id u10mr8445713iol.24.1561694381333;
        Thu, 27 Jun 2019 20:59:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561694381; cv=none;
        d=google.com; s=arc-20160816;
        b=NIOIQ2Jz3NqXobzELm4XHQob/byRCqZAblrPWXNiIdEBE8yE7jJmzD4Lpf1WN///Kr
         dPzpYe8M/jdIsMzuuhIC+n5yjchXe45flKCguiooCgXORywFFxaUtofLnKJ/oQTVeH+6
         sRHJTP0ieH7x+2A+XRB/ANLm5j0IXWPXSBLApd9oC0fB0VwtVlVbSwKyzj3X35F9SFxg
         Wi6hdWClcbp80bv+zZ3/Jji5zpLdoKgYBnrpHvBsmaIGaTNIds4y+AIB+wvNZGpsV+HQ
         5veTkfiCLfI65uhVj8QakmEYw303d+JHIv+AWcP9Y+dgl7zGqqxmdgsIthlap3+3r649
         00ZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Cs/BCNc/RCyeiUvf3Dd7XA6XNw70/7ZfOeMlzKTDfTw=;
        b=fIH7ipTJJZOGkRDUyUDFzLT+rsrQj0ayRB3T+yrp25NFTpF2NpXABjIZ7N87LYxP70
         UjrAjm7AEj8zTC1IMu37UhUboKrbimAIih1oY0lfUFCYxDxgKDfjQRB2Svjo7+oTm4YK
         w4CkYyRG1Ukjk5datjoxowaVGT/lVuQ/+zQOqpYgoeIgjnm8VlW/AVo3KJHnvk3knD6D
         2Q5MnZ9WiQz2tQnStNDLv1WcPxNM0w1VlbqH0J+irmIJnj+jh9jAPuDQfmEqU0WM4bOW
         /8+Ag1ZeQ6ch2NpkJui3qj0wNHo8Upf7pGlm4mP/kpxKFqAyyOysBXQFk+A7l6GHkbnJ
         CQ3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Kkh8QnWI;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n31sor2161631jac.0.2019.06.27.20.59.41
        for <Linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 20:59:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Kkh8QnWI;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Cs/BCNc/RCyeiUvf3Dd7XA6XNw70/7ZfOeMlzKTDfTw=;
        b=Kkh8QnWIzrZazVljg6hBsx7W/ZP0eBr1ejVjQyHZVuyvnJ6opqO1Z13W5iz5qwZfcj
         H0lYWcBOzr76HbMzjj9mSOh7bOMz8gIv2Mc8LAsLOX1h/MbSQcUX+u0P7/MCrytmMmf1
         LP6QAlNDiOPI4CvLDKDvIhwWm+6F4zDZ/QIV2jsOeWikKn5H8nTXUpxnPFDi+tADdELb
         wftLrz7FO1ZOq0s5Vc8glGunRKW99QX4s7hsFHySk3XEKUzqbNXquuqnZrDKU6fKvAgc
         +PVk85g3fniAVaasVO0H0eME/b4zu2fMzz+50cj1nNgjd2/g2/SKXK8IT1YVcTH0vSHL
         pMXA==
X-Google-Smtp-Source: APXvYqyY3ydiSQhtYGah1iASt/iBOIbXr1KVVwN5LrQiYQZl9AUwyMpJlNcyVhrRfjf43MZT+WCGvVS8crgLy/UEH1M=
X-Received: by 2002:a02:c6b8:: with SMTP id o24mr9180808jan.80.1561694381133;
 Thu, 27 Jun 2019 20:59:41 -0700 (PDT)
MIME-Version: 1.0
References: <1561612545-28997-1-git-send-email-kernelfans@gmail.com> <20190627162511.1cf10f5b04538c955c329408@linux-foundation.org>
In-Reply-To: <20190627162511.1cf10f5b04538c955c329408@linux-foundation.org>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 28 Jun 2019 11:59:29 +0800
Message-ID: <CAFgQCTsO6WOef1v69J3+Vx-AuU8pPVeJSTjrf04VQum=YXEk2w@mail.gmail.com>
Subject: Re: [PATCHv5] mm/gup: speed up check_and_migrate_cma_pages() on huge page
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-mm@kvack.org, Ira Weiny <ira.weiny@intel.com>, 
	Mike Rapoport <rppt@linux.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Thomas Gleixner <tglx@linutronix.de>, John Hubbard <jhubbard@nvidia.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Christoph Hellwig <hch@lst.de>, 
	Keith Busch <keith.busch@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>, 
	LKML <Linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 7:25 AM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Thu, 27 Jun 2019 13:15:45 +0800 Pingfan Liu <kernelfans@gmail.com> wrote:
>
> > Both hugetlb and thp locate on the same migration type of pageblock, since
> > they are allocated from a free_list[]. Based on this fact, it is enough to
> > check on a single subpage to decide the migration type of the whole huge
> > page. By this way, it saves (2M/4K - 1) times loop for pmd_huge on x86,
> > similar on other archs.
> >
> > Furthermore, when executing isolate_huge_page(), it avoid taking global
> > hugetlb_lock many times, and meanless remove/add to the local link list
> > cma_page_list.
> >
>
> Thanks, looks good to me.  Have any timing measurements been taken?
Not yet. It is a little hard to force huge page to be allocated CMA
area. Should I provide the measurements?
>
> > ...
> >
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -1336,25 +1336,30 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
> >                                       struct vm_area_struct **vmas,
> >                                       unsigned int gup_flags)
> >  {
> > -     long i;
> > +     long i, step;
>
> I'll make these variables unsigned long - to match nr_pages and because
> we have no need for them to be negative.
OK, will fix it.

Thanks,
  Pingfan
>
> > ...

