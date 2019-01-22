Return-Path: <SRS0=7n0b=P6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 170DEC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 21:44:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B47D7217D6
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 21:44:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B47D7217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 206D18E0003; Tue, 22 Jan 2019 16:44:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B5118E0001; Tue, 22 Jan 2019 16:44:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A6288E0003; Tue, 22 Jan 2019 16:44:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CAEC28E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 16:44:17 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id s71so22363pfi.22
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 13:44:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=WmCJIgU0U+rMXlSQge28ZABnQmUUFnt4rL6spZNid/o=;
        b=VVbxbD0jw9NlGTHXwYhLbLJd0eo772roFrBc6EAtN390nGYsWOI1MztmeMFpQmsxXR
         LLhwHDTUWYUhYvsOvI8RF/qXA8WJ0rsMl+kR/dKo78ahxsSqQQkWw0+lSgrfA1+ulo6I
         V+HRogfGwJyxgUeeIHKpHCQ49Yepmpye7BPsh5lj16D7xAD7Y2EajZ2w63diLzjk361i
         xtnfyejK5yxkM7B9MPjLlYcAURUBK6DD5BgIYVZUD7bkllCreCHgkhkXP2kBFdy1GOsh
         NSIWgeLsCP2ckNwJOObAS8b5tFts8H7mHY4a33InDpFCLD1beBMcWwVWDw1H9rc+j65h
         LMoQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of ak@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ak@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukdBqglmgbC6nstSdXrAAXaAZHlbZPfvUoYrx0mv3bpJepHlLmtz
	lk3oLMeN/QpqnAPsxK9WsJKh1IriSmVwuJiXBx53QT/WlEujnlRVcHMtYhIbBAGh0vMPvkDB3KB
	J0iTn7MYw2VM1IjVXZObsMIcGNSLY/W6B5kJHeYamw28HA9lapdiFzEK8DhaMdL+fiA==
X-Received: by 2002:a62:3241:: with SMTP id y62mr35030342pfy.178.1548193457496;
        Tue, 22 Jan 2019 13:44:17 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5Di6cL8lTpNBK5npo6nuCiZnqQ/kSjGAAREXMFk1CQ6gg/WQNTFvKYO4GKeoAKymozCjs/
X-Received: by 2002:a62:3241:: with SMTP id y62mr35030308pfy.178.1548193456681;
        Tue, 22 Jan 2019 13:44:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548193456; cv=none;
        d=google.com; s=arc-20160816;
        b=G3TceHQDbGa/GWxzOkKVW3wLGYI+FLtBwkgsUlUCjFbuKEyvSYFC6PFBiozbhi3G5P
         +vG/u+kqPhitnwMEvrslUEwgTLioy1UT/YcBfqt4UnFDjSxXE0gcTvo3EdUXn+tB+jFn
         7nYNqGUGH4Jehpl+t4TGUBQ75P1/n15RjC5WUzXWxISPzKZj/svyHuX5OVkH1tM5Hj/J
         HysKObYO2po4iYWf7363TAyG6hFn+rlsjnUHMwd6O7p7c787mwti2/QdjKFD2e7yF/vR
         NUCC9SKbLXLiSiyuErLA8UrIALaA4Y8EO3RZnp4F/6+N+dIuBeYTi1r4egn3Y4r1D0Xs
         QwvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=WmCJIgU0U+rMXlSQge28ZABnQmUUFnt4rL6spZNid/o=;
        b=YPBCcSxW7h3iGyIKM7rapSnZm1XUqihvXr7eAu50LEYYGnaZWkKsjKCILYbgYbSUqw
         lUPYmww/i6OmuRuE0O3BflhLNugbjiJ69mKCaKWZCwjemzKFvQDUstzkrzsjHLDRQEvJ
         4tK3Bm5JMj8xt9f5Zo/FjCfLS23KbtaxuI8JPS8NOxH0fZT3k2kUbNoXG0deKIzc9CxD
         DDFQjL7DlEP+ySpKY0tGJEa/V0MgKHtdr6Dr4JQY+XnxSeWHh3b0kcOw9rbHa/QeuRPj
         aXX3kobnxsB4nBr6+hFravcTZ5SacK4aWv8JmXwSzxeQGmhZdc/Xku4l3KS3dDxbwebD
         UYHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of ak@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ak@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f5si11526028pfn.259.2019.01.22.13.44.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 13:44:16 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of ak@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of ak@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ak@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Jan 2019 13:44:15 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,508,1539673200"; 
   d="scan'208";a="128046630"
Received: from tassilo.jf.intel.com (HELO tassilo.localdomain) ([10.7.201.137])
  by orsmga002.jf.intel.com with ESMTP; 22 Jan 2019 13:44:15 -0800
Received: by tassilo.localdomain (Postfix, from userid 1000)
	id B3876301202; Tue, 22 Jan 2019 13:44:15 -0800 (PST)
From: Andi Kleen <ak@linux.intel.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org,  linux-mm@kvack.org,  linux-kernel@vger.kernel.org
Subject: Re: [LSF/MM TOPIC] Page flags, can we free up space ?
References: <20190122201744.GA3939@redhat.com>
Date: Tue, 22 Jan 2019 13:44:15 -0800
In-Reply-To: <20190122201744.GA3939@redhat.com> (Jerome Glisse's message of
	"Tue, 22 Jan 2019 15:17:44 -0500")
Message-ID: <87tvi074gg.fsf@linux.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190122214415.iWizBunTWe7pg9VQwJ8u15R0TEnThblVlFyR7MxLUE0@z>

Jerome Glisse <jglisse@redhat.com> writes:
>
> Right now this is more a temptative ie i do not know if i will succeed,
> in any case i can report on failure or success and discuss my finding to
> get people opinions on the matter.

I would just stop putting node/zone number into the flags. These
could be all handled with a small perfect hash table, like the original
x86_64 port did, which should be quite cheap to look up.
Then there should be enough bits for everyone again.

-Andi

