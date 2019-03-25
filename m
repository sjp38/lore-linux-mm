Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1A27C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 23:37:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87DE2207DD
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 23:37:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="nLkSN0Dd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87DE2207DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E3916B0006; Mon, 25 Mar 2019 19:37:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 292646B0007; Mon, 25 Mar 2019 19:37:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 15B356B0008; Mon, 25 Mar 2019 19:37:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id E01926B0006
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 19:37:20 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id 70so1232809otn.15
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 16:37:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=iOEBRSaUhydJ0VsiYrBtWnd84J72N11uWSTNWpUMqGM=;
        b=gEM812UoyouEBhNVKBN7HX1r0aHkIhxV094emJZ1SNXT0+5FOVTJoaArnDQtNDOHsf
         skN/eMcOcXpUxa71CcBRpxMBKGfWUki+FEgE1Xw11jJ6vuOpiN+oxAfjBp//WeACcwI4
         P++SobXYnC9izVNNUoOPO/4NtZGXvvnKCnwXZ2dop+u5AmaYtVJB7nRFVNO5n854EbXf
         nsg8mDiu5IdfmJLRtwNxlWY5c0yrsWZVcdna9MmnxXiDiHk/QuhauR49yiYIrsvfZ/Lm
         uxVAxqObkdVZRGcgYSpz6gRrVUMu7QkOmJ+e3v27p8dlng7eXqYtyao9QfyLoFBp/S7L
         K6ng==
X-Gm-Message-State: APjAAAWijPuYmcJ0UHjZOHvcfJXeebTkD+ayPWjzP0EFxDaeVuY0629e
	rIPXnJjp5y95jUcuQubL/IyfhD304YIYrKgqNDTCrD7t2PYftXfoUDSOPoeUR73CqjkPwNJT3ws
	Sak4Hl7fcVuNVa56anSWuzoX6Sge/CD0K6CLKVk/VDncQXh0Dk1v18vnYetiXV3Uqlg==
X-Received: by 2002:aca:407:: with SMTP id 7mr12675858oie.90.1553557040495;
        Mon, 25 Mar 2019 16:37:20 -0700 (PDT)
X-Received: by 2002:aca:407:: with SMTP id 7mr12675838oie.90.1553557039900;
        Mon, 25 Mar 2019 16:37:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553557039; cv=none;
        d=google.com; s=arc-20160816;
        b=dtGNxosic5U7vm7S0QFihlpGsqO4Fdtd27YzX7wMc/bbp+9pCLdo+iitkmVJquLT2T
         ZJ8j2bGFEutSCDdstv2zG1BppmKnodwRt45mA3d8FPmDFFmI7XjMfsN++2Sy1PZKldso
         7j/YmMdXQ2Lfj/lQ/kbNqFHcka6bK0kAOKfjxfeOrpYnWetJDA7Fp+DrHyolmTgjhO2N
         x1vtL5dwCJV6nLIYMWWx3hUcskiqzHaq6TXWsBlfReDeWxqUR3NBOGefUhBFmsVkuueS
         3W+T+2tNX8+UVBxcJcBDtdLLHABppV4hq5b2U3mWwDtxOW98cm00lhLAQnSFlmHY4Czt
         FKJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=iOEBRSaUhydJ0VsiYrBtWnd84J72N11uWSTNWpUMqGM=;
        b=sjhkv4FcGvAlyx8bglHhveTeGXyX/UkpkYpfnTyxPbmunwbgfcSx239z01k5tS6Twb
         GME0PhiY299nQhA1SEMTJs13tzQSGpbfTvSyNK6JIFjxclwyYw5WD7w4G/NaigCnKFhI
         JtBOue3V0QTE3/hM6S2ha0WfEa39fri1tVg3rP/+Bl8W9gy/YK1O88V7FrFbF5gnoDMs
         /YW4Tb73gt33gtcBeshLfGgxvR+XL9t+0u7xWcgd1Dq9UGCAzjEh4K81TCqNe1Xzo/qt
         V49UpakF/rFfQ1iZnWJmz9QUVRfJIaLuw1FSAGi940kAydrcov1iQSf9052k4hSuH7FG
         pi1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=nLkSN0Dd;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s22sor7418501otp.87.2019.03.25.16.37.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 16:37:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=nLkSN0Dd;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=iOEBRSaUhydJ0VsiYrBtWnd84J72N11uWSTNWpUMqGM=;
        b=nLkSN0Dd4GMq5L3T02MkvgHF8Qjfl5hqxMU1jViaI5ZMY4AAUV8ZHWWfpy0vxrHIhL
         LIEN2mgdPNuffbj6PmJIhlJGRYJ0wIbM5jgg33U2srGNKlbnZODcZ6f9IBWDMN0gtpEP
         hXV/K4iCKV4Z3Im93Bt0m9KT540iYAexqfQ2K6Idqu6vwlz8qHPvGGon7xViDUJ6qsZg
         J8/IQM9uG4fb5VnD7AqXnv8IY0K4XEXaZDsXd16h5rhblA3fv583+GUhI1i9PxXOCB8b
         DfajQVlPTYDFXp/LD6aZTfAM+scqCRx1vX6t82+N/Zqyn5t0DyOJO1OZPj+DbdBH00P1
         LArg==
X-Google-Smtp-Source: APXvYqw/QIkPeyK1F3pTQoERs2s+6UGl+RbMp7/gwTUqs0w4dcWtOPjrWt2swBwwV/ZhlF4hO6SEk/UMuJYePQW/4lY=
X-Received: by 2002:a9d:6a4f:: with SMTP id h15mr9650954otn.353.1553557039692;
 Mon, 25 Mar 2019 16:37:19 -0700 (PDT)
MIME-Version: 1.0
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <cc6f44e2-48b5-067f-9685-99d8ae470b50@inria.fr> <CAPcyv4it1w7SdDVBV24cRCVHtLb3s1pVB5+SDM02Uw4RbahKiA@mail.gmail.com>
 <3df2bf0e-0b1d-d299-3b8e-51c306cdc559@inria.fr> <CAPcyv4gNrFOQJhKUV7crZqNfg8LQFZRVO04Z+Fo50kzswVQ=TA@mail.gmail.com>
 <ac409eac-d2fa-8e93-6a18-14516b05632f@inria.fr>
In-Reply-To: <ac409eac-d2fa-8e93-6a18-14516b05632f@inria.fr>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 25 Mar 2019 16:37:07 -0700
Message-ID: <CAPcyv4imk02wme0PsY0rUePax8SOq2-=+objYT-x4bxthLkKkQ@mail.gmail.com>
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@suse.com>, 
	Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@surriel.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Dave Hansen <dave.hansen@intel.com>, Keith Busch <keith.busch@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, "Du, Fan" <fan.du@intel.com>, 
	"Huang, Ying" <ying.huang@intel.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 4:09 PM Brice Goglin <Brice.Goglin@inria.fr> wrote:
>
>
> Le 25/03/2019 =C3=A0 20:29, Dan Williams a =C3=A9crit :
> > Perhaps "path" might be a suitable replacement identifier rather than
> > type. I.e. memory that originates from an ACPI.NFIT root device is
> > likely "pmem".
>
>
> Could work.
>
> What kind of "path" would we get for other types of memory? (DDR,
> non-ACPI-based based PMEM if any, NVMe PMR?)

I think for memory that is described by the HMAT "Reservation hint",
and no other ACPI table, it would need to have "HMAT" in the path. For
anything not ACPI it gets easier because the path can be the parent
PCI device.

