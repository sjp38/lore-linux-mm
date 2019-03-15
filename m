Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41C24C10F06
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 02:47:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E971E2186A
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 02:47:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Z74rZ/60"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E971E2186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 739406B000A; Thu, 14 Mar 2019 22:47:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E8E36B000C; Thu, 14 Mar 2019 22:47:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B2F36B000D; Thu, 14 Mar 2019 22:47:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2053F6B000A
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 22:47:06 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id g24so3364538otq.22
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 19:47:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bJhpfCDr4VJLjBMlqnhNun7Rslw2CS5YSbfu/CWVxC4=;
        b=Uln5pKUhtbRwZs9nxscsq0xRwqDMp4SB8K41Y3xO9e0/wka/9qkFfJe1rx5HPpEwKm
         uG1LmoU6vwkvgElJKr+WVSU00KJhjlfRMgYlNehpOohXXFX4gBb0CNo6CfFB8tpIHwm9
         3pUkEV9CNCi9YJCBntT6L2A5Tq+f6PyzLsVA09LkpamOUvQsTSEpFDgbxeYFpTczvJKT
         tA4a3jvExVrY+gSot08CZtpvPD4HLfGCqyU5X0V8MozVfLQhNZNFlYefh9EkJAGXws2P
         jeFl1jeLeARLp3PV3lBx4yGt5kEVtX+PbcDAAUcApm0/LXLyiurdSpuDEBZB+RZ3KHDj
         S8jw==
X-Gm-Message-State: APjAAAUiuj7K/2U1LbSkRPpTfoSMQ8B8qcWMlYGu2NvzKlit/Ex/RyGy
	c1xAHihKlYJdzWu4+stNDk/FoPRUBMzgR7Bw54Hvq6XZGAIP+37kpMvoWSFcHYPslDV2D0QD1y6
	onBmD2K24AAm+JhGF4P/IfFMng9PjKJyDZS2nEDRpmusUcLhsujGAc4psShzJoOU/Mw==
X-Received: by 2002:a9d:748f:: with SMTP id t15mr826182otk.80.1552618025666;
        Thu, 14 Mar 2019 19:47:05 -0700 (PDT)
X-Received: by 2002:a9d:748f:: with SMTP id t15mr826150otk.80.1552618024691;
        Thu, 14 Mar 2019 19:47:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552618024; cv=none;
        d=google.com; s=arc-20160816;
        b=iAP07cXl7GXZRX09Wf4Raw7FyirYjGmAfHg0F4Q/j42rYAD+jdC+odPRqq8Y7O1d04
         vLwE3GQAlw3Q+3gcVkJPRarF84lLP0rkAD11usb0bKUCnhbxz9cknLC9hZ+862cl615K
         CiXs/zMRpOpRwv0Wn48bi6fP8KQTj5+XFodkLUtWxgqRqI+JYn2ZpFLVTPTtdbAVlIZ7
         DH9ZSJ1ajU5pt5al093QPWfPKMpt9q5TeufIzFWr1wARBIbxOI4IIXPlh9qK1XXt5A4S
         jM6Gefr2eTm+txSButTGCzWpwWFehrN0H1x4v4kr1lDycDDo2p/M8TfZT65vrEckWEax
         6JJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bJhpfCDr4VJLjBMlqnhNun7Rslw2CS5YSbfu/CWVxC4=;
        b=jlrSyP6kZhEPLzV0GUYYeykzpLzjUre0xtZpfVLfH5oJDkWkdB5CH+fz42zsxtTwyv
         nMTdeFEz2q21G/emdsjvLTsx9uZEhzM7IXJl14JxaQX6bReogrHnD0eC6ylLpVZGfA46
         +21O4O/XJW6y5wTNwrNpm9ngQfOe8v7S9v2jbUnA2Ji7r/w0tFY6tDhMh7G8M0xY3hRz
         h9bF5KM9RnY1Q+Jf7G4zLRhuEHqVWIeR1R4DNlXSa41FpMflCdZxGhtgCiloVi6bI13p
         2O7AFjBNbgxYdErvuhD6GHTKg5seqQ779obn1Ay87nqV0y11sSaECGpJX0/aN1yT0oJ3
         YQpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="Z74rZ/60";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g14sor407630otq.142.2019.03.14.19.47.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 19:47:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="Z74rZ/60";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bJhpfCDr4VJLjBMlqnhNun7Rslw2CS5YSbfu/CWVxC4=;
        b=Z74rZ/601dKyWRg1moosLR8ia5qVfh81mg52QDNd2P7r5+3kpBuOcQx23LmC4neFVu
         PTlihjhFJeDSKGtVq3Hm0BG3dJ0Nu4+pR7fFgfW6XxwUACzoCqmeV4sln3MB+lKQfBXZ
         rLUwJEoosqhfFNTJUB2d7i4ZcGZ42IFPySyyBcx8+AzStdYpYaCURi7y9VLqh6CY85TK
         poBYYBAzkhhY2HOvRjskZoh3ULsn0IAM0frwttNbFObg5GiGpC6h+BpV+DTkJHNbh1bn
         yEcaloG5Yu6PpA5F8EtTITHIRXfOoydgvejpPIPGZQGVcgEbQ+wLxtfgRJ5e5TueB2y4
         gaKg==
X-Google-Smtp-Source: APXvYqy4YFfX39pSNL/fWGYab22UNmFC7UynZVik9eYEqntmCgCb31KqYxucgvTWDDYUeKQ8td0aYMQY97yhdkzDR8U=
X-Received: by 2002:a05:6830:1c1:: with SMTP id r1mr749010ota.229.1552618024016;
 Thu, 14 Mar 2019 19:47:04 -0700 (PDT)
MIME-Version: 1.0
References: <CAPcyv4hwHpX-MkUEqxwdTj7wCCZCN4RV-L4jsnuwLGyL_UEG4A@mail.gmail.com>
 <20190311150947.GD19508@bombadil.infradead.org> <CAPcyv4jG5r2LOesxSx+Mdf+L_gQWqnhk+gKZyKAAPTHy1Drvqw@mail.gmail.com>
 <20190312043754.GD23020@dastard> <CAPcyv4i+z0RT7rTw+4w-h8dOyscVk1g3F+cu2pKHqqJjTgU++A@mail.gmail.com>
 <20190315022604.GO26298@dastard>
In-Reply-To: <20190315022604.GO26298@dastard>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 14 Mar 2019 19:46:52 -0700
Message-ID: <CAPcyv4gQBQH9wOz+=dUndmhyLZNsuSWdYALyVkR6n0L=uEiQaQ@mail.gmail.com>
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

On Thu, Mar 14, 2019 at 7:26 PM Dave Chinner <david@fromorbit.com> wrote:
>
> On Thu, Mar 14, 2019 at 12:34:51AM -0700, Dan Williams wrote:
> > On Mon, Mar 11, 2019 at 9:38 PM Dave Chinner <david@fromorbit.com> wrote:
> > >
> > > On Mon, Mar 11, 2019 at 08:35:05PM -0700, Dan Williams wrote:
> > > > On Mon, Mar 11, 2019 at 8:10 AM Matthew Wilcox <willy@infradead.org> wrote:
> > > > >
> > > > > On Thu, Mar 07, 2019 at 10:16:17PM -0800, Dan Williams wrote:
> > > > > > Hi Willy,
> > > > > >
> > > > > > We're seeing a case where RocksDB hangs and becomes defunct when
> > > > > > trying to kill the process. v4.19 succeeds and v4.20 fails. Robert was
> > > > > > able to bisect this to commit b15cd800682f "dax: Convert page fault
> > > > > > handlers to XArray".
> > > > > >
> > > > > > I see some direct usage of xa_index and wonder if there are some more
> > > > > > pmd fixups to do?
> > > > > >
> > > > > > Other thoughts?
> > > > >
> > > > > I don't see why killing a process would have much to do with PMD
> > > > > misalignment.  The symptoms (hanging on a signal) smell much more like
> > > > > leaving a locked entry in the tree.  Is this easy to reproduce?  Can you
> > > > > get /proc/$pid/stack for a hung task?
> > > >
> > > > It's fairly easy to reproduce, I'll see if I can package up all the
> > > > dependencies into something that fails in a VM.
> > > >
> > > > It's limited to xfs, no failure on ext4 to date.
> > > >
> > > > The hung process appears to be:
> > > >
> > > >      kworker/53:1-xfs-sync/pmem0
> > >
> > > That's completely internal to XFS. Every 30s the work is triggered
> > > and it either does a log flush (if the fs is active) or it syncs the
> > > superblock to clean the log and idle the filesystem. It has nothing
> > > to do with user processes, and I don't see why killing a process has
> > > any effect on what it does...
> > >
> > > > ...and then the rest of the database processes grind to a halt from there.
> > > >
> > > > Robert was kind enough to capture /proc/$pid/stack, but nothing interesting:
> > > >
> > > > [<0>] worker_thread+0xb2/0x380
> > > > [<0>] kthread+0x112/0x130
> > > > [<0>] ret_from_fork+0x1f/0x40
> > > > [<0>] 0xffffffffffffffff
> > >
> > > Much more useful would be:
> > >
> > > # echo w > /proc/sysrq-trigger
> > >
> > > And post the entire output of dmesg.
> >
> > Here it is:
> >
> > https://gist.github.com/djbw/ca7117023305f325aca6f8ef30e11556
>
> Which tells us nothing. :(
>
> I think a bisect is in order...

Right, you missed this earlier in the thread, bisect points to:

     b15cd800682f "dax: Convert page fault handlers to XArray"

