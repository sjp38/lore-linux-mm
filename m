Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BE83C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 10:50:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D51C208CB
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 10:50:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D51C208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA7666B026E; Tue, 28 May 2019 06:50:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E56526B026F; Tue, 28 May 2019 06:50:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1E916B0273; Tue, 28 May 2019 06:50:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 883A36B026E
	for <linux-mm@kvack.org>; Tue, 28 May 2019 06:50:28 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r5so32433666edd.21
        for <linux-mm@kvack.org>; Tue, 28 May 2019 03:50:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=QsqFaGaz1HGsf63u50aDNMgF3AaFfbAtnyMKn5jou+I=;
        b=WyMyBDg1XORCZ6xaMnDBjumLjVJgNfxClxsckDHavM0q8WZVhVwuGe4RYcBWcHfs+u
         inFJk2MX9ov6iZr/M+gVsjKmu1wY4OORMsDMWYObF2RQ6bHUvlZ9LgFT3c4lKZtq5hYD
         8YEqyg9V35ZzxW6nahbwyDp3sOocCcLwg5LZPr4l/IXsF/gmxVMBr6JCSe8rY9tddDEC
         BKJkq0IzPHTrSlmLRMlY05tbbxr7X9JuXP83AVtaOOADDWIRAoVOsdACq+y1MxrsXkqB
         qETMLNjLPTZlVCqR5wiroIdZcLFhTuI28al2tPCcnzqOBnNN+v/1oastSzmw5RPPOfq3
         59HA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUoV/1t+EoHA5t5qqNWZb/CZHR2YTwlcdJcFv1BKq+QLHMwyRAo
	/48WSG3ERiklCU1SCxcCskDx9V7Ta9xgbkFJNuoAQu2Rp23SKsxg+MZiRfBro7bg5QjMFVIA73F
	B94uYB5KZdCZrkflWp5HBZxrDvP8K5CBLM71PxmrgivZ0TCCUe67HasFLJNAxbAm9qA==
X-Received: by 2002:a50:ba1d:: with SMTP id g29mr74289525edc.298.1559040628151;
        Tue, 28 May 2019 03:50:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyh2IkSWc9QmA0UdwCe3huo24/EjkYLYUiW4ReYTPeUt4YlmtlU6EJwsyFzfFBM+6lrtL5V
X-Received: by 2002:a50:ba1d:: with SMTP id g29mr74289447edc.298.1559040627089;
        Tue, 28 May 2019 03:50:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559040627; cv=none;
        d=google.com; s=arc-20160816;
        b=XywZGAHVTz1E1C8DZzpAHip0oL/OP7BqSOE183CmyxAt9255rX8s4J8sfNtNJzZRTj
         QHWBn7F1Fezi6lLi4mFvzO1CXbMJkBpdLi89IK/xUB/K/E87cYuuxuCAOmysr4K4QVPu
         z9Z15thwOs+DD6+mcbOMfqOTQtHPgY93iwaPXoSjOZwVriq+8NRNXvCMQQDAGJXWK7No
         j8B4RiD1M2PAFJQmjNTu60egeFu3Siopi4DBA0xprIw9B8q9WlDYsGiyD4XqSng5BEEN
         KOfSaW1ePRg6CpYiBe3B2tNJT8iT4ItrdButk55/QjHpNImC5frZ820KKwOKVM0PjB5J
         NDRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=QsqFaGaz1HGsf63u50aDNMgF3AaFfbAtnyMKn5jou+I=;
        b=U7gqdzQTA+21BDuraaqqpSqgLVuCZGxTahadyYmr0UErRhh723Gr1lRv8dcsOivHEr
         1+w0HcwGayKyzMs9uNlW5FOPNrxLsnBPTH6xE8odEW0O2mjfqIkjzOoxp9Y1CjcmqNfj
         XSg2EUnOQTFKI14zcceHIiglwsM/9XWggWVoan8xfSmHH33fbAtXEqvAmLP2lbJdeSJU
         kOF+Tpb9HRfVdX3NatYpEhIG0Sgky8tCNocA8LPoXiqFC+2JW7ehmUlKIPqN55aesyL7
         ZG/Lcp3XjLj6mpPFkU+TVPnQS2TJseeqwFIYAcWPWOlTAz8UIl2UJlHJceV7T5nxRkAJ
         9ngg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k10si3194475ejs.195.2019.05.28.03.50.26
        for <linux-mm@kvack.org>;
        Tue, 28 May 2019 03:50:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 090F8341;
	Tue, 28 May 2019 03:50:26 -0700 (PDT)
Received: from [10.162.40.141] (p8cg001049571a15.blr.arm.com [10.162.40.141])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AC2493F59C;
	Tue, 28 May 2019 03:50:21 -0700 (PDT)
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
To: Michal Hocko <mhocko@kernel.org>
Cc: Tim Murray <timmurray@google.com>, Minchan Kim <minchan@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Johannes Weiner <hannes@cmpxchg.org>, Joel Fernandes
 <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>,
 Daniel Colascione <dancol@google.com>, Shakeel Butt <shakeelb@google.com>,
 Sonny Rao <sonnyrao@google.com>, Brian Geffon <bgeffon@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <dbe801f0-4bbe-5f6e-9053-4b7deb38e235@arm.com>
 <CAEe=Sxka3Q3vX+7aWUJGKicM+a9Px0rrusyL+5bB1w4ywF6N4Q@mail.gmail.com>
 <1754d0ef-6756-d88b-f728-17b1fe5d5b07@arm.com>
 <20190521103433.GL32329@dhcp22.suse.cz>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <719d3ebf-c6c2-2468-4f04-0ba54b74b054@arm.com>
Date: Tue, 28 May 2019 16:20:33 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190521103433.GL32329@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 05/21/2019 04:04 PM, Michal Hocko wrote:
> On Tue 21-05-19 08:25:55, Anshuman Khandual wrote:
>> On 05/20/2019 10:29 PM, Tim Murray wrote:
> [...]
>>> not seem to introduce a noticeable hot start penalty, not does it
>>> cause an increase in performance problems later in the app's
>>> lifecycle. I've measured with and without process_madvise, and the
>>> differences are within our noise bounds. Second, because we're not
>>
>> That is assuming that post process_madvise() working set for the application is
>> always smaller. There is another challenge. The external process should ideally
>> have the knowledge of active areas of the working set for an application in
>> question for it to invoke process_madvise() correctly to prevent such scenarios.
> 
> But that doesn't really seem relevant for the API itself, right? The
> higher level logic the monitor's business.

Right. I was just wondering how the monitor would even decide what areas of the
target application is active or inactive. The target application is still just an
opaque entity for the monitor unless there is some sort of communication. But you
are right, this not relevant to the API itself.

