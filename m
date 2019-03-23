Return-Path: <SRS0=0AWy=R2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D0EAC43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:40:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 179E321874
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:40:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Zj7Ay7z3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 179E321874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 692756B0005; Sat, 23 Mar 2019 00:40:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 602E36B0006; Sat, 23 Mar 2019 00:40:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F12D6B0007; Sat, 23 Mar 2019 00:40:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 020316B0005
	for <linux-mm@kvack.org>; Sat, 23 Mar 2019 00:40:18 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id x9so1492655wrw.20
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 21:40:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=RnFhmYoB5biJQdWPhT7W4h51OqxNsziYkvqXdOPjJYQ=;
        b=qxIoSyiEuH11fJtBdEuyjnwIjUq+sUo5AA8MODptCfvtx1y5wyJyHVZXGFBrdCGfOe
         PPA7w+ApCyTOiDuIvKNsWG4sEke21A2vyRx94V3vC3XFbbHb4kJYm01V97ntfxUNe647
         V0AFTQXwW9tvujMxni4Mg8uWXATfH+Gt60FsEzwfTV/+DN0MFsD4Kl163ZQZ/llczRnW
         1irAutDhW9KWTYTM1izbDqRwjo1y3SjqZmlnfYtI1r8FePkmL5g4t2eHwtCzpA5FLpS0
         c2w2rH8yuFaP9LfRNbFYeoSV+v3zYDDp+LqdUei8I5yXETulMbvBwGT6eg0iwtR9rwWA
         sLiw==
X-Gm-Message-State: APjAAAXFr/MBXZFORrL4AAZDglRroUGTxDCuUdH3rUy+RbfSL+jAShmP
	+tNd+6DO4lw12IJgySixUF405F2Lx+0yg+urJF5WvmTOfm+3isUzNgMS7tKUcjqfQTU8huDWlU3
	nz0LzoYqcag1cIx1/73Z19rcrHQjFuWRB8dhM/WwCSNcCmG2dP3r8qN9bqyFQgP2jag==
X-Received: by 2002:adf:9427:: with SMTP id 36mr9056617wrq.128.1553316017291;
        Fri, 22 Mar 2019 21:40:17 -0700 (PDT)
X-Received: by 2002:adf:9427:: with SMTP id 36mr9056593wrq.128.1553316016492;
        Fri, 22 Mar 2019 21:40:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553316016; cv=none;
        d=google.com; s=arc-20160816;
        b=xbn6YZbh/ce0Q20I4o+M8s76Yizozpw9HZvs++OnN/YEe8loQlEz1yzUjAsZqiMDaA
         sawj0E7P4S5m3SbMGa3AP8uEoW/usyFwSz88Esix0lgsFCGudfR8J1Hg9qXOXDzGNQwY
         75SHHY2rWTjcVs52ABE43xFgK638Y72ldgZUQ0Fnvgu5frfKodN5oNsl+REQgXiIh0dp
         vG7jB6z66KiBqPPl72plNW7TKn5b4IxH7GXCJjlTWWDLef7BfqtzF9NRe5+rWzAQuEri
         JRacLxWzEvsxKvzd1Y3wi5x7jZSRfYOqqPQQLu4nAxVs1w+ywtJLdUWsQJ1cZwCl4zRj
         v5ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=RnFhmYoB5biJQdWPhT7W4h51OqxNsziYkvqXdOPjJYQ=;
        b=lh8OHkXdrHH5+MLwWKmgmi1DRMV90ry/vIkefu6N/fsd18dQXQFnYX8M8zOE8pPjwb
         KOOKdVDS3r0YaJJk5UtXlhU75vU+978q+mZYRrs3MPme63IUiYDzpOANvCOlg+RXXh40
         Ltnr6T0PdONoW3X99rR/EYTXsMMdk/bQP+Ucm0ivk2q5gF7nSZ+MqFF2FXV93eCyLteW
         SxxtzZgzrCYv9TTxCPmJHpTkI/3KNqmxlJY5IAQpAEnT5Hx2nCTayEGsPUFNTe5S2MWe
         hPKWLqz3cS+fuU8aAXv33gswS+pk6HCltaIdGWvc1GTaROjtElAUcyvOUHfIllFDBQjt
         4aWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Zj7Ay7z3;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r6sor6604070wmc.2.2019.03.22.21.40.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 21:40:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Zj7Ay7z3;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RnFhmYoB5biJQdWPhT7W4h51OqxNsziYkvqXdOPjJYQ=;
        b=Zj7Ay7z3C2/8l1E6GV9mrDIAaID1iukZRMH1FrGU00ZAir3J6x7O7YsmeMEypVNyG+
         Bs6acn8zH5DMzrPRSps0OdIsFls2hM5wsjPnpZ6ZR6UaCEHLnTh9dTT/agv9NjyT3Syi
         q4I1Faq0A7rFnrribxBDw/0OQKx2lzDmO2fft1ZBqK4uwpSTb0fr1SUhOByiVcK97vVz
         2HKy8LomTvYs+A85JXdsryzLktWaUQMnL5t3Jc686rBwdkg3u/rhHIJmXR4QW6NYK5f+
         EbLqweneoVXAP5mhlwrvzfY0YzCBb64abTeXcJRISlRuYAu6bOy9UpIJmvM5klAUtFFX
         klSQ==
X-Google-Smtp-Source: APXvYqws4tycxCWdZIvBKm7TYw3MIN1pwX9t5LLkfy344HWVOciQYgKJCcPccaSOgxyChjNHwfXI3HdCQWzgy3wZMpw=
X-Received: by 2002:a1c:e143:: with SMTP id y64mr4704141wmg.141.1553316015947;
 Fri, 22 Mar 2019 21:40:15 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
 <CABXGCsMcXb_W-w0AA4ZFJ5aKNvSMwFn8oAMaFV7AMHgsH_UB7g@mail.gmail.com>
 <CABXGCsO+DoEu5KMW8bELCKahhfZ1XGJCMYJ3Nka8B0Xi0A=aKg@mail.gmail.com> <20190322111527.GG3189@techsingularity.net>
In-Reply-To: <20190322111527.GG3189@techsingularity.net>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Sat, 23 Mar 2019 09:40:04 +0500
Message-ID: <CABXGCsMG+oCTxiEv1vmiK0P+fvr7ZiuOsbX-GCE13gapcRi5-Q@mail.gmail.com>
Subject: Re: kernel BUG at include/linux/mm.h:1020!
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, Qian Cai <cai@lca.pw>, linux-mm@kvack.org, 
	vbabka@suse.cz
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 22 Mar 2019 at 16:15, Mel Gorman <mgorman@techsingularity.net> wrote:
>
> Build-tested only but can you try this?
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index f171a83707ce..ba3afcc00d50 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -242,6 +242,7 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
>                                                         bool check_target)
>  {
>         struct page *page = pfn_to_online_page(pfn);
> +       struct page *block_page;
>         struct page *end_page;
>         unsigned long block_pfn;
>
> @@ -267,20 +268,26 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
>             get_pageblock_migratetype(page) != MIGRATE_MOVABLE)
>                 return false;
>
> +       /* Ensure the start of the pageblock or zone is online and valid */
> +       block_pfn = pageblock_start_pfn(pfn);
> +       block_page = pfn_to_online_page(max(block_pfn, zone->zone_start_pfn));
> +       if (block_page) {
> +               page = block_page;
> +               pfn = block_pfn;
> +       }
> +
> +       /* Ensure the end of the pageblock or zone is online and valid */
> +       block_pfn += pageblock_nr_pages;
> +       block_pfn = min(block_pfn, zone_end_pfn(zone));
> +       end_page = pfn_to_online_page(block_pfn);
> +       if (!end_page)
> +               return false;
> +
>         /*
>          * Only clear the hint if a sample indicates there is either a
>          * free page or an LRU page in the block. One or other condition
>          * is necessary for the block to be a migration source/target.
>          */
> -       block_pfn = pageblock_start_pfn(pfn);
> -       pfn = max(block_pfn, zone->zone_start_pfn);
> -       page = pfn_to_page(pfn);
> -       if (zone != page_zone(page))
> -               return false;
> -       pfn = block_pfn + pageblock_nr_pages;
> -       pfn = min(pfn, zone_end_pfn(zone));
> -       end_page = pfn_to_page(pfn);
> -
>         do {
>                 if (pfn_valid_within(pfn)) {
>                         if (check_source && PageLRU(page)) {

Unfortunately this patch didn't helps too.

kernel log: https://pastebin.com/RHhmXPM2

--
Best Regards,
Mike Gavrilov.

