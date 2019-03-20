Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85A3CC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 10:25:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 186D02146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 10:25:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 186D02146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=I-love.SAKURA.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 93B666B0003; Wed, 20 Mar 2019 06:25:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 911176B0006; Wed, 20 Mar 2019 06:25:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 827E56B0007; Wed, 20 Mar 2019 06:25:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 507896B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 06:25:03 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id o3so916769ote.11
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:25:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=a5IojVDfO1pSlF87hpuJrDafQs6My1MzzVQ3MScDbBQ=;
        b=GzMQuPXvvwo4J88L9pbA44vo4ifXzo/wBbL1CJytkwUgnahUuX24jDEAK5XwuNLrbO
         Ky4ZCB3MY0/QXX3sCh8AX2+DhrwlZtqzEcVbIhCewRYPJzfpR0pe7WkomWplhU+ZyfZC
         Ys4DigkEBq0BXnzu/q7s1MjMFyoS1WkL38mQW3uw7L6/40yYhmsTK//1eLVt6MBsLhMT
         9wCBQLOCp/pEDaQKIRJer5lpDEtuVM3yNUklDan6YDzsoicZaAGDLzb5S6+oeDyMl//8
         XUQ4bfKo+E7XSR9VaHjf7qNxFIZ33jJn7PvAxZ+zqvVL2iir4PskZN00Lo4i/Dbm6MLU
         MmYw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAUsfOTVh+tHtLUY7JHYWUQRcAKGYfH0oWrwDgSunbef4uoYNs0L
	pcb8Qmd5nqbfNK2mFqs2SUCF/wJVpXklemVOKJhrxX22h63/IXKtaC9jrWVCHmXKF8enX/B9gzF
	wq89IKMbABKCU6tjsUFZHfOUO2tPsbXoWjOxb8mPHYkE8bAjZdSK7zwAtUnL7+XL3cA==
X-Received: by 2002:a05:6830:1145:: with SMTP id x5mr5378343otq.40.1553077502851;
        Wed, 20 Mar 2019 03:25:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtygd1pJdzWcrmndOhODwErOjWV6IZt0ebrsDhk3Kpssd+Q1z3iVGrY67f9OqR6tm972pw
X-Received: by 2002:a05:6830:1145:: with SMTP id x5mr5378315otq.40.1553077502122;
        Wed, 20 Mar 2019 03:25:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553077502; cv=none;
        d=google.com; s=arc-20160816;
        b=aumxu1KprsFWwvOCNL2fsrXp2vjDJ8Rs+kofrQXFtroom3Edefd2ocYXXNFp1AhyGz
         lV07T9Fjc8U7WRtVD9sGWB/AW0d9+9/i/SgjvfBWLokPdKzPrOGnMFTxEfFvHb00GCUc
         Gle9+C3SuDX6/jnZU4MNVNO/gXMkc63Wu0XBixl+I4OIiMB10Yq2NVSdMOaNt41FDHHu
         Rd7P1ZxJUU1k44DccpueJhQmmxp9K8r92XIE8lkmx5dxecigDdMBzVp/fCIQnqCOPTEp
         ALpyjO73Ned6sP9wU/m5La41jDLKjWsJZnWQgPdCpHYgT8sjawynnPN9zQHVTDvVq6wh
         k0qQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=a5IojVDfO1pSlF87hpuJrDafQs6My1MzzVQ3MScDbBQ=;
        b=pKx4Dm2J4KSkom6hF8+5kQSz2aw2M3+Z0qdxrsyKfHxIeo/OWa/GNwNJgYowNNbAnQ
         8NNJx2TP/+s8G/gtUoGoaKh4Z488bKLVPi8p+fWXUFQ2iiJVkmpVKFfpXnCjS02zyxJQ
         D7HmmCc+YXQyu6x31tRK21psjQp0w0Z0atVOHtRqstF+SCgVNoQ+VAXQpJassCiwVeKw
         PyrTu2oGXFWrCco1Ef4NUVWoT6R5ZihtftFTX86fI9V2s5bzUlQDKJM3PVYSDZ8rKY8V
         v52UhMt3qrRrC3N1FGi2wEHYOZPEpP2JKBElL3zHwecPHLXO/EhtfxB6C+0IJLfXo9Bm
         OFsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id w12si679689otk.230.2019.03.20.03.25.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 03:25:01 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav301.sakura.ne.jp (fsav301.sakura.ne.jp [153.120.85.132])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x2KAO3Sr008946;
	Wed, 20 Mar 2019 19:24:03 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav301.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav301.sakura.ne.jp);
 Wed, 20 Mar 2019 19:24:03 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav301.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126094122116.bbtec.net [126.94.122.116])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x2KANxPp008907
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Wed, 20 Mar 2019 19:24:03 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: Re: kernel panic: corrupted stack end in wb_workfn
To: Dmitry Vyukov <dvyukov@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: syzbot <syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com>,
        Andrew Morton <akpm@linux-foundation.org>, Qian Cai <cai@lca.pw>,
        David Miller <davem@davemloft.net>, guro@fb.com,
        Johannes Weiner <hannes@cmpxchg.org>, Josef Bacik <jbacik@fb.com>,
        Kirill Tkhai <ktkhai@virtuozzo.com>,
        LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        linux-sctp@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>,
        Michal Hocko <mhocko@suse.com>, netdev <netdev@vger.kernel.org>,
        Neil Horman <nhorman@tuxdriver.com>,
        Shakeel Butt <shakeelb@google.com>,
        syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Vladislav Yasevich <vyasevich@gmail.com>,
        Matthew Wilcox <willy@infradead.org>, Xin Long <lucien.xin@gmail.com>
References: <000000000000db3d130584506672@google.com>
 <d9e4e36d-1e7a-caaf-f96e-b05592405b5f@virtuozzo.com>
 <CACT4Y+Zj=35t2djhKoq+e1SH3Zu3389Pns7xX6MiMWZ=PFpShA@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <426293c3-bf63-88ad-06fb-83927ab0d7c0@I-love.SAKURA.ne.jp>
Date: Wed, 20 Mar 2019 19:23:58 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Zj=35t2djhKoq+e1SH3Zu3389Pns7xX6MiMWZ=PFpShA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/03/20 18:59, Dmitry Vyukov wrote:
>> From bisection log:
>>
>>         testing release v4.17
>>         testing commit 29dcea88779c856c7dc92040a0c01233263101d4 with gcc (GCC) 8.1.0
>>         run #0: crashed: kernel panic: corrupted stack end in wb_workfn
>>         run #1: crashed: kernel panic: corrupted stack end in worker_thread
>>         run #2: crashed: kernel panic: Out of memory and no killable processes...
>>         run #3: crashed: kernel panic: corrupted stack end in wb_workfn
>>         run #4: crashed: kernel panic: corrupted stack end in wb_workfn
>>         run #5: crashed: kernel panic: corrupted stack end in wb_workfn
>>         run #6: crashed: kernel panic: corrupted stack end in wb_workfn
>>         run #7: crashed: kernel panic: corrupted stack end in wb_workfn
>>         run #8: crashed: kernel panic: Out of memory and no killable processes...
>>         run #9: crashed: kernel panic: corrupted stack end in wb_workfn
>>         testing release v4.16
>>         testing commit 0adb32858b0bddf4ada5f364a84ed60b196dbcda with gcc (GCC) 8.1.0
>>         run #0: OK
>>         run #1: OK
>>         run #2: OK
>>         run #3: OK
>>         run #4: OK
>>         run #5: crashed: kernel panic: Out of memory and no killable processes...
>>         run #6: OK
>>         run #7: crashed: kernel panic: Out of memory and no killable processes...
>>         run #8: OK
>>         run #9: OK
>>         testing release v4.15
>>         testing commit d8a5b80568a9cb66810e75b182018e9edb68e8ff with gcc (GCC) 8.1.0
>>         all runs: OK
>>         # git bisect start v4.16 v4.15
>>
>> Why bisect started between 4.16 4.15 instead of 4.17 4.16?
> 
> Because 4.16 was still crashing and 4.15 was not crashing. 4.15..4.16
> looks like the right range, no?

No, syzbot should bisect between 4.16 and 4.17 regarding this bug, for
"Stack corruption" can't manifest as "Out of memory and no killable processes".

"kernel panic: Out of memory and no killable processes..." is completely
unrelated to "kernel panic: corrupted stack end in wb_workfn".

