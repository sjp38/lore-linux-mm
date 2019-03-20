Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17E08C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 13:34:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B49A3213F2
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 13:34:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B49A3213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 242D66B0003; Wed, 20 Mar 2019 09:34:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F2A06B0006; Wed, 20 Mar 2019 09:34:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E1F86B0007; Wed, 20 Mar 2019 09:34:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 996B46B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 09:34:16 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id d20so422882lfa.14
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 06:34:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=y93P8V0JEbhy51autrO0vk3y/+ZtbIz69pKtJ+mRUNo=;
        b=i7WPGMhT0sC7Vs8Ym5RIK1GVUyUQoXEbLy8Ts7orBLC+qk+AS/Vv3M4vtfgcQ2LiIK
         wCG951/cWULpys8QSctL7lWgsCenaH6yR83hnJyPA7T9rj4IkeyV8zlXdyVIn9tB1Usd
         JTivAM2/I3Y1IA7FLIWKA+bWg42UnZGgz63qZZTmxI/0KVX7Km8suMejX9OTXa4Y1vtJ
         fGj87G3R07XdXeYhJpJbsl1Y9YZ+VbHJC66BXntVFWCfD92NnpfTeX5XktDTyviTaTM8
         17DJ8juqcQJ6R8A+TfNSiAzzBZWFiGroB4usyatAjuZwig1nE5CHAgpQamj8U24FhEff
         NaPA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAV3Bz4Uwfvr+wldnkvdi19wnUAlqdBfwUH2OjUgouYuHUDtQtU3
	c3QmNob6lv0EMYaPjpZUBIalXbazmddBKDuukuMzXuThmGC1cBLsqfSmpgMFDCspsFymFfCRcW5
	fGrbu0b52lZxIKiZZ1alslN1+6DYG2sS4WLu7d0mNb7NlETgc+EutvE0m+MkMaZ4Trg==
X-Received: by 2002:ac2:5921:: with SMTP id v1mr16558306lfi.135.1553088855867;
        Wed, 20 Mar 2019 06:34:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDaU57W2ocqf9hxuZxDV9ufy9yB+pa9m6OnI/BQ7IZ3+T+ABvGMiIZXgybKeuJdnjDKOrS
X-Received: by 2002:ac2:5921:: with SMTP id v1mr16558261lfi.135.1553088854964;
        Wed, 20 Mar 2019 06:34:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553088854; cv=none;
        d=google.com; s=arc-20160816;
        b=Utdm3SkNPPTdaQgH6RQinR416hJqk2W+nVn0n2junsowm52EktFbAcpST6nghmX2Hn
         obD7QUA7GceKYNOAX1J24Dz77gA9YyVdW3KGfL6fnzGMsdrjo+Rum5ZdcsRw40RQfJ31
         XSHZl11KiE26awXpNmPRC9W0If0NvF8kw9U5aYdLgGTwnNWG7cykbPwTU7fFcj9xvYF7
         u10maT/aUcekycr9TJr75Q8LXhOOK4OWbSPh/v7Hzfc++s0TlBv1VW9LWf92/v+JgG6D
         +Y/bwCM1EEezqfom7ZeftGT4FCx7PKPaUmysPNEm1iB8RM6clhEckoB7cr3jBQ7JXBK1
         rDjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=y93P8V0JEbhy51autrO0vk3y/+ZtbIz69pKtJ+mRUNo=;
        b=oYdeWK19JTaLSPhRWxPw4ixBH3/3DpFGLXRSxfCqmflW6M29XfqmKLr69TXIYoFOL5
         Sxum2oSOOn0mfiCeOP8WS35YOseN3h/5vzsLSYEL7/QBT0nN8Hdv1xHetAFolOAK4Aja
         Np4hPiQlTc/WFiTyglBJ/YITvoqU+HpNll3Rvw+9nWHT2Ezg6P8B+dFiPR7h06GJGnUH
         joETKMD4Y5hLUiPdvFrElGpjzGUCWCnEovc7phHAVv26RSjrOkPe9KmHqoC4JuV6CEvh
         m2h/d7xQcDf8dAYJ+oVD1/278clLYoeViUAEuoAj99cKp55eYQrJKCdEfo1WHcxsenq0
         jGAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id 10si1326245lje.200.2019.03.20.06.34.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 06:34:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1h6bLg-0000UM-PB; Wed, 20 Mar 2019 16:33:40 +0300
Subject: Re: kernel panic: corrupted stack end in wb_workfn
To: Dmitry Vyukov <dvyukov@google.com>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com>,
 Andrew Morton <akpm@linux-foundation.org>, Qian Cai <cai@lca.pw>,
 David Miller <davem@davemloft.net>, guro@fb.com,
 Johannes Weiner <hannes@cmpxchg.org>, Josef Bacik <jbacik@fb.com>,
 Kirill Tkhai <ktkhai@virtuozzo.com>, LKML <linux-kernel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>, linux-sctp@vger.kernel.org,
 Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>,
 netdev <netdev@vger.kernel.org>, Neil Horman <nhorman@tuxdriver.com>,
 Shakeel Butt <shakeelb@google.com>,
 syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
 Al Viro <viro@zeniv.linux.org.uk>, Vladislav Yasevich <vyasevich@gmail.com>,
 Matthew Wilcox <willy@infradead.org>, Xin Long <lucien.xin@gmail.com>
References: <000000000000db3d130584506672@google.com>
 <d9e4e36d-1e7a-caaf-f96e-b05592405b5f@virtuozzo.com>
 <CACT4Y+Zj=35t2djhKoq+e1SH3Zu3389Pns7xX6MiMWZ=PFpShA@mail.gmail.com>
 <426293c3-bf63-88ad-06fb-83927ab0d7c0@I-love.SAKURA.ne.jp>
 <CACT4Y+Zh8eA50egLquE4LPffTCmF+30QR0pKTpuz_FpzsXVmZg@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <315c8ff3-fd03-f2ca-c546-ca7dc5c14669@virtuozzo.com>
Date: Wed, 20 Mar 2019 16:34:11 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Zh8eA50egLquE4LPffTCmF+30QR0pKTpuz_FpzsXVmZg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 3/20/19 1:38 PM, Dmitry Vyukov wrote:
> On Wed, Mar 20, 2019 at 11:24 AM Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>>
>> On 2019/03/20 18:59, Dmitry Vyukov wrote:
>>>> From bisection log:
>>>>
>>>>         testing release v4.17
>>>>         testing commit 29dcea88779c856c7dc92040a0c01233263101d4 with gcc (GCC) 8.1.0
>>>>         run #0: crashed: kernel panic: corrupted stack end in wb_workfn
>>>>         run #1: crashed: kernel panic: corrupted stack end in worker_thread
>>>>         run #2: crashed: kernel panic: Out of memory and no killable processes...
>>>>         run #3: crashed: kernel panic: corrupted stack end in wb_workfn
>>>>         run #4: crashed: kernel panic: corrupted stack end in wb_workfn
>>>>         run #5: crashed: kernel panic: corrupted stack end in wb_workfn
>>>>         run #6: crashed: kernel panic: corrupted stack end in wb_workfn
>>>>         run #7: crashed: kernel panic: corrupted stack end in wb_workfn
>>>>         run #8: crashed: kernel panic: Out of memory and no killable processes...
>>>>         run #9: crashed: kernel panic: corrupted stack end in wb_workfn
>>>>         testing release v4.16
>>>>         testing commit 0adb32858b0bddf4ada5f364a84ed60b196dbcda with gcc (GCC) 8.1.0
>>>>         run #0: OK
>>>>         run #1: OK
>>>>         run #2: OK
>>>>         run #3: OK
>>>>         run #4: OK
>>>>         run #5: crashed: kernel panic: Out of memory and no killable processes...
>>>>         run #6: OK
>>>>         run #7: crashed: kernel panic: Out of memory and no killable processes...
>>>>         run #8: OK
>>>>         run #9: OK
>>>>         testing release v4.15
>>>>         testing commit d8a5b80568a9cb66810e75b182018e9edb68e8ff with gcc (GCC) 8.1.0
>>>>         all runs: OK
>>>>         # git bisect start v4.16 v4.15
>>>>
>>>> Why bisect started between 4.16 4.15 instead of 4.17 4.16?
>>>
>>> Because 4.16 was still crashing and 4.15 was not crashing. 4.15..4.16
>>> looks like the right range, no?
>>
>> No, syzbot should bisect between 4.16 and 4.17 regarding this bug, for
>> "Stack corruption" can't manifest as "Out of memory and no killable processes".
>>
>> "kernel panic: Out of memory and no killable processes..." is completely
>> unrelated to "kernel panic: corrupted stack end in wb_workfn".
> 
> 
> Do you think this predicate is possible to code?

Something like bellow probably would work better than current behavior.

For starters, is_duplicates() might just compare 'crash' title with 'target_crash' title and its duplicates titles.
syzbot has some knowledge about duplicates with different crash titles when people use "syz dup" command.
Also it might be worth to experiment with using neural networks to identify duplicates.


target_crash = 'kernel panic: corrupted stack end in wb_workfn'
test commit:
	bad = false;
	skip = true;
	foreach run:
		run_started, crashed, crash := run_repro();

		//kernel built, booted, reproducer launched successfully
		if (run_started)
			skip = false;
		if (crashed && is_duplicates(crash, target_crash))
			bad = true;
	
	if (skip)
		git bisect skip;
	else if (bad)
		git bisect bad;
	else
		git bisect good;

