Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0B5AC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 16:40:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A9BB2087F
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 16:40:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A9BB2087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 099148E0004; Wed, 30 Jan 2019 11:40:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04A068E0001; Wed, 30 Jan 2019 11:40:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E535F8E0004; Wed, 30 Jan 2019 11:40:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC9898E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 11:40:28 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id u32so202959qte.1
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 08:40:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=eQxAk4yVpxCiOFFuuIfNLqAgY+swOxFr+EhFcwEfwvI=;
        b=hKBEVMk5afOcImcBo1Cx7y89RWkzwIAnJ4ST6TiSdKc1p/JAd6JFsMcEjq3XS+Mtug
         A519h+zhJgkpaVQEXw7bzF13gICJW1sM1PYPolwjV8y3mR8vwRtJ7nAvmHV1gnPitCRV
         v67MbK4XAHrRPj2P+WgqGqTsBeQZYuXkn8USHJYLO4GrjapeAqTFBFzGGoJlqxNOZsVU
         hEXKnVEbMAHbv0TORiMmzQ49H6Rs3SAvTx5a4ypzISO3oB5fAZwUIh5Pl3CaqIaLPh1D
         EogVV3tQNoCOUQj7qDp+Dk4qvie9pAu5f9vdZD5CyvaIZde+lZs0h0a566FsKLUszEZ5
         /0bg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukeioHH1sM/fBD1t/ncTQiTLIv/MpUGifRwxu6amVEhjaMhbC+pq
	bVRUTomhRZvWIKS6PUxPQ1wFtWH1YFhwr76mj2beuL7RlQISlYLWb05k+5Y2eZTP+gvF3VG8QvV
	YiaSe2qzZP8a40oaSvDEWM1t6/ohFM+nXQAdZs9idF6/WQhVXrj4GFAn0X5BOR/XAiQ==
X-Received: by 2002:a37:c51b:: with SMTP id p27mr26895025qki.86.1548866428515;
        Wed, 30 Jan 2019 08:40:28 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6dWaV0ojjMOOkO4JgmaB0tYNV1N8HckqSXnkDnGUD57XTDiYyU3n6unq0qbOBL3wSYz/8H
X-Received: by 2002:a37:c51b:: with SMTP id p27mr26894982qki.86.1548866427657;
        Wed, 30 Jan 2019 08:40:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548866427; cv=none;
        d=google.com; s=arc-20160816;
        b=j5s6Jrh84UoXbOMecqFtwIiidETpD/2g7t96myPhr1gc34X20sqpJ7at5usW/l/hsk
         WrrEicNuBNhWoVerjHSTGc9eSSGHLCKqGM6INMbGdHUsAkQekIu23tVN0pbaC6W3b/Oh
         blSayAvqnwqbEGj1Ky2Fdsdn4/G3wyFS96iy5MjlSoYtRUvx7MdObS96XfvxSL4ciCpH
         lUmXlT1cbdS7gdL/eTILwm4TCsn5/5C0QB2k0gCMCQO4CQj1qSFaZRzEl6bxgubaXOVi
         zxpQwiAtFekozmso8Q6WnAe/5Qoam9OXDTCyDSabRC/RGWeqY6p0zyTkO6O51A8QMZNj
         WXVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp
         :references:cc:to:from:subject;
        bh=eQxAk4yVpxCiOFFuuIfNLqAgY+swOxFr+EhFcwEfwvI=;
        b=hDUbsB1JhVvcQwm0g0NGFWCUGmhX18zAPaI93PaV5KX+0Rcz0gbKciTCuAaX1UNxSJ
         Bpq9lPvOp0U2HnC6sBIjcJELmoQ4s7TwD5DNvPyUl9kwYYbJQiuDtrQsKcI3rGB+oJxo
         1s9EVIAxogHcwc7pOZhINDyMR5cU60ub2Ly/o/QSmB8oFjaJl8TcLYY0B9X1wf9ZGoVG
         tCJ9zzPP4rc7LKiTrGGDs9jaGdzKPUsnVrC6Y03fl6KneV+kEnq6AjN2ySAIx07fI77J
         3EcvooY53KWgAgCnIRq8zZT8kXIMyUCErmIF0dW2SlYXQZAqLdFzULppcn6lNObobOPz
         Wsug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x71si625511qkx.198.2019.01.30.08.40.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 08:40:27 -0800 (PST)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 48371C04958E;
	Wed, 30 Jan 2019 16:40:26 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-59.bos.redhat.com [10.18.17.59])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 197E3608C1;
	Wed, 30 Jan 2019 16:40:23 +0000 (UTC)
Subject: Re: [RESEND PATCH v4 0/3] fs/dcache: Track # of negative dentries
From: Waiman Long <longman@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
 Jonathan Corbet <corbet@lwn.net>,
 Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
 linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org,
 linux-doc@vger.kernel.org, mcgrof@kernel.org,
 Kees Cook <keescook@chromium.org>, Jan Kara <jack@suse.cz>,
 Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>,
 mszeredi@redhat.com, Matthew Wilcox <willy@infradead.org>,
 lwoodman@redhat.com, James Bottomley
 <James.Bottomley@hansenpartnership.com>, wangkai86@huawei.com,
 Michal Hocko <mhocko@kernel.org>
References: <1544824384-17668-1-git-send-email-longman@redhat.com>
 <CAHk-=wi-V7LjAAzFuxg+eLQAdp+Ay4WmVJdTNxgPjqKXaj-3Xw@mail.gmail.com>
 <0433488a-c8ad-e31a-6144-648e45478c07@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=longman@redhat.com; prefer-encrypt=mutual; keydata=
 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
 weim8xU=
Organization: Red Hat
Message-ID: <260e6cdb-42b7-1891-e525-54048d168b5c@redhat.com>
Date: Wed, 30 Jan 2019 11:40:23 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <0433488a-c8ad-e31a-6144-648e45478c07@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 30 Jan 2019 16:40:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01/15/2019 04:27 PM, Waiman Long wrote:
> On 12/16/2018 02:37 PM, Linus Torvalds wrote:
>> On Fri, Dec 14, 2018 at 1:53 PM Waiman Long <longman@redhat.com> wrote:
>>> This patchset addresses 2 issues found in the dentry code and adds a
>>> new nr_dentry_negative per-cpu counter to track the total number of
>>> negative dentries in all the LRU lists.
>> The series looks sane to me. I'm assuming I'll get it either though
>> -mm or from Al..
>>
>>             Linus
> Could anyone pick up this patchset?
>
> Thanks,
> Longman
>
Ping. Will this patch be picked up?

Thanks,
Longman

