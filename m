Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31FE3C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 07:35:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFBD2217F5
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 07:35:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="kssB68xQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFBD2217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22AEB8E0003; Thu, 14 Mar 2019 03:35:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DA2F8E0001; Thu, 14 Mar 2019 03:35:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07AD28E0003; Thu, 14 Mar 2019 03:35:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id C18508E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 03:35:05 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id g24so1972076otq.22
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 00:35:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=c6RmvMGqPWAWxUd3O1lkOdkloNoA8pecp9+CaPLqXag=;
        b=iwnGOcHqQ6I+hnxlV7Nh5A+Y0dXZaZcYqwGD1IfKlidv0g/+Yrf2kHRYUAZkt77XsN
         esV6m4ZmiJM15euECJI29rmPma2Cm3Os2/qd1ZSYfHX+0lN+ybAfnLmT9Q/uVkU5kE9s
         gVTQ9omVBYdhKKlFqdX5516eNsCg7hvx+O8ByxffCiXHJ5uqvmJ6RRPcv6C0uxYaP0Ce
         dJSnbg33qwON9VLq1M9b3TH7E4maTkvV1u5CWKi/m0fklm8U62nBDTojsP10NS+zOoIc
         UUSkiuY8TVApWaygR+ltovGrHQKp032sX9SumsXUNBwg+7J1Df3LTPxuYsO9YzV+86l+
         3ZpA==
X-Gm-Message-State: APjAAAXZMWKKm8i9wuhTpOmYk+kRP16vi9yKrI3qJqHNeEBsy9cEb26T
	y5Vi2KTmk1YPn88Hc7wSKTU2fj1jN7PyX6LEZ9XsiCv7VqSODg/+wK3yrvru9zmpNF+ZRvH6h5F
	yA04ekuSktMrSFkzp04oD2zZ9H2lGuNZzZXkzcYc1NYuxW/C4Mrh90DrhQxuirggEYQ==
X-Received: by 2002:aca:ac45:: with SMTP id v66mr1157515oie.134.1552548905216;
        Thu, 14 Mar 2019 00:35:05 -0700 (PDT)
X-Received: by 2002:aca:ac45:: with SMTP id v66mr1157483oie.134.1552548904253;
        Thu, 14 Mar 2019 00:35:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552548904; cv=none;
        d=google.com; s=arc-20160816;
        b=fRrkW1sp6JEKOqP5nzvdI744V3hOVeEBZ+uVy+2XseV+NBbwCTA4xxkfgwhjCQ59KX
         MCEf+pVPzjSeMSuh4L+VgQqcozG3J6F40W8mgOwCcdS8JE/CrGZWEKus+DVB/ZXqDKWH
         vxMY/L4ULIj5Lb68HtjnAJiextMsgVjGkH8PW/evcUpgjGqj6oA562aUXTSSNGpu83fJ
         enSxL0Q2046W/b+ZU6ktbZ2Ly/7z9WNYZiXCEcWU948fN0WX83EmSJXF0qhhZFMZq3HX
         T23NUVYH507AMR8DV026C9V2FAndll2m3R7HUv/uAr3qVRqY9rI1Rr4yu9QBqeFQmwfp
         U8Ag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=c6RmvMGqPWAWxUd3O1lkOdkloNoA8pecp9+CaPLqXag=;
        b=GUY180kBYzHK3MrYC0AtldPoyIuU3D3h/b3ckd+28oVzPsgJp30/rU9mKsB+p252uz
         /Px8GxESAzwhi7YibFK8EGUGl88oHeaI5CQg4ehJNBhtdZgDPBHghGzNspYyroQ8Ykbe
         KGrbdYk0vNZYfMJgGJunDhjTRtY6iJHCI+s0KiM4F7SnBRPYi/F8AzfwwRjNrYYx/hdB
         4TTLnkX/QP01oXOGAkkCD36Z3n7vipTssYgbzpGU/aSU5fxcorXDvW6e38GSeahG8SVW
         /SBdFLwXungPNF0awolFOU5o/dIiUxRIVL/KaqwXu0bSfOaX3AGS1iLMnVvm2a5siDmx
         dZJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=kssB68xQ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w206sor7247545oie.95.2019.03.14.00.35.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 00:35:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=kssB68xQ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=c6RmvMGqPWAWxUd3O1lkOdkloNoA8pecp9+CaPLqXag=;
        b=kssB68xQ1NRnPFJX7FNmHSCO0La+HESbz0naLhdMQgqa2T91H8PZ6rk//dWr+ohXFP
         Ek43ukZuCzm9YPJwZzGEENEWatpw5bjF62IulpyZjsfDt02VbOheXpfduaiEC5EbJV5I
         rHs11SzGS2bgT239gHPOyDUO/Ae+rPYSJThmQrt+aYyTrVfa0nRqOl/VbHNB6rdoLosz
         vdiSuq3dsQzb7uOV+aPjHXeEPfMXdYZb0fIeTOvkMdkp2k7tnNq/0HyOFNJwfOPkrfpL
         acEUhrsNuz5JxjYBhCZ9UjMrpeMFjMRAA7hvqiUn2eFIicjPlDVDaaT3Fyd3Vn8+u6Vu
         lW1A==
X-Google-Smtp-Source: APXvYqzW8opUf5S7WggMvLFZBVB0rJpKfbciKvNt8CS8zIEq1WM2fTdHY8kO3eJCil2s20yvq7+Em+TzkbT6FUoFMXU=
X-Received: by 2002:aca:54d8:: with SMTP id i207mr1259635oib.0.1552548903501;
 Thu, 14 Mar 2019 00:35:03 -0700 (PDT)
MIME-Version: 1.0
References: <CAPcyv4hwHpX-MkUEqxwdTj7wCCZCN4RV-L4jsnuwLGyL_UEG4A@mail.gmail.com>
 <20190311150947.GD19508@bombadil.infradead.org> <CAPcyv4jG5r2LOesxSx+Mdf+L_gQWqnhk+gKZyKAAPTHy1Drvqw@mail.gmail.com>
 <20190312043754.GD23020@dastard>
In-Reply-To: <20190312043754.GD23020@dastard>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 14 Mar 2019 00:34:51 -0700
Message-ID: <CAPcyv4i+z0RT7rTw+4w-h8dOyscVk1g3F+cu2pKHqqJjTgU++A@mail.gmail.com>
Subject: Re: Hang / zombie process from Xarray page-fault conversion (bisected)
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <willy@infradead.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	"Barror, Robert" <robert.barror@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 9:38 PM Dave Chinner <david@fromorbit.com> wrote:
>
> On Mon, Mar 11, 2019 at 08:35:05PM -0700, Dan Williams wrote:
> > On Mon, Mar 11, 2019 at 8:10 AM Matthew Wilcox <willy@infradead.org> wrote:
> > >
> > > On Thu, Mar 07, 2019 at 10:16:17PM -0800, Dan Williams wrote:
> > > > Hi Willy,
> > > >
> > > > We're seeing a case where RocksDB hangs and becomes defunct when
> > > > trying to kill the process. v4.19 succeeds and v4.20 fails. Robert was
> > > > able to bisect this to commit b15cd800682f "dax: Convert page fault
> > > > handlers to XArray".
> > > >
> > > > I see some direct usage of xa_index and wonder if there are some more
> > > > pmd fixups to do?
> > > >
> > > > Other thoughts?
> > >
> > > I don't see why killing a process would have much to do with PMD
> > > misalignment.  The symptoms (hanging on a signal) smell much more like
> > > leaving a locked entry in the tree.  Is this easy to reproduce?  Can you
> > > get /proc/$pid/stack for a hung task?
> >
> > It's fairly easy to reproduce, I'll see if I can package up all the
> > dependencies into something that fails in a VM.
> >
> > It's limited to xfs, no failure on ext4 to date.
> >
> > The hung process appears to be:
> >
> >      kworker/53:1-xfs-sync/pmem0
>
> That's completely internal to XFS. Every 30s the work is triggered
> and it either does a log flush (if the fs is active) or it syncs the
> superblock to clean the log and idle the filesystem. It has nothing
> to do with user processes, and I don't see why killing a process has
> any effect on what it does...
>
> > ...and then the rest of the database processes grind to a halt from there.
> >
> > Robert was kind enough to capture /proc/$pid/stack, but nothing interesting:
> >
> > [<0>] worker_thread+0xb2/0x380
> > [<0>] kthread+0x112/0x130
> > [<0>] ret_from_fork+0x1f/0x40
> > [<0>] 0xffffffffffffffff
>
> Much more useful would be:
>
> # echo w > /proc/sysrq-trigger
>
> And post the entire output of dmesg.

Here it is:

https://gist.github.com/djbw/ca7117023305f325aca6f8ef30e11556

There are some process stuck indefinitely waiting to acquire an Xarray
entry lock.

