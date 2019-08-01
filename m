Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E7C2C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 13:42:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49D8B20838
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 13:42:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kam.mff.cuni.cz header.i=@kam.mff.cuni.cz header.b="pvLWO7li"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49D8B20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kam.mff.cuni.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D84828E0016; Thu,  1 Aug 2019 09:42:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D34E58E0001; Thu,  1 Aug 2019 09:42:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C24AD8E0016; Thu,  1 Aug 2019 09:42:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 74CE88E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 09:42:53 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id b14so35469710wrn.8
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 06:42:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=Tgtx8AU1eDvtzwgrnSCNWwtGnoWIuLmdAOsYfNaJttw=;
        b=rJOyV4w1SJqIP0WSTWdy6wa3x3U8pw9PJhSk7W8tPPkIJAcgDzMWSPvNMEap32vtXv
         LsaNn+e6iOY8Y45vj8DBlAn2V0ijKVIjoffMvS1uVf5rlL+5e+ehwdhQ+g2iWUCuRcOv
         tzDtDCC3/jJMklTKsG/8cIY108wOoqtEmvT6sEa8Wc+TwF8LVmxQNQctTxqJ3CccBK4j
         RuOq85oKMCuW0rLrZ+xl8HcgTHJZjQXbnqXXX3qb+zouq2myH9ZWiRXQOAzvIbOxynoG
         ax+mOxOekhxQQbqxkG9Hu5J9tQ8uvTRNCZX/OGHI36LF0ROGL4Pq0WiDFdhmHw+g+neG
         ScVw==
X-Gm-Message-State: APjAAAVpRpdpDuNLfCAkDIVCU3YbuoSoFv+/999oB0hjW4EpG5vVpdSO
	dVx7qP38LF4rUO7lyTwXNmNYoK5D/aIk6AOic8K1Nga+UjpiXSjR++79SqNqLwK+XKGd5L4F7NS
	3X+gg08Ej1Q72FoyP+dy6zMCOeoq9FpdhPnj6ouLqKeqYg+puu86o9IUja6EVAFmD7g==
X-Received: by 2002:a5d:62cc:: with SMTP id o12mr3215291wrv.63.1564666972892;
        Thu, 01 Aug 2019 06:42:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCJ7HjbcfFktV1ZR3azOLCucm0uB4pooyqu0xUTnOznihxNZJMRMg+Pm0sia5exFPAWqtO
X-Received: by 2002:a5d:62cc:: with SMTP id o12mr3215215wrv.63.1564666971874;
        Thu, 01 Aug 2019 06:42:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564666971; cv=none;
        d=google.com; s=arc-20160816;
        b=Ht5utCyiJYN+OLlxOROS6L3bM89i8xHJcCiY1bfA80jf6ymtrITE+Tjy2g9YizJ2D1
         K9vfZx5Ws7c6pr5W1AkGWK8qng+Ogce0cHT7+X6jlzzP+OS5PHuyoYTsHBkr00+CVMfl
         k/uDfpB8Q12EshjHIRydA5H4k79b+to5xzSlOBf+gVxsfZCsOYZbPnWdxvPXPf6xbf23
         E4VBqPR2h01iPa6nMnld1yEY3XAaZyigofNtFobAaKxBtd6YgwXHIicmr6ZlI766i0hB
         zJ94ozlm9B4m6zNIDBukIM8DmBHeTn44LVdPSZ+4tB/msb7FlEivWkF9ze2quBST3TnT
         o0kA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=Tgtx8AU1eDvtzwgrnSCNWwtGnoWIuLmdAOsYfNaJttw=;
        b=KITI653o1EE9d1cUkW9RAn6pVWL+Xt7w4pDEnTI9UrhIjIAgZaKPQMqRENNTY/bCI5
         QGUqBypeNMEgXqcxZBYcl43ZxE2S2T1PfPN3P3yjcVt/C93SCeM3lXWCdCv5kT2by4KS
         gO+SAsqTnd4xB7FTevJKkqXGVCRh+MbH8AzCBQCUSMlTkZcMG0G+Bs+Lmoc9Qxie14G5
         oT71RXnmqEO/d//6zDpzM5CaB99zy53xM5TSfqBeZQ0fy55JYr0PzKuz0jcm1cVPUNR9
         og2wzVw/WhRII+maviUCWlpXzCBJq65pCjH0NbQtAoG7/si2O+cWisd5wF1+jcycWiZe
         7ISw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kam.mff.cuni.cz header.s=gen1 header.b=pvLWO7li;
       spf=pass (google.com: best guess record for domain of had@kam.mff.cuni.cz designates 195.113.20.16 as permitted sender) smtp.mailfrom=had@kam.mff.cuni.cz;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kam.mff.cuni.cz
Received: from nikam.ms.mff.cuni.cz (nikam.ms.mff.cuni.cz. [195.113.20.16])
        by mx.google.com with ESMTPS id q4si68395706wrn.99.2019.08.01.06.42.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 01 Aug 2019 06:42:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of had@kam.mff.cuni.cz designates 195.113.20.16 as permitted sender) client-ip=195.113.20.16;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kam.mff.cuni.cz header.s=gen1 header.b=pvLWO7li;
       spf=pass (google.com: best guess record for domain of had@kam.mff.cuni.cz designates 195.113.20.16 as permitted sender) smtp.mailfrom=had@kam.mff.cuni.cz;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kam.mff.cuni.cz
Received: by nikam.ms.mff.cuni.cz (Postfix, from userid 3081)
	id 2A775281EE0; Thu,  1 Aug 2019 15:42:50 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kam.mff.cuni.cz;
	s=gen1; t=1564666970;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type;
	bh=Tgtx8AU1eDvtzwgrnSCNWwtGnoWIuLmdAOsYfNaJttw=;
	b=pvLWO7li2agCXnOPRX+RP+FfBG/H4UjD1Z36HStX9QXgqzBne9yrQdkyv4dwY6R/M8kvw6
	psKsU6cNwkhptR0NCmhwUdYXyXXJS+CHvs7YUWjnVbYdszIp/dolw8ejrWNBHYW1QRG9IB
	AEi4mT+wDS4rybhu1FxQzlzI6dAPZYI=
Date: Thu, 1 Aug 2019 15:42:50 +0200
From: Jan Hadrava <had@kam.mff.cuni.cz>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, wizards@kam.mff.cuni.cz
Subject: [BUG]: mm/vmscan.c: shrink_slab does not work correctly with memcg
 disabled via commandline
Message-ID: <20190801134250.scbfnjewahbt5zui@kam.mff.cuni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There seems to be a bug in mm/vmscan.c shrink_slab function when kernel is
compilled with CONFIG_MEMCG=y and it is then disabled at boot with commandline
parameter cgroup_disable=memory. SLABs are then not getting shrinked if the
system memory is consumed by userspace.

This issue is present in linux-stable 4.19 and all newer lines.
    (tested on git tags v5.3-rc2 v5.2.5 v5.1.21 v4.19.63)
And it is no not present in 4.14.135 (v4.14.135).

Git bisect is pointing to commit:
	b0dedc49a2daa0f44ddc51fbf686b2ef012fccbf

Particulary the last hunk seems to be causing it:

@@ -585,13 +657,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
                        .memcg = memcg,
                };

-               /*
-                * If kernel memory accounting is disabled, we ignore
-                * SHRINKER_MEMCG_AWARE flag and call all shrinkers
-                * passing NULL for memcg.
-                */
-               if (memcg_kmem_enabled() &&
-                   !!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
+               if (!!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
                        continue;

                if (!(shrinker->flags & SHRINKER_NUMA_AWARE))

Following commit aeed1d325d429ac9699c4bf62d17156d60905519
deletes conditional continue (and so it fixes the problem). But it is creating
similar issue few lines earlier:

@@ -644,7 +642,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
        struct shrinker *shrinker;
        unsigned long freed = 0;

-       if (memcg && !mem_cgroup_is_root(memcg))
+       if (!mem_cgroup_is_root(memcg))
                return shrink_slab_memcg(gfp_mask, nid, memcg, priority);

        if (!down_read_trylock(&shrinker_rwsem))
@@ -657,9 +655,6 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
                        .memcg = memcg,
                };

-               if (!!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
-                       continue;
-
                if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
                        sc.nid = 0;


How was the bisection done:

 - Compile kernel with x86_64_defconfig + CONFIG_MEMCG=y
 - Boot VM with cgroup_disable=memory and filesystem with 500k Inodes and run
   simple script on it:
   - Observe number of active objects of ext4_inode_cache
     --> around 400, but anything under 1000 was accepted by the bisect script

   - Call `find / > /dev/null`
   - Again observe number of active objects of ext4_inode_cache
     --> around 7000, but anything over 6000 was accepted by the script

   - Consume whole memory by simple program `while(1){ malloc(1); }` until it
     gets killed by oom-killer.
   - Again observe number of active objects of ext4_inode_cache
     --> around 7000, script threshold: >= 6000 --> bug is there
     --> around 100, script threshold <= 1000 --> bug not present

Real-world appearance:

We encountered this issue after upgrading kernel from 4.9 to 4.19 on our backup
server. (Debian Stretch userspace, upgrade to Debian Buster distribution kernel
or custom build 4.19.60.) The server has around 12 M of used inodes and only
4 GB of RAM. Whenever we run the backup, memory gets quickly consumed by kernel
SLABs (mainly ext4_inode_cache). Userspace starts receiving a lot of hits by
oom-killer after that so the server is completly unusable until reboot.

We just removed the cgroup_disable=memory parameter on our server. Memory
footprint of memcg is significantly smaller then it used to be in the time we
started using this parameter. But i still think that mentioned behaviour is a
bug and should be fixed.

By the way, it seems like the raspberrypi kernel was fighting this issue as well:
	https://github.com/raspberrypi/linux/issues/2829
If I'm reading correctly: they disabled memcg via commandline due to some
memory leaks. Month later: they hit this issue and reenabled memcg.


Thanks,
Jan

