Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B273ECDE20
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 17:22:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2264D2081B
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 17:22:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="VZFyADzL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2264D2081B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1BD46B0006; Wed, 11 Sep 2019 13:22:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACB7C6B0008; Wed, 11 Sep 2019 13:22:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 994126B000A; Wed, 11 Sep 2019 13:22:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0160.hostedemail.com [216.40.44.160])
	by kanga.kvack.org (Postfix) with ESMTP id 77BB56B0006
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 13:22:51 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id F2548181AC9C6
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 17:22:50 +0000 (UTC)
X-FDA: 75923309700.16.land64_5303a515a765e
X-HE-Tag: land64_5303a515a765e
X-Filterd-Recvd-Size: 6335
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 17:22:50 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id b2so26207380qtq.5
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 10:22:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=0ExgZnqgklMWdIYiMJ2Wv1Hn7vtnSFHAJcrwJboP42E=;
        b=VZFyADzL38joKkpJuBWRKTPWsj0AsFVHMPzQmYRB/9/C00xWTM+HXGJVBChxai54gS
         ZPDKBIEv+3XmTYpkzKY7npox4Dpl/3w3jabJF7K01DBzkyOfowbsgdPSoZi4zbw7T8CS
         lqhkLI0CL+AYPPCIzX//zUnH4CsC4l3bdqsfFiwzgR2Q0vLYsW54MCzPPN7qQrLcWHUO
         1MJuuxIZkyUguMM0yxqT9xz9lWg2D9i4fcLnIxLFON/CwLmciDK0B0fnx/egtBiLgJ0o
         KCSian6nIevP8C/tUooQePOnZKoolNdww5VPAbHN3PYUKhXRjSI+JcIY9AM13ZVeaekW
         iTNg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=0ExgZnqgklMWdIYiMJ2Wv1Hn7vtnSFHAJcrwJboP42E=;
        b=QxvpSLPk5/ICQaLSLMlLB2qz19atg9hn6LrrAh4nruEFslkNH9kDQlm1AlkhG1aaxI
         DRz0oF50F/TheIYJqNDF3SYe6v8eB3p+eLUfT3PpuRvWrNzeF7DaD+xSZdyQLiRoduv8
         LagioXtyaywZl54FAvzG75dUjB+S569Ph5Kmr/SKijCdH0+lUeLIDhaDqzsk7DVrpKdL
         ovOV5BHvApoRaN/FjWgBoF/8eowhECLK5prGm4Zns0MRS1XuRoMyqV+ZU99YBbqEiVQI
         j46Zst9h+o7/jZ5ygpjz5LfP+RBa60GcQkh9Dvk9RiWR/fdN/+UxeZt5LUQnnFevnl8X
         MTSA==
X-Gm-Message-State: APjAAAU5EyBPWv+nfkroQNkdb0FvN2AtgLycwwTfEVO5nfLLUww/Z7xG
	5eZ3OdlwBMoOUoVNbXQQCBdnFA==
X-Google-Smtp-Source: APXvYqzvv6U+xbTLnOSjGWjjWVRfXjmKj9b42wVs0jiW5KiIT6bDF2XD5HxHvxwGBrHtg23jdzyfgw==
X-Received: by 2002:ac8:6983:: with SMTP id o3mr18706431qtq.31.1568222569708;
        Wed, 11 Sep 2019 10:22:49 -0700 (PDT)
Received: from [192.168.1.153] (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id w11sm12308601qtj.10.2019.09.11.10.22.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Sep 2019 10:22:49 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [PATCH 5/5] hugetlbfs: Limit wait time when trying to share huge
 PMD
From: Qian Cai <cai@lca.pw>
In-Reply-To: <5229662c-d709-7aca-be4c-53dea1a49fda@redhat.com>
Date: Wed, 11 Sep 2019 13:22:47 -0400
Cc: Mike Kravetz <mike.kravetz@oracle.com>,
 Matthew Wilcox <willy@infradead.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Ingo Molnar <mingo@redhat.com>,
 Will Deacon <will.deacon@arm.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 linux-kernel@vger.kernel.org,
 linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org,
 Davidlohr Bueso <dave@stgolabs.net>
Content-Transfer-Encoding: quoted-printable
Message-Id: <C29A1EFA-148C-454E-91F1-93D5116FB640@lca.pw>
References: <20190911150537.19527-1-longman@redhat.com>
 <20190911150537.19527-6-longman@redhat.com>
 <20190911151451.GH29434@bombadil.infradead.org>
 <19d9ea18-bd20-e02f-c1de-70e7322f5f22@redhat.com>
 <40a511a4-5771-f9a9-40b6-64e39478bbcb@oracle.com>
 <5229662c-d709-7aca-be4c-53dea1a49fda@redhat.com>
To: Waiman Long <longman@redhat.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Sep 11, 2019, at 1:15 PM, Waiman Long <longman@redhat.com> wrote:
>=20
> On 9/11/19 6:03 PM, Mike Kravetz wrote:
>> On 9/11/19 8:44 AM, Waiman Long wrote:
>>> On 9/11/19 4:14 PM, Matthew Wilcox wrote:
>>>> On Wed, Sep 11, 2019 at 04:05:37PM +0100, Waiman Long wrote:
>>>>> When allocating a large amount of static hugepages (~500-1500GB) =
on a
>>>>> system with large number of CPUs (4, 8 or even 16 sockets), =
performance
>>>>> degradation (random multi-second delays) was observed when =
thousands
>>>>> of processes are trying to fault in the data into the huge pages. =
The
>>>>> likelihood of the delay increases with the number of sockets and =
hence
>>>>> the CPUs a system has.  This only happens in the initial setup =
phase
>>>>> and will be gone after all the necessary data are faulted in.
>>>> Can;t the application just specify MAP_POPULATE?
>>> Originally, I thought that this happened in the startup phase when =
the
>>> pages were faulted in. The problem persists after steady state had =
been
>>> reached though. Every time you have a new user process created, it =
will
>>> have its own page table.
>> This is still at fault time.  Although, for the particular =
application it
>> may be after the 'startup phase'.
>>=20
>>>                         It is the sharing of the of huge page shared
>>> memory that is causing problem. Of course, it depends on how the
>>> application is written.
>> It may be the case that some applications would find the delays =
acceptable
>> for the benefit of shared pmds once they reach steady state.  As you =
say, of
>> course this depends on how the application is written.
>>=20
>> I know that Oracle DB would not like it if PMD sharing is disabled =
for them.
>> Based on what I know of their model, all processes which share PMDs =
perform
>> faults (write or read) during the startup phase.  This is in =
environments as
>> big or bigger than you describe above.  I have never looked at/for =
delays in
>> these environments around pmd sharing (page faults), but that does =
not mean
>> they do not exist.  I will try to get the DB group to give me access =
to one
>> of their large environments for analysis.
>>=20
>> We may want to consider making the timeout value and disable =
threshold user
>> configurable.
>=20
> Making it configurable is certainly doable. They can be sysctl
> parameters so that the users can reenable PMD sharing by making those
> parameters larger.

It could be a Kconfig option, so people don=E2=80=99t need to change the =
setting every time
after reinstalling the system. There are times people don=E2=80=99t care =
too much
about those random multi-second delays. For example, running a debug =
kernel.


