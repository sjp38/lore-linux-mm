Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35FFAC28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 20:52:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D562126153
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 20:52:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="P7oOZgl3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D562126153
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AE246B000A; Thu, 30 May 2019 16:52:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35F336B0266; Thu, 30 May 2019 16:52:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24E306B026A; Thu, 30 May 2019 16:52:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E40196B000A
	for <linux-mm@kvack.org>; Thu, 30 May 2019 16:52:16 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u7so5438380pfh.17
        for <linux-mm@kvack.org>; Thu, 30 May 2019 13:52:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=6xW2J8Id+5nx2KJz7k0sgVn959SqhmXLM/78ZxNyQrM=;
        b=ZMdohpPEqPS9aHlLmNteWEGy/rclCLzNk/cNzqRAKXzNLQD1Vm1fWp91kEzvvO+9/U
         8VAiSODmo/OWlJaoDx9x5Sznoh+NzZMWc57ULkXwAg/dEHZ5AtR7rEL/3IdXhZKUwdTX
         +5oyg34h1SajNPyihvFrtB7Qhuo8DxJTPDatvVMfGrmVpoOnvfkl5qCYQ4b5wWQ6nNkx
         C5Yobi3X6QtzfBAYndfCsjFUn+c38Y3A3zPfpsbDPIMblV2Oe4rI6qO/8GIDodftXePr
         b9xlYKjY+29lrJzr0rqZFpEloob59ZL3Vo4t1bZ/D9P7FXsUaH1N64q0IdVKY5FqZC4I
         x1cg==
X-Gm-Message-State: APjAAAVJPE5zqA5QyRyGAA0sIfCjZtfeZCczjQno+zpV+WW3JdgbIrVV
	7jfHnx1xjGpll5jVStS1mmNJlVYWsDFxhzqNJ0KEkXJg648oWlSGJwDsxVAXd1rbVHGhNcNh8LK
	fbX8a9ZAIvTRoI9gohensjm1mQ6asDivAdzk4mLlSd4+OzYYi458hHg8fNM3PiWDByA==
X-Received: by 2002:aa7:93ba:: with SMTP id x26mr5546769pff.238.1559249536573;
        Thu, 30 May 2019 13:52:16 -0700 (PDT)
X-Received: by 2002:aa7:93ba:: with SMTP id x26mr5546612pff.238.1559249534008;
        Thu, 30 May 2019 13:52:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559249534; cv=none;
        d=google.com; s=arc-20160816;
        b=iChkJw9dYRH6FwSmbavJpvMjVdGOcj7G/dFq3dbZ3cY5WfhsoQeW0RqeQlJ3c8sQfB
         gynU1UvU9n+3LZ1qVuusAJB4m5zTRovaS4VILzophw4tWghTmaRmnCe8+JowdYFClAcn
         ICuN5kgWkRBjJooQZyvIh+/g2PFRVWZnzDrfovpmmdjPzFPFhFzJPN/3xSMoYAzKBuk4
         2tBHcIvkw2dFKc+YqnDk68jMR+EnfyEZv1rIht0PbakHiP+kem4tESkyNWG2cm6CBYV8
         9zwyH40Jzf8+KrkFgURAoo34bjg40RXRpR1QFQt4DS7iZ+hP0fyE+YOIVeDcMyLoJ7/Q
         4gpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=6xW2J8Id+5nx2KJz7k0sgVn959SqhmXLM/78ZxNyQrM=;
        b=On+oiQi2c+M47mNZtY6Qvc4voF/GR9oJ8BvWKMuQKN8cKdOCp7sniT1juo0N1V6pjC
         vZ0x++6XBL5QSctjd+y9342GitzuyfiMuYiPAhr0M3cje1KpKNJ4hlv+wAgube5buA5o
         PNS2ITm9q70WMz5q7flWyRBJVpPD4VX6aFgGPwvLNNvYRyXTiHiPy284tmxmlZBKHfhr
         aIDp/bhQdefvrKmtI4Ar6H/DaQF9JjxXbDG5zgV7zTyAbcaReYA7PFqHlWj6Tpy4cEBJ
         rFaYaa8U9VXkbBiG4QqaWpgmiGvNnRvJiU7gBVnz0QqQujwqBMGGZRhyI7PDMNXrdspD
         NI7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=P7oOZgl3;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j25sor4128247pgb.31.2019.05.30.13.52.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 13:52:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=P7oOZgl3;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=6xW2J8Id+5nx2KJz7k0sgVn959SqhmXLM/78ZxNyQrM=;
        b=P7oOZgl3CtO57JCewH/kKTPTub5g44+HbkPoxMUgXSg+G+mYhHLm56nrj0Ca0w4uXe
         1y5o+9cwnqcke09kZKrZ07g+cQivOFM52Jn56eiI9G38mT2W5A58AY/pnXbpMkHnaf6b
         YmGt4GV5AsM5rEH9QzxxTZrA7C0HqUi7G0YlE=
X-Google-Smtp-Source: APXvYqw2Vrsl6MhrLN4N404XzV0x9D1AP5nF4XCE2sc5cXxgq1gpcLjWmpcQqB50nghux+A2TsCiFA==
X-Received: by 2002:a63:4006:: with SMTP id n6mr5564930pga.424.1559249533347;
        Thu, 30 May 2019 13:52:13 -0700 (PDT)
Received: from localhost ([2620:10d:c090:200::ca0f])
        by smtp.gmail.com with ESMTPSA id b3sm4127765pfr.146.2019.05.30.13.52.11
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 30 May 2019 13:52:12 -0700 (PDT)
Date: Thu, 30 May 2019 13:52:10 -0700
From: Chris Down <chris@chrisdown.name>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH REBASED] mm, memcg: Make scan aggression always exclude
 protection
Message-ID: <20190530205210.GA165912@chrisdown.name>
References: <20190228213050.GA28211@chrisdown.name>
 <20190322160307.GA3316@chrisdown.name>
 <20190530061221.GA6703@dhcp22.suse.cz>
 <20190530064453.GA110128@chrisdown.name>
 <20190530065111.GC6703@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190530065111.GC6703@dhcp22.suse.cz>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000005, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Michal Hocko writes:
>On Wed 29-05-19 23:44:53, Chris Down wrote:
>> Michal Hocko writes:
>> > Maybe I am missing something so correct me if I am wrong but the new
>> > calculation actually means that we always allow to scan even min
>> > protected memcgs right?
>>
>> We check if the memcg is min protected as a precondition for coming into
>> this function at all, so this generally isn't possible. See the
>> mem_cgroup_protected MEMCG_PROT_MIN check in shrink_node.
>
>OK, that is the part I was missing, I got confused by checking the min
>limit as well here. Thanks for the clarification. A comment would be
>handy or do we really need to consider min at all?

You mean as part of the reclaim pressure calculation? Yeah, we still need it, 
because we might only set memory.min, but not set memory.low.

>> (Of course, it's possible we race with going within protection thresholds
>> again, but this patch doesn't make that any better or worse than the
>> previous situation.)
>
>Yeah.
>
>With the above clarified. The code the resulting code is much easier to
>follow and the overal logic makes sense to me.
>
>Acked-by: Michal Hocko <mhocko@suse.com>

Thanks for your thorough review! :-)

