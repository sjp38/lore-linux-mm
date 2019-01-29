Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E078C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 14:52:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B577020989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 14:52:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Dz35Rfkm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B577020989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08AFE8E0002; Tue, 29 Jan 2019 09:52:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03AEE8E0001; Tue, 29 Jan 2019 09:52:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E44838E0002; Tue, 29 Jan 2019 09:52:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF5338E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 09:52:45 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id l82so9796070ybc.22
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 06:52:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zQdBRqPFHOQNaO1SDGHuI8AHS8ubhF0Kp7ZKbPRa6WM=;
        b=CKGXaJRf164YcGvGHYKbkumSe8zySpjZcpnt8GBSsYRMOq8lVuEU4j3O0+9IUgAcHQ
         l00hjkzoJO0+JDd+TmTIc4uZli+LL9268V46YBnXD8PvABC2zTKmDvt6gOBFByWjFuuo
         JVe6wPI5p+c9rdCW7pKsH2v72vwG5RS4i4iNlJQYvI9WE1gRwQ35EF9ROyCYQMQTtiuu
         I+lQmDXGR0lFomts0fzGvPDbkF+Qf+doW33mwAWkPvq6VUxSSdxmn5GFUfUjzZEp5ZdQ
         6D/y6uAjOh3JmjEhnzTlzJ0YkwjzFn5D9C8n/Ybd02GT5w4C7IseqcKfWG6bgg7Al59/
         XHPQ==
X-Gm-Message-State: AJcUukfBxkzR3Qygy+VQCPij1g+Ar8Artwu7ZeaC2Q9GByXSzS9/GTyG
	Sp/2p/i4Try5cCU6ptltrLhQiYg9QIgwltL7NwiRXnlL2cMrnSoIt+YCvwRpKIUi5k8RbsugQF4
	eIWvcYCZZvWyuMFeg92qNblHKjcizrfhp2i6pW6V+2lbJtUpAa9IJn9Pxpo4wngH4uYIwGtPDwR
	Kb6LgOg30Qw+NlPXjrC6Lb2jhbvwVPkAzKKLO+rYd5eg+lM9prsV10eJx1mm/nmbXUAUO1O8972
	rC+nk9vg35ainy7v8qwF4JWKvUzumnIgKmSZ186I6Rj/lAGEVqYZsd4+leYTcQZhVHTCNoZh08K
	rFUtDs9VEutBdXCG299FzmSqrTwTD4X7bhvrrPNcCES+pMXfQxDN2mRXWpJ4PpDsZ3DBRS/H0g=
	=
X-Received: by 2002:a81:e14:: with SMTP id 20mr24752261ywo.87.1548773565337;
        Tue, 29 Jan 2019 06:52:45 -0800 (PST)
X-Received: by 2002:a81:e14:: with SMTP id 20mr24752239ywo.87.1548773564841;
        Tue, 29 Jan 2019 06:52:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548773564; cv=none;
        d=google.com; s=arc-20160816;
        b=jZSkEmI5AwEryA0XKcoOKMlWzkF16RWIRLSmGL0HcHZl0aBEgzxlQRGdaxsZhtVLIf
         YDXfXPcyh6USq5xxj9UfF7T+vPH+9/Y/OvQCAvInrSOGe4XaBIh+w0759TyrzhvM4xpq
         fHwDkjRdgbiKsVTQwAsbk7ftSey3yJLseaijMoTGLpc8USQlTq9KWIxh6KJfI0/ZMOZc
         0HQ8+SMbnQqrxEYoRLf34d2X8NVchGayYtDVKheVHd2p6gSsOwbqaOFKyc3Clwsjr62J
         62DRu8e9mZhk7rFqfXoadAlezQz36JoJ02OMC7Zwfby0N8OKM9MQ6FvZdY/X6X6p4/Z9
         K0pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=zQdBRqPFHOQNaO1SDGHuI8AHS8ubhF0Kp7ZKbPRa6WM=;
        b=V5E5k+BPFLIiRF1OaGhn0h+4dZpMknXme7il2GS+1tcYfEKlDCo1KKZmS9bNlXJi8Y
         rc2BYe0AHAjl4NeelldRd7CeZ2K5CUykLcegjGnsrl/8ONdmeSgA3v4y5KGT771I+ajI
         3ShASVX6EEbcVerHGqRP5vWpP+a1UPWipSxfbsC7nrlbNJfoZ8KvWlZ/G4azcWvR9wyb
         b9BFypf5kzVppyOUoM/TWY13zEFZ8GT81upbF1WGVteATp+MNmUrpuPE9icgHY4bn09i
         iYM8HlmuT5DmrS7h6GZzty19FR16glPxyVyMIiUwSALp3AjBCFghiz20L2L2mLLyzRhH
         j/5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Dz35Rfkm;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u192sor4784216ywf.109.2019.01.29.06.52.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 06:52:44 -0800 (PST)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Dz35Rfkm;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=zQdBRqPFHOQNaO1SDGHuI8AHS8ubhF0Kp7ZKbPRa6WM=;
        b=Dz35RfkmFlIAefYXONkJks2DWh4gCYSnDKx7Ic9HCprDFYX5Ou5vbuEIkXMn+z+fVO
         JlHPuKDsGHYaZ5pZSVsoIO7EAEa11SntplExSN4clqxj1CByxBGlYVrJST4PezDYw34n
         Vc/jMONPC/0IrDFDJG3YbY7XtYxPITE6fLy2D7OpGo1S1N/Z/E02SXKASbQoaIFKVk7G
         gBWy0pe9nZYbE5UcQFeAvBwRLg+/EDPeW4VWsHdPRYpsNKmZdE398QzmsTJKW9nGvl+i
         92Mpet2l+ATxjKuy62Xea++iKrZ7k8T3k3Rk3Aj5HsH1IS3R+V/R7YoWg5HgP5Pd274u
         s6Yw==
X-Google-Smtp-Source: ALg8bN4aink6rsz+TOQ2if0OOpZyL9ApwVWIWHdHrCpHq2n7sxOckKcbDvWJxHmW4VOUUW11u4088w==
X-Received: by 2002:a81:8a07:: with SMTP id a7mr24626349ywg.403.1548773564329;
        Tue, 29 Jan 2019 06:52:44 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::7:19ad])
        by smtp.gmail.com with ESMTPSA id d4sm13949191ywe.104.2019.01.29.06.52.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 06:52:43 -0800 (PST)
Date: Tue, 29 Jan 2019 06:52:40 -0800
From: Tejun Heo <tj@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190129145240.GX50184@devbig004.ftw2.facebook.com>
References: <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <20190128125151.GI18811@dhcp22.suse.cz>
 <20190128142816.GM50184@devbig004.ftw2.facebook.com>
 <20190128145210.GM18811@dhcp22.suse.cz>
 <20190128145407.GP50184@devbig004.ftw2.facebook.com>
 <20190128151859.GO18811@dhcp22.suse.cz>
 <20190128154150.GQ50184@devbig004.ftw2.facebook.com>
 <20190128170526.GQ18811@dhcp22.suse.cz>
 <20190128174905.GU50184@devbig004.ftw2.facebook.com>
 <20190129144306.GO18811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129144306.GO18811@dhcp22.suse.cz>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Tue, Jan 29, 2019 at 03:43:06PM +0100, Michal Hocko wrote:
> All memcg events are represented non-hierarchical AFAICS
> memcg_memory_event() simply accounts at the level when it happens. Or do
> I miss something? Or are you talking about .events files for other
> controllers?

Yeah, cgroup.events and .stat files as some of the local stats would
be useful too, so if we don't flip memory.events we'll end up with sth
like cgroup.events.local, memory.events.tree and memory.stats.local,
which is gonna be hilarious.

If you aren't willing to change your mind, the only option seems to be
introducing a mount option to gate the flip and additions of local
files.  Most likely, userspace will enable the option by default
everywhere, so the end result will be exactly the same but I guess
it'll better address your concern.

Thanks.

-- 
tejun

