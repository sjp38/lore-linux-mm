Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39D2CC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 14:18:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2A5621773
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 14:18:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2A5621773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A4848E0003; Tue, 19 Feb 2019 09:18:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82C1E8E0002; Tue, 19 Feb 2019 09:18:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 768F78E0003; Tue, 19 Feb 2019 09:18:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1F75A8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 09:18:18 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d8so8534714edi.6
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 06:18:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=FU9EbS04ioijoSCBNNObOq6mvNxzcSl5xT1Xzh9Ks5o=;
        b=BoV3tJa93i/AqVpIN165LTjMdQfo8I/cUVr9LuJvoz90LzQc8kSm17MvthY9TZaqmb
         sgibLzGiO/jZ3Qwx8SunArGMKDdMIMGpNxiRB/KR4fbOalcbXfdeaClJp51t+C0HfybQ
         0TbUjvxB1nMLzKZZVWTDWTiIyQaVR8W7UOnqIkYSF67+Rd/hU8kXZ6vjChxXL57/xntI
         7n0sQJGZpwuCT1TYwnDeq+TA9bj9GLHxUwI4C4bWLOOM3XchEilRiIvcNcsGjUFa8Yop
         YAi5heMNfehytxEJa18p0hom3Ll+kRMw2puijfcbTLcAo1W5ZDhlI5nycIq0o9DAyFF2
         Qu6A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuY5SCLH0oPOfu5kovYeQMwy2FnBRHESUl+ifnE177yBDabil88F
	B3qviThxk6X9CP/jUzXN6+CBvsJNtKhq19iPcna/tSuc72X8nfNfoqMNm3RNjYEQLhsbjYOQGOU
	VnsaK5hco7ASdicdbf6BWcuQnICjYxknyS+djU28h2lBFU45MZ16Sd+fVX/l/CS0Cog==
X-Received: by 2002:a50:a786:: with SMTP id i6mr23336041edc.37.1550585897662;
        Tue, 19 Feb 2019 06:18:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbDm8Q11eVWOGkRskHvnsRk81/m9hbloK8AeTR8YHK2/L5sdHroeWecmL+JTMmV3zbKZpMV
X-Received: by 2002:a50:a786:: with SMTP id i6mr23335978edc.37.1550585896633;
        Tue, 19 Feb 2019 06:18:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550585896; cv=none;
        d=google.com; s=arc-20160816;
        b=WjaWMkQ5gncYKBaQsrFEw1BQ8k6WI0VFDVgWlrgP/i+4+SX56kRgtf18L6BzqVWV74
         Cq9Ilp0cs63DfA361DGmI0L4kBdlzFfmUdO75R76VRi3UIigex+7VcWWdmZ8t+l1JBb0
         dh6Uo38L5lvdLNB97LiheDTA4jRTLMp07fxw/AKaG55VGEG46EKf/y4m/WUJcYpKSN9d
         gG6Ij9vroGytAxV29mY6BXxwo+pBmSQA1MgqdxnyxHUBN4lz7sBWGmZcPe7vLoxkSQV0
         2bGxowps5C+Gd0f8qrEP/D7AQhHqybeFgSkydIR7XsHuS89OdVmiLsUL++9f+Tksd7LD
         rZkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:openpgp:from:references:cc:to:subject;
        bh=FU9EbS04ioijoSCBNNObOq6mvNxzcSl5xT1Xzh9Ks5o=;
        b=f1+5SFR1qIl2nols7uDehz98qjvWDhDxot6GhGuKcDsU+894EeS56d2M7WBtVw6VcP
         HjbEWU04v9WfPhIR8gVJZVhuYOQPWQrkBpl7t5v9dQ5kMcp2ZTJFry+q7BO82fsn9YZA
         jL6YqaVaH7HHaAlEfvj+ypOk0bmSLkhU4RUUdBCROXBdbSO12uRYyuvRPRmkEzdOwCHZ
         sq4Fmk0qxjFrrioIx1kR6G9dcvPdmwGN7rIGC/NWqfmlbDr3fOro/waj7RchHQulMihM
         C409BfEH8DS80dPa1vbay5VTvE5cpchxtd2RnMPnY1xKTkgA/Tp7KQbdbpa9BRlU9ljr
         qC2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n8si4424985ejh.169.2019.02.19.06.18.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 06:18:16 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ECB79B020;
	Tue, 19 Feb 2019 14:18:15 +0000 (UTC)
Subject: Re: [linux-stable-rc:linux-4.14.y 9470/9484]
 fs/proc/task_mmu.c:761:7: warning: 'last_vma' may be used uninitialized in
 this function
To: kbuild test robot <lkp@intel.com>, Sandeep Patil <sspatil@android.com>
Cc: kbuild-all@01.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Joel Fernandes (Google)" <joel@joelfernandes.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Linux Memory Management List <linux-mm@kvack.org>
References: <201902190440.gctrp6gs%fengguang.wu@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Message-ID: <57a1aab3-1779-21ca-cbfe-52c357d4de32@suse.cz>
Date: Tue, 19 Feb 2019 15:18:15 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <201902190440.gctrp6gs%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/18/19 9:01 PM, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable-rc.git linux-4.14.y
> head:   fea4e6b46436daf1982a367f638e3f5e0ae1bd3f
> commit: 7c0e08d8ed3b8b6cf287007968d130f737256438 [9470/9484] mm: proc: smaps_rollup: fix pss_locked calculation
> config: i386-randconfig-s1-02172359 (attached as .config)
> compiler: gcc-6 (Debian 6.5.0-2) 6.5.0 20181026
> reproduce:
>         git checkout 7c0e08d8ed3b8b6cf287007968d130f737256438
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> Note: it may well be a FALSE warning. FWIW you are at least aware of it now.
> http://gcc.gnu.org/wiki/Better_Uninitialized_Warnings
> 
> All warnings (new ones prefixed by >>):
> 
>    fs/proc/task_mmu.c: In function 'show_smap.isra.38':
>>> fs/proc/task_mmu.c:761:7: warning: 'last_vma' may be used uninitialized in this function [-Wmaybe-uninitialized]
>      bool last_vma;
>           ^~~~~~~~

AFAICS false positive, and the commit in question doesn't touch that part.

