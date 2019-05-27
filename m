Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 655EDC04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 15:18:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29F432184C
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 15:18:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VQ9NJi36"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29F432184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5E426B027E; Mon, 27 May 2019 11:18:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE64F6B0280; Mon, 27 May 2019 11:18:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 960D96B0281; Mon, 27 May 2019 11:18:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 30DAA6B027E
	for <linux-mm@kvack.org>; Mon, 27 May 2019 11:18:57 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id p7so2189688lfc.5
        for <linux-mm@kvack.org>; Mon, 27 May 2019 08:18:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=YAM42W4nl7Xrv+602WPlcincJeD4Ntz7L8w8jwaNl0c=;
        b=ToebFb80ebdCi1kycAKDtmvpyhRWMqxwUR0yz+MbFk94ur+WXJ6c+hWw9sjn/D7kS8
         1/VgXVJZTEFURcGa0UoxIPiWfArCqsBjTE8F4Vy64uxJnXC7FlrcT3p9ARU1IPmlSTGY
         zaOAPc/PhOUFJckYdzKpWPjYCQyoxC5zSZYMRVb+lKa2nmwCupjpUimcuL77RJADcka0
         3dDWACExbLIXFPk8vp3oTMwGnroqR8+/I8EKQZjy0+b4lE4tBtDfZvqMo5O/voALjCq8
         EmiNID7whrgGybEHDMEo1OX/KVHItdYMrmHGLO5zYRr35sAlEnp28Mcoefqmb3Hvd/eD
         tdxw==
X-Gm-Message-State: APjAAAUiYdvjaeEFdz45QvEYw75jyL/gn7CwPCafFgxmiEBF7dHmeqty
	HJWg40k4c5mqAP2aOCxkRv4wHSSDkMnjpN98KNxRL53wlrapm5NSxDktUyaW9W9JpoYjMa+njh5
	6HnzfqjTZ/x1Sf4Gjg7Pmvb3pWfwjLOhroi5mLZDu8bvOY8jGwd4clN+h921bKMCqJQ==
X-Received: by 2002:ac2:51d1:: with SMTP id u17mr18328221lfm.151.1558970336452;
        Mon, 27 May 2019 08:18:56 -0700 (PDT)
X-Received: by 2002:ac2:51d1:: with SMTP id u17mr18328178lfm.151.1558970335489;
        Mon, 27 May 2019 08:18:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558970335; cv=none;
        d=google.com; s=arc-20160816;
        b=QP7HBH84oio0IByH/6dxgfGIJi6wjV04XJfUlNoog4Yueo6KF9XZxlNBafbeAs7pFx
         X36yEsIOnSE7vx7DYK2jsegiKviAD+g1OeQc8f4dq0PCc2Zst7TtlzTv0Zzzvyd1wqSC
         FOyoRQN9qE+9BQMmM2sl9QxTf+j/VhoHjVS4qIq9dm66YyYekFN6do0nRUMpdJli58Qr
         LhbsKCSMJPOptWuxy1fIRZffNuHtDpkCiGNUqP9BOUk1g3nv+8N1LYRYQfgs9RKUxjVU
         cGYTjXqz4hvpbRUUBZFG2M2mRHbmI/UeR4EYyd7meIDaTfulwxkt7bVxruPfvNjXpnn1
         NAYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=YAM42W4nl7Xrv+602WPlcincJeD4Ntz7L8w8jwaNl0c=;
        b=fmZNXU+WUeSZuppvHQdc7jVS3y6ZJEfq/yPaYASCD7kI4GICsxAt6V3YnoE04pAcA4
         0BKskL3szCalvL8co5VCEoq/8FQHTyeSv/GUL45XxeQFEU777A0YC6Kw020Fh2q216L/
         53311TWLhZXXcihxde1IMuiinptdRn1E5sx9diz+Skmrn7zunHnrqC4iBPvTChr3NBnQ
         O38/bTvnWs3M1XRclnUs4kFY8vpqAqdj78ccWrzprWt2RRAZICN1awtWaXaIat0BWifW
         ElavzNbGMChq1WV76PhoWBfpYS20Y0R4dh7ie94pVKTDokdihJyCZiTeqEYJjonGUTH4
         hNVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VQ9NJi36;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x90sor5477287ljb.40.2019.05.27.08.18.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 08:18:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VQ9NJi36;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=YAM42W4nl7Xrv+602WPlcincJeD4Ntz7L8w8jwaNl0c=;
        b=VQ9NJi36DfshM8MP2kweAEWk741ksZscNvFPiZjFXx0nT5AzXSauCHBeE0WJIHgqaY
         BNuAc5tc16R7hJ8HLN0whUtkUwKZT8HJGgCOVYWqETue3iojBVgK9UAwSHruHYFle6jB
         RSc/Tvq/UUeUGiVXcnCD+PzUIieXGblDvftvXPWX/EXXL60GcbWW2rNmn8f2oMRaiDOW
         Gp+MkJ9OGWciJdLAfmyrYnX4eyONJDiXr82BC6/mw7zqnYx4MLp6+PEG+2q/FQzOYIJN
         7Ho0DJ+8cCi1/d3JVay4+3lmb26TdDwWfwoU97yfGaLO5UbWOeCvZaKIizyBUQjqiIUh
         Wcjg==
X-Google-Smtp-Source: APXvYqxD62DsXuniXEJslrnzdRm4D6x1+aa+aiF4J04y4ulWJ0Sk7kXPdjqDoq4c18XrEgykDRxvoQ==
X-Received: by 2002:a2e:81d9:: with SMTP id s25mr22145532ljg.139.1558970334984;
        Mon, 27 May 2019 08:18:54 -0700 (PDT)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id h25sm2308701ljb.80.2019.05.27.08.18.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 08:18:54 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Hillf Danton <hdanton@sina.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: [PATCH v4 0/4] Some cleanups for the KVA/vmalloc
Date: Mon, 27 May 2019 17:18:39 +0200
Message-Id: <20190527151843.27416-1-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Patch [1] removes an unused argument "node" from the __alloc_vmap_area()
function and that is it.

Patch [2] is not driven by any particular workload that fails or so,
it is just better approach to handle one specific split case.

Patch [3] some cleanups in merging path. Basically on a first step
the mergeable node is detached and there is no reason to "unlink" it.
The same concerns the second step unless it has been merged on first
one.

Patch [4] replaces BUG_ON() by WARN_ON() and moves it under "unlink" logic.
After [3] merging path "unlink" only linked nodes. Therefore we can say
that removing detached object is a bug in all cases.

v3->v4:
    - Replace BUG_ON by WARN_ON() in [4];
    - Update the commit message of the [4].

v2->v3:
    - remove the odd comment from the [3];

v1->v2:
    - update the commit message. [2] patch;
    - fix typos in comments. [2] patch;
    - do the "preload" for NUMA awareness. [2] patch;

Uladzislau Rezki (Sony) (4):
  mm/vmap: remove "node" argument
  mm/vmap: preload a CPU with one object for split purpose
  mm/vmap: get rid of one single unlink_va() when merge
  mm/vmap: switch to WARN_ON() and move it under unlink_va()

 mm/vmalloc.c | 99 +++++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 81 insertions(+), 18 deletions(-)

-- 
2.11.0

