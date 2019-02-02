Return-Path: <SRS0=HJeg=QJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C003BC282D7
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 11:06:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 813712146E
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 11:06:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 813712146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BC768E0017; Sat,  2 Feb 2019 06:06:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16BBB8E0001; Sat,  2 Feb 2019 06:06:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00B9F8E0017; Sat,  2 Feb 2019 06:06:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id C6AF88E0001
	for <linux-mm@kvack.org>; Sat,  2 Feb 2019 06:06:22 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id q11so4211305otl.23
        for <linux-mm@kvack.org>; Sat, 02 Feb 2019 03:06:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=FZCPnLMFFlfaprbVMbmiqZ0Kby96x//rMg/l/SLCZkU=;
        b=Z4lkRTadZkBYOoaXRIq1TUM1PCCGoI5K6rPCdBsB2O5ZIpZr9jEKxuMyhWZG+Zxmrg
         G9mtIHCGMV8DlmmAYvlfxcFUo2PM0Bl7MtMc3qtdWMNtplGon588gHcxLA/dceSOGvf2
         6sja3N4xLPXsTVWe/ErRC494YEM7o/HstrpTXLIZHUJ3kjs246zPj0Rzz5Jr/309X7Ne
         Z1LLUXOeFYkhjPt8xq0g3jS5+S5EYVVTIVAmBhP8azFFACH1vzGuhuyl5SAXE/v9To0R
         OsPV1Ce1Exp65QAExwijByrEDjuxv0IxOC3s7Bt6W9Hrct8vM8jiQDl9WdmKh0PlB9Fv
         fMQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AJcUukfNpu+TQiz0YH38nJAHzc0fOVHBaE03Dqi5PG6OAJ2jQs0ONsQ6
	Dee2z//InyAODjcpbo0219voWBkaiidS2JXXkU0xSjt2GQnpZuLHgAzY1CgfidlD+klCAHHnKM1
	NDfQ5wVJR4bb90H5bZNj5DRb9ZPr7r0lUJ3FoYfrMFtTRRTXk3preliUPT1T9fhmNpw==
X-Received: by 2002:aca:62d7:: with SMTP id w206mr21737665oib.121.1549105582428;
        Sat, 02 Feb 2019 03:06:22 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6UlJrkiGBRTEi1bEy+9rd0ylo87I1yE6RpUF/u5hhaX5pr7YxL+XJEJDyUXALBYzz739s0
X-Received: by 2002:aca:62d7:: with SMTP id w206mr21737634oib.121.1549105581498;
        Sat, 02 Feb 2019 03:06:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549105581; cv=none;
        d=google.com; s=arc-20160816;
        b=hJVbRyk7ew8COuvtCM8MOtpzs2tcAhskt762bl9w+Ut93tuHKDK/wLI+kGcfOIeFPv
         dwdQF3X9pldSwE3aM7txNnUi93XgRs2HHhBJM1/MVHqvMfDUs5Gnb92WJ+tpsltL/8ML
         Ob8mBU4o5ndXd8RpwnV0Qu3azzyBXpwR4OA5ugxkFBijUXrmjrIJ9sAcpslrXKwBniRE
         4UwMz6FYSybmQXPj33fZzVjmVu5Knx8QFf+pH7X351SkPPeW6EHOgcQ36QXS2tCmcHge
         fFHM13CgTE/URJFWKUAUseER/vmk0/xZq1sarE1mPXrFSNI8nG4uX/JTt5TIMIJuYf4v
         Egiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=FZCPnLMFFlfaprbVMbmiqZ0Kby96x//rMg/l/SLCZkU=;
        b=nCyQ0Wpz4QVm5qmtuln4ZILCQoq0Bxkaw+3dArRSC6zTta+gvX6473rf7xu79nPQT9
         FBBCznJmUo7QzVxc4KmtEiwqMManeiYgvDwtp3UwRnRv0bhSs0JlwNhz8gIRQ/bVMThF
         Ram3grMHRz0aHrHpYILK5fP3avrE5KRp5IChJFAppn6ZwhXv4KUAZoDwVRlrOmurzzsj
         2CYkFUd0BaU2Wktpl75jtn3lNj4VEgMf2GTA9JZRvVUZPcmY6bgZwTHwtfpQGya3wmhZ
         ilFn0JSLTbHGib1IdWjXBRvSqdsSLsb5DnaSVWEjbvRif4obs1lUkxVQZvzlo3gys3T4
         cqbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p10si4326527otl.267.2019.02.02.03.06.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Feb 2019 03:06:21 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav303.sakura.ne.jp (fsav303.sakura.ne.jp [153.120.85.134])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x12B6AFR081072;
	Sat, 2 Feb 2019 20:06:10 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav303.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav303.sakura.ne.jp);
 Sat, 02 Feb 2019 20:06:10 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav303.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x12B69Es081069
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Sat, 2 Feb 2019 20:06:09 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH v2] mm, oom: Tolerate processes sharing mm with different
 view of oom_score_adj.
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Johannes Weiner <hannes@cmpxchg.org>,
        David Rientjes <rientjes@google.com>, linux-mm@kvack.org,
        Yong-Taek Lee <ytk.lee@samsung.com>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>
References: <1547636121-9229-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190116110937.GI24149@dhcp22.suse.cz>
 <88e10029-f3d9-5bb5-be46-a3547c54de28@I-love.SAKURA.ne.jp>
 <20190116121915.GJ24149@dhcp22.suse.cz>
 <6118fa8a-7344-b4b2-36ce-d77d495fba69@i-love.sakura.ne.jp>
 <20190116134131.GP24149@dhcp22.suse.cz>
 <20190117155159.GA4087@dhcp22.suse.cz>
 <edad66e0-1947-eb42-f4db-7f826d3157d7@i-love.sakura.ne.jp>
 <20190131071130.GM18811@dhcp22.suse.cz>
 <5fd73d87-3e4b-f793-1976-b937955663e3@i-love.sakura.ne.jp>
 <20190201091433.GH11599@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <643b94c2-d720-fa95-d6ee-4f0ea6e2686a@i-love.sakura.ne.jp>
Date: Sat, 2 Feb 2019 20:06:07 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190201091433.GH11599@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/02/01 18:14, Michal Hocko wrote:
> On Fri 01-02-19 05:59:55, Tetsuo Handa wrote:
>> On 2019/01/31 16:11, Michal Hocko wrote:
>>> This is really ridiculous. I have already nacked the previous version
>>> and provided two ways around. The simplest one is to drop the printk.
>>> The second one is to move oom_score_adj to the mm struct. Could you
>>> explain why do you still push for this?
>>
>> Dropping printk() does not close the race.
> 
> But it does remove the source of a long operation from the RCU context.
> If you are not willing to post such a trivial patch I will do so.
> 
>> You must propose an alternative patch if you dislike this patch.
> 
> I will eventually get there.
> 

This is really ridiculous. "eventually" cannot be justified as a reason for
rejecting this patch. I want a patch which can be easily backported _now_ .

If vfork() => __set_oom_adj() => execve() sequence is permitted, someone can
try vfork() => clone() => __set_oom_adj() => execve() sequence. And below
program demonstrates that task->vfork_done based exemption in __set_oom_adj()
is broken. It is not always the task_struct who called vfork() that will call
execve().

----------------------------------------
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sched.h>

static int thread1(void *unused)
{
	char *args[3] = { "/bin/true", "true", NULL };
	int fd = open("/proc/self/oom_score_adj", O_WRONLY);
	write(fd, "1000", 4);
	close(fd);
	execve(args[0], args, NULL);
	return 0;
}
int main(int argc, char *argv[])
{
	printf("PID=%d\n", getpid());
	if (vfork() == 0) {
		clone(thread1, malloc(8192) + 8192,
		      CLONE_VM | CLONE_FS | CLONE_FILES, NULL);
		sleep(1);
		_exit(0);
	}
	return 0;
}
----------------------------------------

  PID=8802
  [ 1138.425255] updating oom_score_adj for 8802 (a.out) from 0 to 1000 because it shares mm with 8804 (a.out). Report if this is unexpected.

Current loop to enforce same oom_score_adj is 99%+ ending in vain.
And even your "eventually" will remove this loop.

