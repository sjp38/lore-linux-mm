Return-Path: <SRS0=+oA7=SQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C19E8C10F13
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 18:21:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4ACA3206B7
	for <linux-mm@archiver.kernel.org>; Sun, 14 Apr 2019 18:21:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=colorfullife-com.20150623.gappssmtp.com header.i=@colorfullife-com.20150623.gappssmtp.com header.b="FvLguiWQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4ACA3206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=colorfullife.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C0F16B0003; Sun, 14 Apr 2019 14:21:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 948796B0006; Sun, 14 Apr 2019 14:21:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 838456B0007; Sun, 14 Apr 2019 14:21:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 33CFC6B0003
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 14:21:34 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id a206so12431739wmh.2
        for <linux-mm@kvack.org>; Sun, 14 Apr 2019 11:21:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=vaqsB7LJneSNZZid9H90AUoXXCygYQad8u6hQPYJOos=;
        b=HyeRZGQAVNZ0kyMMKS6fw5lZrs4nrSGuAerg+RMNyXgmR+240Td3b+r+DAEnx02rnQ
         veMIX1vrCYEx/2OVtKar+MgXsiuTh3telUvYLLqA7Pwg0fW121IlonFXeufUq9rl6iKI
         ci9BoktckLfmz+2aQxXeL4ZUytzb5RcOjaTa4Vg+xspLh+fsG5SzlRVb4iVNgClkmwof
         lfb10MMRHS3loF0kpNzsYu73QkYqhrpWaK6HfrHuwXob7oEOQioFxCsCsmKike2FG5LW
         idRsbpExS+M8scrcfIbnH4TIvHB7ULgLqTpeFEzP28AgH79/hHqUg7UkDnAJtSNrxMDk
         pEkQ==
X-Gm-Message-State: APjAAAWEKikpoMphmNwy0oLXX4ALtUfngBJti1vxbc1NXycNZ+1i3yqn
	x7uUPiz8VOr3efCl/TCMleFI99NsXUETLNeqXFLkq1w57LffvU0ayoKEtqqsiL/zA4OTwuirsqY
	Ll3ClrEwMBms9fmab1t3NWdUT+zVaUHknnyROR0QbJ2M2EIZ18owjB9R6NUCGUPi3hQ==
X-Received: by 2002:a5d:62c4:: with SMTP id o4mr24263651wrv.282.1555266093536;
        Sun, 14 Apr 2019 11:21:33 -0700 (PDT)
X-Received: by 2002:a5d:62c4:: with SMTP id o4mr24263622wrv.282.1555266092487;
        Sun, 14 Apr 2019 11:21:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555266092; cv=none;
        d=google.com; s=arc-20160816;
        b=vBoOoEzH1gxgrsy8Q2CbuhYujo4fiJXd68MR2XQhTCal5zPcxDFL9cJbg85b3wajh0
         sLsnXqlq8kKYtCnTJswigvo3LR+UzwbQrf/X9/tk4A67SIvl6g20322rEDaJ72NdD8fs
         MPjs4MfZ50i5c0lkAYxCxX6FGd4RmkzM6YFrqbO871kJrCoEGvn4MM4v3kH45VE1103Q
         uNKl1le3XTb4WbIbSkHdZWjIh5VSZDImW81/CsyVhTdYtmVtT0SqDtOQ4D5mTqPolrAo
         YPnoXvlxvIdE5hLLCo3tTGKst8MJbl1l1uX2HUtoWmWX/HQecLd77WmGjSLI+cJy1WQl
         8IkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=vaqsB7LJneSNZZid9H90AUoXXCygYQad8u6hQPYJOos=;
        b=q6/ejgcjX/Dnn64U2ZjkCeSB+Fai2I56iIqjAE+j0Bqo5SRuXO8jz1l7yiltIywV+g
         AQ0j1Inhl2ao5uuKj6cWM6wJODJllus+hz83NhiSh8Lm4tGMlbIVdcTJagtYFfiOJQkO
         RNsdHQFyvtx+tKxAkY1ouRqv0jQudWfS5Q9PLlhtMUBRtEgOIbQmR1sipS/BOpdaTg3K
         42AuCSGtokQOfZQAFJ0aEn/sotZ/NGVUFRAHKWT73cFqo39qu+jhqlMXAnwFVetrd3mc
         3WSZOPeXT6dypwfW8qVbY28W9ko/UF0HualRCfp5xt33Cy4buTnFsciLOEuWcwnq12f8
         imDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@colorfullife-com.20150623.gappssmtp.com header.s=20150623 header.b=FvLguiWQ;
       spf=pass (google.com: domain of manfred@colorfullife.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=manfred@colorfullife.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q1sor18091224wrj.21.2019.04.14.11.21.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 14 Apr 2019 11:21:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of manfred@colorfullife.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@colorfullife-com.20150623.gappssmtp.com header.s=20150623 header.b=FvLguiWQ;
       spf=pass (google.com: domain of manfred@colorfullife.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=manfred@colorfullife.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=colorfullife-com.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=vaqsB7LJneSNZZid9H90AUoXXCygYQad8u6hQPYJOos=;
        b=FvLguiWQWYCt8V2f3omIwfu9l6z8zYOkTKg79UMuq/o62P5k8ija/vSyyISId2bIwL
         6D//lkQMwPDS758u2ZSiQHFfArE7b/KcfB8KwKsdZIaFOXh8heQSaMr4SlH7WJ0jTzvv
         vEM7H82fa/aVeTbOoPaMKV8QjYmdSCdU6DTZ2ryT/EGxGFjG6kn7JpBeTiSuaWYUYRfp
         +OUAGkZmva5c7XXbyaby3vreFgXYrTOCf81xNLw95IN4MqI1ky/du+PUpmA2cj0eKY4q
         C7nLskS6tA/Mjd1sX3rtzRLcs+kZtlHSrvbeFZrs/sS4YVw3z2Xo7IwljhBryU5l2UWK
         fvGw==
X-Google-Smtp-Source: APXvYqw4VEtgUbwO/asKFfIT5XFnQbZvtHTl2a71alRWF9uNDk+JXgTVWtFC4c4a60oivtPWRmAEBg==
X-Received: by 2002:adf:dc88:: with SMTP id r8mr22132559wrj.28.1555266091915;
        Sun, 14 Apr 2019 11:21:31 -0700 (PDT)
Received: from linux.fritz.box (p200300D993FEBC00B053C56B24DFEA2F.dip0.t-ipconnect.de. [2003:d9:93fe:bc00:b053:c56b:24df:ea2f])
        by smtp.googlemail.com with ESMTPSA id 61sm158169712wre.50.2019.04.14.11.21.30
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Apr 2019 11:21:31 -0700 (PDT)
Subject: Re: [linux-next:master 6345/7161] ipc/util.c:226:13: note: in
 expansion of macro 'max'
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>,
 Linux Memory Management List <linux-mm@kvack.org>,
 Waiman Long <longman@redhat.com>, Davidlohr Bueso <dbueso@suse.de>
References: <201904130252.Ws2iLv7w%lkp@intel.com>
From: Manfred Spraul <manfred@colorfullife.com>
Message-ID: <e9dc2a8a-6e57-c57a-df1f-678794542d09@colorfullife.com>
Date: Sun, 14 Apr 2019 20:21:30 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <201904130252.Ws2iLv7w%lkp@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Sorry - it seem that I forgot to retest the patch without sysctl() after 
converting from direct if/else to max().

On 4/12/19 8:43 PM, kbuild test robot wrote:
> [...]
>     ipc/util.c: In function 'ipc_idr_alloc':
>     include/linux/kernel.h:828:29: warning: comparison of distinct pointer types lacks a cast
>        (!!(sizeof((typeof(x) *)1 == (typeof(y) *)1)))
>                                  ^
>     include/linux/kernel.h:842:4: note: in expansion of macro '__typecheck'
>        (__typecheck(x, y) && __no_side_effects(x, y))
>         ^~~~~~~~~~~
>     include/linux/kernel.h:852:24: note: in expansion of macro '__safe_cmp'
>       __builtin_choose_expr(__safe_cmp(x, y), \
>                             ^~~~~~~~~~
>     include/linux/kernel.h:868:19: note: in expansion of macro '__careful_cmp'
>      #define max(x, y) __careful_cmp(x, y, >)
>                        ^~~~~~~~~~~~~
>>> ipc/util.c:226:13: note: in expansion of macro 'max'
>        max_idx = max(ids->in_use*3/2, ipc_min_cycle);
>                  ^~~
>
>     223		if (next_id < 0) { /* !CHECKPOINT_RESTORE or next_id is unset */
>     224			int max_idx;
>     225	
>   > 226			max_idx = max(ids->in_use*3/2, ipc_min_cycle);

With sysctl disabled, ipc_min_cycle is RADIX_TREE_MAP_SIZE, and this is

 > include/linux/radix-tree.h:#define RADIX_TREE_MAP_SIZE  (1UL << 
RADIX_TREE_MAP_SHIFT)

The checker behind max() is not smart enough to notice that 
RADIX_TREE_MAP_SIZE can be represented as int without an overflow.


What is the right approach?

 > #define ipc_min_cycle    ({    int tmp; tmp = RADIX_TREE_MAP_SIZE; tmp;})


--

     Manfred

