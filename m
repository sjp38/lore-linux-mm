Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77CD3C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 21:34:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 031DA20835
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 21:34:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="cAwbB9Jr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 031DA20835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 636916B0007; Wed, 24 Apr 2019 17:34:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E6046B0008; Wed, 24 Apr 2019 17:34:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AEC36B000A; Wed, 24 Apr 2019 17:34:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 10D796B0007
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 17:34:58 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r8so1559878edd.21
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 14:34:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Y/Haum+Q0Tq67LT+lgDVhjDSLBZNQProc5ALAzxiJIE=;
        b=oD0wz/Rl09spyCig8etW1jQ9pmgeU/qb8/ebiVElr+hRnrd9IqsikIlShM4amNqS6J
         /RgBQlyMTH5MtK6RS/hWQBgX9deV+xi6BBaYvqWH+S8XTpQI8iaCkiNpd9m+GYHHAwj0
         A0/keWapDgOT8y2JIpK7pQrfvWeCXkqkme4lao7ybw5a8McrlguDmOjg4uv9ItYb+Yc8
         5B4RVipcjutnEGG1ZlIg7KEMPRvkfXKxbb4wxMEMtyV70flM+u6ZMhikVG3Ut8uwzlXq
         x1l6t81RhSkmXYPrOx2Fg6pbSGfDn9Z8FuA7ftgB5RKenBcIuupa43gQBFrf1Qyhi6R1
         gNCQ==
X-Gm-Message-State: APjAAAVQoX8Jfx8dHGO6EkRGAjxNcIbynoikghKJgsI7on7aq51oCraw
	NUwn7P9DQUpp2+miiToAVXdQNK/ey1e5wCrxwbKz2EDKyHzg1woCNHOuSA3A+GFZ3yBz01xDtda
	JKj4moSty82/8h9xobo91351KfgoePX8eLn2zV+HaE54dMh9b4geYPtINqH6cn/tRMg==
X-Received: by 2002:a17:906:944b:: with SMTP id z11mr1125050ejx.151.1556141697522;
        Wed, 24 Apr 2019 14:34:57 -0700 (PDT)
X-Received: by 2002:a17:906:944b:: with SMTP id z11mr1125023ejx.151.1556141696701;
        Wed, 24 Apr 2019 14:34:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556141696; cv=none;
        d=google.com; s=arc-20160816;
        b=heAROnKHoibv7+ktzU9elkB6AX86qW0p5G9/XBkISbSyqOeAneChC9/9XIHKEDzre7
         kymH+vf0sIW9rlscBHxAa/080sfF+pBvmuDCK+/JHVX1pUdroarEVjMVREbRi/WY1Y8t
         2ZIPTas+cp4fCj7gitsxEfA1N4Op86dGzpH9oLawtacDP0zoU3zXGV6/+6+4usUfVyzG
         yatlu0RC5xO15Qqpp8H7+gzPl/r6t44vNquXAcNyOs6sML0rOzKz/oQ9yQVhoncOo4+O
         1lsBBlgrhAGDTGDCyziKQfcpZeas6UjmJ/cgofPtnRvxq90QKQVJTcloyZ9a2pt0qz4d
         aVnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Y/Haum+Q0Tq67LT+lgDVhjDSLBZNQProc5ALAzxiJIE=;
        b=qDti0WAtrhWrm0LrKzZs9vtm6+ErLnayl1scYwDI+m30YWuhB3fmBkSF8UqJ7zeejr
         L89tDHgBsMy420+zJFAZRbovpWUExYBxBYyfJ06Mr+pVQ2qQ8VITEjMLK0WHF90Wnqvq
         BuHoismg2404v/MI+qgf6fyhmdRCloK5tZBvm0ojR3SZQmscLuheT3ALfV0tmwiu9BLt
         0o6qYuhctUk8a2PxZrqpjQM0uGVog5/EjaT/ploe7zvvvC6X9LI7EMvFsqlNemdxHTVv
         I9S9Nl9OjOCfWb/KLcReNa5yxYLiLrbw4muY6CApOFSAikVzI5PFndxTk6bFBklrNbWD
         fUqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=cAwbB9Jr;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e25sor1603308ejc.18.2019.04.24.14.34.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 14:34:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=cAwbB9Jr;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Y/Haum+Q0Tq67LT+lgDVhjDSLBZNQProc5ALAzxiJIE=;
        b=cAwbB9JrYP5QxhlwvuMdvdpA/ZsEiPfp9Oo18cK5lc1PLwGEuU52GQ5fgDi7K9on6l
         /VnQBR8ptusfL7wNOtbygpxerdwYUYrO+4a/VaSSSD/weFcWpLVTmaIZlhOUq3ehQGlW
         hSYXwrddTV4ayCT07Suk56HCGoGeNg+YXSnNd33lPboBbs98njPt7+JEfTQbv/es4Iji
         R91OTj1zR1fJNbeDlcVyuAJ3fqsG6Fv1AlVNh5k5TkhqSXFYMVoVmHo/eFPvb6YlC900
         mVArULVKGxcnY620A6h8WEBJ1JA7yMNtfccwIARWCHT48RM0hX+SWfTSiw+5ze9XmIoY
         nBkA==
X-Google-Smtp-Source: APXvYqyw22yehyfckHGABFZjJ9k6UmdAua6ix/uaYi0Qv9TrVQhsLWKpvHjhVIsMkfhz6j7gMzL0YwmKiJYpYflTGzk=
X-Received: by 2002:a17:906:944b:: with SMTP id z11mr1125008ejx.151.1556141696280;
 Wed, 24 Apr 2019 14:34:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190421014429.31206-1-pasha.tatashin@soleen.com>
 <20190421014429.31206-3-pasha.tatashin@soleen.com> <4ad3c587-6ab8-1307-5a13-a3e73cf569a5@redhat.com>
 <CAPcyv4h3+hU=MmB=RCc5GZmjLW_ALoVg_C4Z7aw8NQ=1LzPKaw@mail.gmail.com>
In-Reply-To: <CAPcyv4h3+hU=MmB=RCc5GZmjLW_ALoVg_C4Z7aw8NQ=1LzPKaw@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Wed, 24 Apr 2019 17:34:45 -0400
Message-ID: <CA+CK2bDB5o4+NMc7==_ipVAZoEo7fdrkjZ4etU0LUCqxnmN-Rg@mail.gmail.com>
Subject: Re: [v2 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: Dan Williams <dan.j.williams@intel.com>
Cc: David Hildenbrand <david@redhat.com>, James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Keith Busch <keith.busch@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, 
	Dave Jiang <dave.jiang@intel.com>, Ross Zwisler <zwisler@kernel.org>, 
	Tom Lendacky <thomas.lendacky@amd.com>, "Huang, Ying" <ying.huang@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > > +static int
> > > +offline_memblock_cb(struct memory_block *mem, void *arg)
> >
> > Function name suggests that you are actually trying to offline memory
> > here. Maybe check_memblocks_offline_cb(), just like we have in
> > mm/memory_hotplug.c.

Makes sense, I will rename to check_memblocks_offline_cb()

> > > +     lock_device_hotplug();
> > > +     rc = walk_memory_range(start_pfn, end_pfn, dev, offline_memblock_cb);
> > > +     unlock_device_hotplug();
> > > +
> > > +     /*
> > > +      * If admin has not offlined memory beforehand, we cannot hotremove dax.
> > > +      * Unfortunately, because unbind will still succeed there is no way for
> > > +      * user to hotremove dax after this.
> > > +      */
> > > +     if (rc)
> > > +             return rc;
> >
> > Can't it happen that there is a race between you checking if memory is
> > offline and an admin onlining memory again? maybe pull the
> > remove_memory() into the locked region, using __remove_memory() instead.
>
> I think the race is ok. The admin gets to keep the pieces of allowing
> racing updates to the state and the kernel will keep the range active
> until the next reboot.

Thank you for noticing this. I will pull it into locking region.
Because, __remove_memory() has this code:

1868   ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
1869   check_memblock_offlined_cb);
1870   if (ret)
1871      BUG();

Basically, panic if at least something is not offlined.

Pasha

