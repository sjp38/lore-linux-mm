Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48FBDC04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 22:50:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBB9020879
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 22:50:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="geh9IqmP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBB9020879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6A226B0005; Tue, 14 May 2019 18:50:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1A326B0006; Tue, 14 May 2019 18:50:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 908996B0007; Tue, 14 May 2019 18:50:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C0F66B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 18:50:20 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id v16so723087qtk.22
        for <linux-mm@kvack.org>; Tue, 14 May 2019 15:50:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=sBibEd37orYwP+TZJ5qBpxDkSgs2ES/yDrUDzm5pB78=;
        b=U25T5z50fjsfMBLmSNkLhFCzuRnGRAIOff351EA311UpBn1Kqz6zCtwC1jmgG/b0vo
         ntCMUwUvZWoyK1rk0g/9w2vDdBOBfmdQ1vISAUXebfRhRST9esmbVAyliw7CxEt/3sjv
         FSawc58HGJdjhshTMiuYYFiGhgkn9XapnGVKfcKG/Nip22sRmZyytzXDe1iVFM1AiFil
         kYz+BoDXQK+00BzqYP24A4p2DxDIVdhyIapLBgL6swjoYx+koVQ/S+N+vb1tpMQcY86P
         RK9i4XS2XGDULSFv04Ri0lUK10Jq0ofm/0LVEB9ltxDGDmlcUDmZWldyRLFBUTxhY+wP
         0tTg==
X-Gm-Message-State: APjAAAVvGyTpE6yzwW4AbmUx0H4J6khkDDrVyUS2MKwt2NMcUEtOcdGX
	WlE5U6BFQpUZCKdVVDp10GtELBpBxfw1DLOyux98TsUP/7JLU7H6h+35pLCfy63ovwoZG3GpEB9
	a/Rtviio25PFWkAz1LU6A0mfidT8Atngt35HcjT4biOYaMrplpaen7fUS0lpc7vxmsQ==
X-Received: by 2002:a0c:87da:: with SMTP id 26mr10711137qvk.192.1557874220196;
        Tue, 14 May 2019 15:50:20 -0700 (PDT)
X-Received: by 2002:a0c:87da:: with SMTP id 26mr10711094qvk.192.1557874219526;
        Tue, 14 May 2019 15:50:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557874219; cv=none;
        d=google.com; s=arc-20160816;
        b=zkS3ZYx7BRHOvoRo+f7kyR0gaC7zy+hgxlsh68yuF2CklAWa0IbXqtM5KP8lQaeLxL
         thRBUFTPdRwmm/uZr365U0gZfonsP17ZN+Arjhji9uKTTmh3IWDcP1G0HWeuuMBUFyiK
         nY/EPJJgB9b3bfIZeGr2hrihoeoBGjKib61o+/zCwMAig+AnIHRRHzwpU6ievJF/pu4a
         TmSQV2zRIHegRkh/oyTSSDJvh2aLg5FUKkPl1mzo1xFDNfc3qMdoK4Fd30RAMHnkFY6b
         gtnJT3nXSPyN0X6JhC1p+aq8+H2gXrDHymIL1qJ8APWZqhQ/t5wJQL7Mba5b7KxFPeou
         sFCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=sBibEd37orYwP+TZJ5qBpxDkSgs2ES/yDrUDzm5pB78=;
        b=mYzkgJKV/3Q4cipTec9V0fWerq4nd3tatpyqhxs21SjSu6k/qxyFqC2hgEygO4JZH0
         Rpo/XOuALOPUpVGI2omNeTp5X2LkVegYoywJR0x5oSmsxDBgCswxrKUKJsz2c3rPYbay
         zfoqaA2XSRPZ3DKwWYvYvY/RMN6p7a7bEhkiMIY/0Vb2QvmBP1LnDXKXnkBTvqZmcAdr
         FhkBjGfi7ETXzYOpsFjMsDXPwzX/n/TT1H9MKEJdu3dtFfFi64ryI2CmanAWsz3xDmdb
         Pr0GOtBUgb6mVeqK7r2UIVPbVqIYlyCE/BuXnfSiu+p3PW5pPaRXQvgtyFBT/IHbnElZ
         y06Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=geh9IqmP;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o44sor570670qtf.20.2019.05.14.15.50.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 15:50:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=geh9IqmP;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=sBibEd37orYwP+TZJ5qBpxDkSgs2ES/yDrUDzm5pB78=;
        b=geh9IqmPLBJnUYyIo6PAtXPXPLzNqILn5iLKHhl3l7XLKEzLv96wpC28OF3APbM+la
         TOtRGScvJ5U5bTjKE0JlFWhLmkUwdMeuaCdnPmez7BbWHdUuph7Amatgae0AfRhL7cte
         BL0NyLQedCTo9hxX2Pff2SfoYlMCLzn7ev4of0WnzljKeawIaQg3HSp1Oj+oy+2/URdk
         GLJyoFA0tv5AKTt32ZT1fPPz6lCXSy+Rb4lGKs3wFYHaMCYeoEDRlrks9H509X3Blbm1
         UhHSoOhPs/DB6q5rTa4eXS3Ijy2tkLwodP+/UnOCDC/2OJbexQpvrJXfVBHtCMsVIH8r
         hERA==
X-Google-Smtp-Source: APXvYqzOqoD4C9YC9a8iIwRTwQ6rEod1EWH5hmXbAkGou8uu9bNPaymY5aCx1bt1prrRWUNg0zk7S08Hq5eQ/SB1DlY=
X-Received: by 2002:ac8:16b4:: with SMTP id r49mr24380657qtj.157.1557874219298;
 Tue, 14 May 2019 15:50:19 -0700 (PDT)
MIME-Version: 1.0
References: <1556234531-108228-1-git-send-email-yang.shi@linux.alibaba.com> <66e2f965-4f4d-a755-69b3-5342aa761ff3@linux.alibaba.com>
In-Reply-To: <66e2f965-4f4d-a755-69b3-5342aa761ff3@linux.alibaba.com>
From: Yang Shi <shy828301@gmail.com>
Date: Tue, 14 May 2019 15:50:07 -0700
Message-ID: <CAHbLzkqU=O9JmE9Fnie1MzRB_fbD1=3turBtmaRwX-p=PMHHXw@mail.gmail.com>
Subject: Re: [PATCH] mm: filemap: correct the comment about VM_FAULT_RETRY
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: josef@toxicpanda.com, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Josef,

Any comment on this patch? I switched to my personal email since the
mail may get bounced back with my work email sometime.


On Wed, May 8, 2019 at 9:55 AM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
> Ping.
>
>
> Josef, any comment on this one?
>
>
> Thanks,
>
> Yang
>
>
>
> On 4/25/19 4:22 PM, Yang Shi wrote:
> > The commit 6b4c9f446981 ("filemap: drop the mmap_sem for all blocking
> > operations") changed when mmap_sem is dropped during filemap page fault
> > and when returning VM_FAULT_RETRY.
> >
> > Correct the comment to reflect the change.
> >
> > Cc: Josef Bacik <josef@toxicpanda.com>
> > Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> > ---
> >   mm/filemap.c | 6 ++----
> >   1 file changed, 2 insertions(+), 4 deletions(-)
> >
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index d78f577..f0d6250 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -2545,10 +2545,8 @@ static struct file *do_async_mmap_readahead(struct vm_fault *vmf,
> >    *
> >    * vma->vm_mm->mmap_sem must be held on entry.
> >    *
> > - * If our return value has VM_FAULT_RETRY set, it's because
> > - * lock_page_or_retry() returned 0.
> > - * The mmap_sem has usually been released in this case.
> > - * See __lock_page_or_retry() for the exception.
> > + * If our return value has VM_FAULT_RETRY set, it's because the mmap_sem
> > + * may be dropped before doing I/O or by lock_page_maybe_drop_mmap().
> >    *
> >    * If our return value does not have VM_FAULT_RETRY set, the mmap_sem
> >    * has not been released.
>

