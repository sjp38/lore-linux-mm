Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60FFCC48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 14:20:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2362F2085A
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 14:20:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WNnNyq3R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2362F2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B101A8E0015; Thu, 27 Jun 2019 10:20:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A99DB8E0002; Thu, 27 Jun 2019 10:20:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 962338E0015; Thu, 27 Jun 2019 10:20:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E86C8E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 10:20:29 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id l16so2545571qkk.9
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 07:20:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ibMkJJWkf9wfeR0beVqPsWCh5Yhblc2HN5zfVuXpgPc=;
        b=ttUvkq3AIpMApYAJ7fkErFR8FhUH6sydu73K4KZMPqT5vpv0SL3UJs6kHlPvN2oBTf
         NZnK2/pco+MrtchDpLE9YhD8Tk4bpGFeIxDvOS8q/lApwm+kHZAb2Q61o63QNJJ2MdZJ
         Ha6LzmLRr2oZ9OL5D1voQUfJE3PPc5f3GO7k8c/DcRR7FxhOfkLCPjxdnN1lGlCHZCUS
         HqJ8tU7BaqgTfKW56XvZzZK8PVXhomOea3Yszk3AgfXKBAgr//mkT5tDovPTZ1LJV0tH
         ccMfEPLMlIIgOdJcZEvco1mMUpK5fqskVnItI7LdHn/yRHrDPbOEyc+enCK5HxKt+8Qs
         OUzg==
X-Gm-Message-State: APjAAAUjogDHZdM3pyiG6pfriioAplbJG4gg1zTZPSBJfrGaSz+ENfn2
	bd6HlufMKmVDx8irFf9ISmwhicv9j7NuUr0fdxxBI+6ft9w9B/gRS/uqa2krnMI0D87j/FSiDPs
	Ow/vHTfNvBoaFwikUZLYoqQiBUd14O7/vjAga32EAUjniX0oTF9xkqwGYA5kcFQE=
X-Received: by 2002:ae9:ed8f:: with SMTP id c137mr3706388qkg.471.1561645229243;
        Thu, 27 Jun 2019 07:20:29 -0700 (PDT)
X-Received: by 2002:ae9:ed8f:: with SMTP id c137mr3706355qkg.471.1561645228794;
        Thu, 27 Jun 2019 07:20:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561645228; cv=none;
        d=google.com; s=arc-20160816;
        b=dHYsQOuSeHKRXGvEttX2pW5UoWBXE7ypOAKVDYDnq9QNvA6d8RJYh/b6nDFMkD9omB
         9ynks5Wqvo+6QwC1WKnnC9X7axfLoC2FkDIQzjukmAgwopCsiNxwU2gjhEdP4TkG6jlA
         ILp7IW+wsdJMsd8ovzornb2ANfN7kccbPYxAxkYGa97HCf7ZbWGK4s98EiwxxOT2uN8I
         +tVMDj5om1+RkwH4jpRX2XVUjeC1XPjxd+JfX1RaibzPnAfhODoLzHoGMZr2p30gcxnB
         X5pOGZ4b+gSclbGW5uWqILlAqYRQzIQ3GIeOb2uzLM7OzhMNUKzlQUthWl0jMnp3z5WB
         uvDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=ibMkJJWkf9wfeR0beVqPsWCh5Yhblc2HN5zfVuXpgPc=;
        b=bcamg9DdEanLN7WPkUckPIyGF2LpoTGBdjbtR+g2ZFHgk/vX+iuwbZoUf3nt8XvK40
         GYrFQ84VOFyuV+vkEDNi/k2ZHICjW7f3RCrZx3eYi88Rzikn6Bw+1/yTyO5vfsro25xD
         pLvKVmcn/oZvV0hnvisPAuMOzJA8nrUc9EW/+L7YJUDvhf3f5md3gDKQ4u90J7leOZ20
         iKyxmzqZvE+YK6XKjNhfLk/PSpHgk4HxcZc4xS0WS+rR920yAOky4phB2h1revprPOG/
         7zaGF65L79A7iG5V+G/oYWLO8HC6wVsysXoaxwz9MukqusONkR2GAGXd4WEhHpbRuZBk
         OlBw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WNnNyq3R;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 2sor2086964qvf.55.2019.06.27.07.20.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 07:20:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WNnNyq3R;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ibMkJJWkf9wfeR0beVqPsWCh5Yhblc2HN5zfVuXpgPc=;
        b=WNnNyq3R8FEYB2OR4flGfDaN1gAY7zPvl1DH6UtOPQvFdLJb3HAALzv3EDVY/ywtdl
         TpKnrFAROO6vLbl+cRlP7sQ/1Lc580ODR9iQYsWRhQPGRdN8YIyadlaHheXQdXZofolU
         R8XFUCJOYrgrWI9K8MuvklrUsp0h60A6/ga0KIQ8nFq1NYb0GJIUnq8stt4LOn0nAA35
         AQ3BLdfljIXqXQUYnWdrvO0xLRuPg31xcILy/wmDpdItAuKlMBglKb0a/CspeBgyrgLq
         F0l4pO6YScXuy6RtPMh/BgdclgtR8UQWLIqcUDte8+04k4YUjlcbMMIw3z0ZZiZ986yh
         SsnA==
X-Google-Smtp-Source: APXvYqzz3ddo5kehN94RkRnIMw8EXVljFjNANKZxMc7zBPdyQt10KTunLVInpbJ3F2ZQzhNNjIcNhg==
X-Received: by 2002:a0c:d0fc:: with SMTP id b57mr3618236qvh.78.1561645228288;
        Thu, 27 Jun 2019 07:20:28 -0700 (PDT)
Received: from localhost ([2620:10d:c091:480::5a51])
        by smtp.gmail.com with ESMTPSA id s134sm1084648qke.51.2019.06.27.07.20.27
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 07:20:27 -0700 (PDT)
Date: Thu, 27 Jun 2019 07:20:24 -0700
From: Tejun Heo <tj@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Shakeel Butt <shakeelb@google.com>
Subject: Re: [PATCH] memcg: Add kmem.slabinfo to v2 for debugging purpose
Message-ID: <20190627142024.GW657710@devbig004.ftw2.facebook.com>
References: <20190626165614.18586-1-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626165614.18586-1-longman@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Waiman.

On Wed, Jun 26, 2019 at 12:56:14PM -0400, Waiman Long wrote:
> With memory cgroup v1, there is a kmem.slabinfo file that can be
> used to view what slabs are allocated to the memory cgroup. There
> is currently no such equivalent in memory cgroup v2. This file can
> be useful for debugging purpose.
> 
> This patch adds an equivalent kmem.slabinfo to v2 with the caveat that
> this file will only show up as ".__DEBUG__.memory.kmem.slabinfo" when the
> "cgroup_debug" parameter is specified in the kernel boot command line.
> This is to avoid cluttering the cgroup v2 interface with files that
> are seldom used by end users.

Can you please take a look at drgn?

  https://github.com/osandov/drgn

Baking in debug interface files always is limited and nasty and drgn
can get you way more flexible debugging / monitoring tool w/o having
to bake in anything into the kernel.  For an example, please take a
look at

  https://lore.kernel.org/bpf/20190614015620.1587672-10-tj@kernel.org/

Thanks.

-- 
tejun

