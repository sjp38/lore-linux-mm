Return-Path: <SRS0=Jdrj=PS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A420C43612
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 21:29:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD3F820652
	for <linux-mm@archiver.kernel.org>; Thu, 10 Jan 2019 21:29:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="aNXZ2OJv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD3F820652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4524E8E0003; Thu, 10 Jan 2019 16:29:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 400778E0002; Thu, 10 Jan 2019 16:29:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 318728E0003; Thu, 10 Jan 2019 16:29:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 02C2B8E0002
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:29:41 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id r24so5088640otk.7
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:29:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=86T4nAEAR2Gerci2yDzFI28cHZhy38n5W4JM5FBd67Q=;
        b=Ycmpry6sqZ9bMXJEz3svGnaR/oGCjlWyhoYAzqVDDCQPZpVOI1Qoc5vgsrvi23JCAV
         QD08K+Bu6AxTRIRDNWI+Tdk7xw7R0Sf9ChHJdExhJOc1vltZ6ZJeNCYEOdnC5r5V+Iar
         NDOjYxke3PvTZGz8HLztOzBxFdWVZYP/yZMhxjrmLAXUBj56RjloNaSbMx6dKoKuKExv
         ud9xm44ous0YZnR14C3RjHECUD8/iIkhdF32sBH9ikl4w4/2jsBUnERfCpYlUuv/uzlr
         VkNqdSrfCw5ohs6c+vGESzpD/WWCtBfA37LfsRc4fqi8RHkw4uPk5108ZocLS1z2HTZv
         ZJqQ==
X-Gm-Message-State: AJcUukf32wToVTcI7Wzw6RLAyeGgw0I4/sCMwdpm/lQkm/ub5vOMn3QL
	v7VZntR7ly7CVCX6plNXGzUhcUniUGMIpxlbRNXN736JNoNWbtUcht87bhZfMQDholGLS0YiuGo
	w7nRxCagA/uK9WO/hqdV4WC3wS6GwxlAIRkG/U2GrnqJOQgjRYc2A1P7dpQIJnlWbRNwDMvWQEs
	R+tFTlfHEYYfcBT/tTsBSuivuI6JmUcxzty6TeNiIdNzF5Zl3PbvnGsqT894xXIGcj32ZJm1vM1
	XIEPa6mjeft5TyTQrGO2yjYsePC8+shpaN13YpvBMKrIhXwlQqoz7DzhG2g0SWUV7RPaSpJXubM
	3FV/Y54bHcXcMhKMAQAu/fPJ20ho1ihAFFI+4tlDbSLTrzKbjoiXi+Ad5j6h1H0L8Ix02c79B4N
	z
X-Received: by 2002:a9d:2062:: with SMTP id n89mr7482199ota.244.1547155780643;
        Thu, 10 Jan 2019 13:29:40 -0800 (PST)
X-Received: by 2002:a9d:2062:: with SMTP id n89mr7482153ota.244.1547155779098;
        Thu, 10 Jan 2019 13:29:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547155779; cv=none;
        d=google.com; s=arc-20160816;
        b=xpSUEHKnGgHY9rKM+fynQlEfBdAW2Q3uAFECNrnk8n23qufZhqd5irbs8DMsEXdx3e
         IzkEYejBzbeK5Sl818OJIMo5iHZ3Sd4QJyeoK/smxM/YP7edrphSO0cglUXvYUUc2SAP
         CuitI4bFDhmHk/w8P0ViVfE/wkAUp8/GmIdq7QcfnWAIILd3slMmLKTcPtQLzbfWo6T8
         JOsSAWHAVYcgJKcQ2hoMFFqiY/iIvNdV0hfCkwlXIzGYoNtVwmeaDBMtV1CZIh1AO/T0
         lZbiN1k5tPMt1JLjfY7GT6DaDirtRUj7mc4Vf+tAMCLVUrVzNLFLAnxM99zLcH3X4POK
         4Dsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=86T4nAEAR2Gerci2yDzFI28cHZhy38n5W4JM5FBd67Q=;
        b=a2jgJsQXpleiMasBDj7VE6hDKu8gjRHVc1Vp35mO/2DI3VJaGKtFcsAvdTFUMb24h2
         vGNTqxWjmxr2hV7eY320f26EryEyL/CInFJcTQAqAiy82FtxlkMAMbp+9+yZWGdgpcsS
         69/xi1fMOWfrjRXTEUBkLoKlTPpM28iKmr8b3x4iN6rWTlArDZjZNc38sAppkgVSzjAe
         S3agVS0WH/9l5BviNaYYnsvOPWW6BXfw6WS9rZrbZvf01vTH3mJUCIYfuXFzidhh6S/Q
         /eg7ghlWrVw2ktaFerbxMfvsky4wo8G9rLIUqaQytS+s+LqwIIYoi9NC/3wG4xXJ4vZW
         hi2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=aNXZ2OJv;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 42sor37072559oti.51.2019.01.10.13.29.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 13:29:39 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=aNXZ2OJv;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=86T4nAEAR2Gerci2yDzFI28cHZhy38n5W4JM5FBd67Q=;
        b=aNXZ2OJv4lGdZUFtY0qFcQH46WAlTZPVrWsQ7R2/7JgRhq6BqlVA6eSqGksN/XwG5k
         zvQ9Xvj0JIw6FHM8MQgI2JoZIGKHAVjUtRnPzJHRzNkM3JcacX2ycOVsJdPiPjv+bm5F
         2Kyl8UNqwj+uyM6atFdhtn/dl1WLbkYo7ZrVnDUqfpUMBn6sWYuSuZd5sUrAcgRaHTkK
         o+O3uHsSyNn3jgj3ezB7uQIasjLJK2OGfwxqrmHo5IQv6RxSMQUM+qB46zy7Z4lo2Vfn
         fIC5DhlSzCMButhYflQf5vR0FrccsMWSr9U6JnNcn5MdHtJzZxpqcRU9//lmsAUD8SWe
         hYCA==
X-Google-Smtp-Source: ALg8bN7x7casDXvUdv89UF5nNU1E+sgmMJdshHOV8kDoMWaWVulEN4fBUOF2DGXBRNUjl6+d9Pi37DIQD4TuCI2E1ww=
X-Received: by 2002:a9d:7dd5:: with SMTP id k21mr8192664otn.214.1547155778669;
 Thu, 10 Jan 2019 13:29:38 -0800 (PST)
MIME-Version: 1.0
References: <154690326478.676627.103843791978176914.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154690327057.676627.18166704439241470885.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190110105638.GJ28934@suse.de>
In-Reply-To: <20190110105638.GJ28934@suse.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 10 Jan 2019 13:29:27 -0800
Message-ID:
 <CAPcyv4gkSBW5Te0RZLrkxzufyVq56-7pHu__YfffBiWhoqg7Yw@mail.gmail.com>
Subject: Re: [PATCH v7 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Mike Rapoport <rppt@linux.ibm.com>, Keith Busch <keith.busch@intel.com>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190110212927.qqXjNMuLR1nOXwucAPBH6Cv56WNCg8yut7koZNHz_P4@z>

On Thu, Jan 10, 2019 at 2:57 AM Mel Gorman <mgorman@suse.de> wrote:
>
> On Mon, Jan 07, 2019 at 03:21:10PM -0800, Dan Williams wrote:
> > Randomization of the page allocator improves the average utilization of
> > a direct-mapped memory-side-cache. Memory side caching is a platform
> > capability that Linux has been previously exposed to in HPC
> > (high-performance computing) environments on specialty platforms. In
> > that instance it was a smaller pool of high-bandwidth-memory relative to
> > higher-capacity / lower-bandwidth DRAM. Now, this capability is going to
> > be found on general purpose server platforms where DRAM is a cache in
> > front of higher latency persistent memory [1].
> >
>
> So I glanced through the series and while I won't nak it, I'm not a
> major fan either so I won't ack it either.

Thanks for taking a look, some more comments / advocacy below...
because I'm not sure what Andrew will do with a "meh" response
compared to an ack.

> While there are merits to
> randomisation in terms of cache coloring, it may not be robust. IIRC, the
> main strength of randomisation vs being smart was "it's simple and usually
> doesn't fall apart completely". In particular I'd worry that compaction
> will undo all the randomisation work by moving related pages into the same
> direct-mapped lines. Furthermore, the runtime list management of "randomly
> place and head or tail of list" will have variable and non-deterministic
> outcomes and may also be undone by either high-order merging or compaction.

It's a fair point. To date we have not been able to measure the
average performance degrading over time (pages becoming more ordered)
but that said I think it would take more resources and time than I
have available for that trend to present. If it did present that would
only speak to a need to be more aggressive on the runtime
re-randomization. I think there's a case to be made to start simple
and only get more aggressive with evidence.

Note that higher order merging is not a current concern since the
implementation is already randomizing on MAX_ORDER sized pages. Since
memory side caches are so large there's no worry about a 4MB
randomization boundary.

However, for the (unproven) security use case where folks want to
experiment with randomizing on smaller granularity, they should be
wary of this (/me nudges Kees).

> As bad as it is, an ideal world would have a proper cache-coloring
> allocation algorithm but they previously failed as the runtime overhead
> exceeded the actual benefit, particularly as fully associative caches
> became more popular and there was no universal "one solution fits all". One
> hatchet job around it may be to have per-task free-lists that put free
> pages into buckets with the obvious caveat that those lists would need
> draining and secondary locking. A caveat of that is that there may need
> to be arch and/or driver hooks to detect how the colors are managed which
> could also turn into a mess.

We (Dave, I and others that took a look at this) started here, and the
"mess" looked daunting compared to randomization. Also a mess without
much more incremental benefit.

We also settled on a numa_emulation based approach for the cases where
an administrator knows they have a workload that can fit in the
cache... more on that below:

> The big plus of the series is that it's relatively simple and appears to
> be isolated enough that it only has an impact when the necessary hardware
> in place. It will deal with some cases but I'm not sure it'll survive
> long-term, particularly if HPC continues to report in the field that
> reboots are necessary to reshufffle the lists (taken from your linked
> documents). That workaround of running STREAM before a job starts and
> rebooting the machine if the performance SLAs are not met is horrid.

That workaround is horrid, and we have a separate solution for it
merged in commit cc9aec03e58f "x86/numa_emulation: Introduce uniform
split capability". When an administrator knows in advance that a
workload will fit in cache they can use this capability to run the
workload in a numa node that is guaranteed to not have cache conflicts
with itself.

Whereas randomization benefits the general cache-overcommit case. The
uniform numa split case addresses those niche users that can manually
time schedule jobs with different working set sizes... without needing
to reboot.

