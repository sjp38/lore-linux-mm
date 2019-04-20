Return-Path: <SRS0=t1VS=SW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52FBEC282DD
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 16:34:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAA8B20869
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 16:34:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="lQ5hlKkn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAA8B20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 447416B000A; Sat, 20 Apr 2019 12:34:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F74F6B000C; Sat, 20 Apr 2019 12:34:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30D106B000D; Sat, 20 Apr 2019 12:34:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1A56B000A
	for <linux-mm@kvack.org>; Sat, 20 Apr 2019 12:34:39 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id c21so3355293oig.20
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 09:34:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2nkNuARp9X01dKfEBOtMwOp996ppluuGSD9cN/HBKF0=;
        b=GveRfrYpqVvCtRb7tSAhwlKLwSo22N9Pem7Hw8VdvZ4tWCdJwf4r5lLm+VQh1n4cJ5
         vl/7BWJ1n69OA6infW2S0VjpulQ3xxOCLUB8xuxF+mPoAsKJNlZGTWXLeJKUyUrn5L6g
         8xhMy8R3y1zwDcMydELuK153rvaemDsoqjpH5xObsnX9pzhRPmeRm99GoVoqKxJAGXx/
         lK3QmEDWCFN1fLQqY3N2KbQIymHeH624xDiBA+/eax9EOS2Zhw4Z9DNVDXNZDb760QIh
         VEY9Kz2IsS5XBVCJJSCf+97/jQNTwIO7ukj3WNGOXdsGk+4bGWPwiM9xDL0GSSOfUTBr
         tQNA==
X-Gm-Message-State: APjAAAWIdlX/LoQRQJOyBBpTluFUSU0SaWsgVyrGFJPbcc9EQ8GkCADM
	cXC8XJ+0KWouTN1RWZh9EoAaxHzaeKnuO9ahUJun1uGw4LO+lj99c9Xd3MnEuy6wj7P9jGz12tW
	VFPK+Hc1Crqj3OdXssQ2CBw5K7OQd3nhdiFVp0Uj40HGIf0tn3Bp5eKBd7fRciVg+iA==
X-Received: by 2002:a9d:51d2:: with SMTP id d18mr6254997oth.61.1555778078777;
        Sat, 20 Apr 2019 09:34:38 -0700 (PDT)
X-Received: by 2002:a9d:51d2:: with SMTP id d18mr6254977oth.61.1555778078236;
        Sat, 20 Apr 2019 09:34:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555778078; cv=none;
        d=google.com; s=arc-20160816;
        b=URwt2fhEKrERXzYuQ25INp4QQkc96peNjUfgHZ6QtObQtI4KGuE26ayEfQypk+hOB7
         bfHTDrV7CRkScXpBU0PbKx3TT9X79xGup99/Fa+azIziitM4elgdmh5VcKRovaoc+cjE
         FDeR1MZ5LerNaA6rVGGMi73G5A7FXhyQyv6HxOcmyBR7OCLfjFzFKfLgUv0iyLlBWjR8
         05BoCT1qBQ1z+DlxYaW0Eb4HxsYKvuh3TJV60fKaL7/FKPtbOPIhwGxt6mODcC+jLO56
         L5RxjZkhdXAlQqrpcaSEA0I+rNrPZXF0K4yy4lt/qMm1k+6WhJVBfOtNwXlU2A1btgz5
         wLqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2nkNuARp9X01dKfEBOtMwOp996ppluuGSD9cN/HBKF0=;
        b=PI6gYOA6hdq8ewt0FZH+0vvjytYzVeYLl4kw9IPiVGjbUcl16tdFlCAZLYeNtazKL2
         9m+QotLkTofnhx67RmVYGwCHbLZW4sUufrkHjHfsxMkwqvCD9hwroSTwhRNiJiHCgLOr
         rwWgCREJJJaNufj8GkrpJZyCL8000YTBa7KFE/x9ut66KOgJQJEU4HFtrh6CCpubzAbk
         wxroPr6+Sw/dFKNMynqKPjrO+kOaTHSnEssaVJwI2DnX6H4AWQ2G0VXqucBKYx9XmzgU
         0rrFEVRKqlcX4sSJPRPgZ745I2XkjJlhYMomXIl2F7yWzWcsUV+wCU//gIBeY7FigGau
         t8DA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=lQ5hlKkn;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v2sor3740919oib.165.2019.04.20.09.34.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Apr 2019 09:34:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=lQ5hlKkn;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2nkNuARp9X01dKfEBOtMwOp996ppluuGSD9cN/HBKF0=;
        b=lQ5hlKknHgUdIgtdCdSW+BlZNAFfLwu4hWsS9k88Ag24YEMBmAwCWE3/CkQVyeYzeg
         3DBa/mRqMobf0jbS4KDLFQpX2/bLaOPnc0J0DAzpIxxqngPpoOFIZcZ1Ig2O2j1EO3wf
         GAun3ArtW1LScidQo9nzjwulZ5rXl5sF8L72MNAsiCJCkFtoO5KK4A8jdV4ivGcF97H+
         I44a7FkspL8ec+mXvswIjUGz6vQ1DsIc+M8DgUzXLsv2YU7wNEYsP/zx7o4x1/zNh3AH
         Tv/+hv9FI06FU/1rSvaLo8VX4p/Z2DHQwjQ2PjY8ERIoNlVwd9PcVwuwgdbAyuDsq3tt
         oQRA==
X-Google-Smtp-Source: APXvYqwPxWJkMWqyvsgPZQqhL3+W5zzE3UErLcb18t7ERNXhzlO8we8FPAnQV+jOk6LI1G7NFpMMK/IvtwiYI/3C0cA=
X-Received: by 2002:aca:d513:: with SMTP id m19mr5252902oig.73.1555778077724;
 Sat, 20 Apr 2019 09:34:37 -0700 (PDT)
MIME-Version: 1.0
References: <20190420153148.21548-1-pasha.tatashin@soleen.com>
In-Reply-To: <20190420153148.21548-1-pasha.tatashin@soleen.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 20 Apr 2019 09:34:26 -0700
Message-ID: <CAPcyv4h73gUwntDYx012qcyMYCmzZDU3HOvKcW5DRkO-GoTc+w@mail.gmail.com>
Subject: Re: [v1 0/2] "Hotremove" persistent memory
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
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

On Sat, Apr 20, 2019 at 8:32 AM Pavel Tatashin
<pasha.tatashin@soleen.com> wrote:
>
> Recently, adding a persistent memory to be used like a regular RAM was
> added to Linux. This work extends this functionality to also allow hot
> removing persistent memory.
>
> We (Microsoft) have a very important use case for this functionality.
>
> The requirement is for physical machines with small amount of RAM (~8G)
> to be able to reboot in a very short period of time (<1s). Yet, there is
> a userland state that is expensive to recreate (~2G).
>
> The solution is to boot machines with 2G preserved for persistent
> memory.

Makes sense, but I have some questions about the details.

>
> Copy the state, and hotadd the persistent memory so machine still has all
> 8G for runtime. Before reboot, hotremove device-dax 2G, copy the memory
> that is needed to be preserved to pmem0 device, and reboot.
>
> The series of operations look like this:
>
>         1. After boot restore /dev/pmem0 to boot
>         2. Convert raw pmem0 to devdax
>         ndctl create-namespace --mode devdax --map mem -e namespace0.0 -f
>         3. Hotadd to System RAM
>         echo dax0.0 > /sys/bus/dax/drivers/device_dax/unbind
>         echo dax0.0 > /sys/bus/dax/drivers/kmem/new_id
>         4. Before reboot hotremove device-dax memory from System RAM
>         echo dax0.0 > /sys/bus/dax/drivers/kmem/unbind
>         5. Create raw pmem0 device
>         ndctl create-namespace --mode raw  -e namespace0.0 -f
>         6. Copy the state to this device

What is the source of this copy? The state that was in the hot-added
memory? Isn't it "already there" since you effectively renamed dax0.0
to pmem0?

>         7. Do kexec reboot, or reboot through firmware, is firmware does not
>         zero memory in pmem region.

Wouldn't the dax0.0 contents be preserved regardless? How does the
guest recover the pre-initialized state / how does the kernel know to
give out the same pages to the application as the previous boot?

