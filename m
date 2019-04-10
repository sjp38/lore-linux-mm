Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED162C10F14
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 15:34:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8BAB20818
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 15:34:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chrisdown.name header.i=@chrisdown.name header.b="xJDIIxl1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8BAB20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chrisdown.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4387A6B029F; Wed, 10 Apr 2019 11:34:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E7C46B02A0; Wed, 10 Apr 2019 11:34:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D73A6B02A1; Wed, 10 Apr 2019 11:34:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id D41EE6B029F
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 11:34:56 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id k4so1649121wrw.11
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 08:34:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=arxBGNSX0OUYGmyljwVEu7bbeV7OhkzO+FdllTWnzPo=;
        b=if8UTdMRlxtLibvXMroMHYhumptiIO0MuHS2lxnqBQwppIycxT9tyLJWbTUEOkGQ9f
         gEsYe4WUK7i+PHG+lEJf1b4HHdfiCQYEI0JNYpv5k+1qhClwb7jQ9n5ddaTs5LIee093
         TlzYxf+Sj+msMIijYZhkv5++xOBH0wlojseAtlhSgGwysmjHRFstPnj6MjsA2tJ8QdTQ
         iEYxbQLdSawYeTVZiCxdZtsP+sVlFVLcwrYVJ2Kk5g2+CX4vU0m0oSWKCJX+oisryeE+
         kaVrMb923wiUjRXo28x+M4FXDrEbr9NKrXB9KynQGuoC3A8Seg6B69X6AwnKIyIZCPiE
         PHww==
X-Gm-Message-State: APjAAAV4pmMlTo/Xc5+PINV1B5mCzz6ynzTIk+4T6JEUDO48LT5k0Udb
	cwI7eoWGda+GYc2Gh/D5PvAVO84x0hQCYPOdD0b9aXGg0l29hLGukLddpxjSNC2tAkI5Wrx61Cr
	ot8CaPxi2myBn9MxKj6pS7OT5knIdqOTPE7pbKQRHeKbybwy8u5GoxC/ReqwIJQ7NGw==
X-Received: by 2002:a5d:4b01:: with SMTP id v1mr26817943wrq.48.1554910496265;
        Wed, 10 Apr 2019 08:34:56 -0700 (PDT)
X-Received: by 2002:a5d:4b01:: with SMTP id v1mr26817902wrq.48.1554910495582;
        Wed, 10 Apr 2019 08:34:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554910495; cv=none;
        d=google.com; s=arc-20160816;
        b=yGfX/jt1ql7SwF8++9sv18mJLhV6Z8wf3cCcvzBElw4cR5UuU+mfyRy2UPDDyjYtwl
         Ru7UxLyV7jSd0MWxt6988H3bCuccBgwaBvSU6nr5ChkNDdEyGJEKbFcAmwwtM73lI0O0
         Hku7eBjZ6Lmlt0/FjRhelmJn/inpPUgl+cXulZukZiHie6ZNxST5wp+2VdI9TZ8pd6dc
         7lLN7BCJfH8dioBVInKVef9vIsEuhHo3wBBpUobqJ/3lT9qEEkHShOWGk++kuvir/ECJ
         tCZmXVnsT7vdeWLM7CRjg94y792Iv/i8aeIjL3gyRabSeK6qt8/BGYa2v/f86iUV5OM6
         HPQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=arxBGNSX0OUYGmyljwVEu7bbeV7OhkzO+FdllTWnzPo=;
        b=apHv9UtjjOg26lCWkqN+Ci/g/tXlyx7UF2ulP9HPLWtOMBQcOVYvFt7UwsjSPm5QUD
         LorilncFRKXYG1S8PFcRsOZATxP0qTRC8B+B4OcoDNCCKzObEUHVvoDf4PquhMMfjyKZ
         QiP+GNB4PbeqS7M5Jq7R8WZNTuh1C1GUFBdbl0IeaFKuzm54nTcIB61dI6e9Hs9Qo6zQ
         wH2y/F5EMXNVVVfM8OXpBb0aAAfSI0prUEjWIJI8qbcO9zYfHtgMMNn5PiAz8pYPUNji
         u4mvZgY6OuLOQIbK1wlg+7+AyiyXD3ajQCp4k3UXSzXT6quTc8aV5agwi1JObYfxqsKq
         u3ug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=xJDIIxl1;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w2sor26393405wrm.19.2019.04.10.08.34.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Apr 2019 08:34:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chrisdown.name header.s=google header.b=xJDIIxl1;
       spf=pass (google.com: domain of chris@chrisdown.name designates 209.85.220.65 as permitted sender) smtp.mailfrom=chris@chrisdown.name;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chrisdown.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chrisdown.name; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=arxBGNSX0OUYGmyljwVEu7bbeV7OhkzO+FdllTWnzPo=;
        b=xJDIIxl1eeL/dAIbEYlOuZSAFwejku7gsZgBW1BS1TBrC2f9JSBLITDJqVqs0PSeI4
         maDchJybAJdG0zBjinmp9wRxhX9DKa0H/MmG6XAo+vD62eSzMbE6SshIV9gtBlg76KPQ
         89iiOrmmBwbKuVrud8G0hORSsuQSWFNviuPfM=
X-Google-Smtp-Source: APXvYqwZJTtXFr6jhEhKPNCvW4MV9AmarGhvGr6jmEIy7i40TneIr27Iec90v8rr29B2QsQpsb/+5g==
X-Received: by 2002:adf:f050:: with SMTP id t16mr23381660wro.198.1554910490281;
        Wed, 10 Apr 2019 08:34:50 -0700 (PDT)
Received: from localhost ([2620:10d:c092:200::1:4ff4])
        by smtp.gmail.com with ESMTPSA id 7sm122837004wrc.81.2019.04.10.08.34.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 10 Apr 2019 08:34:49 -0700 (PDT)
Date: Wed, 10 Apr 2019 16:34:49 +0100
From: Chris Down <chris@chrisdown.name>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH REBASED] mm: Throttle allocators when failing reclaim
 over memory.high
Message-ID: <20190410153449.GA14915@chrisdown.name>
References: <20190201191636.GA17391@chrisdown.name>
 <20190410153307.GA11122@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190410153307.GA11122@chrisdown.name>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hey Michal,

Just to come back to your last e-mail about how this interacts with OOM.

Michal Hocko writes:
> I am not really opposed to the throttling in the absence of a reclaimable
> memory. We do that for the regular allocation paths already
> (should_reclaim_retry). A swapless system with anon memory is very likely to
> oom too quickly and this sounds like a real problem. But I do not think that
> we should throttle the allocation to freeze it completely. We should
> eventually OOM. And that was my question about essentially. How much we
> can/should throttle to give a high limit events consumer enough time to
> intervene. I am sorry to still not have time to study the patch more closely
> but this should be explained in the changelog. Are we talking about
> seconds/minutes or simply freeze each allocator to death?

Per-allocation, the maximum is 2 seconds (MEMCG_MAX_HIGH_DELAY_JIFFIES), so we 
don't freeze things to death -- they can recover if they are amenable to it.  
The idea here is that primarily you handle it, just like memory.oom_control in 
v1 (as mentioned in the commit message, or as a last resort, the kernel will 
still OOM if our userspace daemon has kicked the bucket or is otherwise 
ineffective.

If you're setting memory.high and memory.max together, then setting memory.high 
always has to come with a.) tolerance of heavy throttling by your application, 
and b.) userspace intervention in the case of high memory pressure resulting. 
This patch doesn't really change those semantics.

