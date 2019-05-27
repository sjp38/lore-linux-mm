Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEE7AC07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 09:38:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6ECA521743
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 09:38:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MmnXcabM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6ECA521743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF4FC6B000C; Mon, 27 May 2019 05:38:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7DF56B0266; Mon, 27 May 2019 05:38:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD0246B026B; Mon, 27 May 2019 05:38:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6534A6B000C
	for <linux-mm@kvack.org>; Mon, 27 May 2019 05:38:53 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id r8so2772579ljg.6
        for <linux-mm@kvack.org>; Mon, 27 May 2019 02:38:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=KJULdVfLsRoB+sGyptDGkaVMQxwt1Boacmd0PqpEDts=;
        b=e235I+/QmLpJCjUIM76YelvXquopykeYvKQk4bUpaKYFRKversbg53MZv8SEhwCrGi
         Q54Zr9wXZBBfqH6W65rdCAWpJN4bSU2eJWs4gtsCu9StLg/Pr//BGM2Id1jdDbs9WGMD
         JayBnUSTV8OdmY2AHoPTfNks45ETLqYDIu41ofcEk2cKMNBBSFJ8ZltieWg7gArukwwL
         ng03WJwRl1cxS/W6+pDB5yvBwh4fzIT83jPCNLwJQBKt11JvFLpOXKE66pemaffhvNhn
         8ymnGQufclEmBxQFmUvV7nUJyrKCE4ZYAUYJIM1IeO2Yia1xNvOSWrCYJpqeKqqhdUTw
         uFGw==
X-Gm-Message-State: APjAAAW4F9DUT1oBxBZCJbT/vFSZtfk1anetPbo6do1HzLaXJa/w7Uu2
	HK15rgSMtBIinz+L5VrGpL602eWtIjuEzPfBTO/f2tpXciXOWIAEr0IUfwhJH7GScR2TVpWHi4g
	277qv+ZtQBxRJlqihTAry3XSyPkFP41Re3B2+SdsSLKFhKAl1xnmReM6oPrN13WzJtg==
X-Received: by 2002:a2e:5dcb:: with SMTP id v72mr61164593lje.54.1558949932475;
        Mon, 27 May 2019 02:38:52 -0700 (PDT)
X-Received: by 2002:a2e:5dcb:: with SMTP id v72mr61164568lje.54.1558949931696;
        Mon, 27 May 2019 02:38:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558949931; cv=none;
        d=google.com; s=arc-20160816;
        b=SEOfY9YR2Kg3iWNOwrDjUWRBNwa9IJcUlje3JQvW6+MaUqSFRv/GOY3pnohj8iqdtw
         ziuTC3VjWlSN+qcurRBwOoP3HtpmBxYdScta5+9dtv9AMnaLg0HenvTrPo8YtWdZir3S
         ZQeuoiZ9WwmNhs3M/4EjcXiwFJeJfiqTxLiq9E+naiMZMtgDmJs8u5ZBcwv7nQbGQTFc
         uMiWJ+Q+L0GCFlF9wYe21iUPUK/HgGoBGy1NCrWdm/hSx9kqajFB60BaNHY2aNgLvKCK
         1npBDcB8WezopfPqq+Yal6EYJduCmKjgdHh/CvtepLtVLOgvPYifOYwtTclqFHi4UpB9
         HRjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=KJULdVfLsRoB+sGyptDGkaVMQxwt1Boacmd0PqpEDts=;
        b=ksjEqJfMLpkp6AGGJa6glv2ISoHLk/qyWEMJooZ1nrzg+HZuHPXLs7NJMlb1h8fEnU
         tezlpFhZNVGvIaC5vlNXWx8t9WPeJHAZkUYRK0d+eDS1CsnpH4rrOPyBYYq3yUX6CEDo
         dOeZZOX24LFeDRLkvzvQ8PTkOBAofgI+JKgEm53uaxzloYiP6fpqNnsHMhuUSZkuShHd
         NsHFK/taBiqN4FRh64JQXpAMegjULGuw2niQ8vCIjeMkoOutmVHLaL+rbwgt4urQaNjP
         sryLze3AydYoPyhxjpZ4mzRFVbwZyEhG0Eqzt76TbBp3y95XJG9bZb6ZSWXebMqNkKxj
         C/qw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=MmnXcabM;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c19sor4885526ljk.34.2019.05.27.02.38.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 02:38:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=MmnXcabM;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=KJULdVfLsRoB+sGyptDGkaVMQxwt1Boacmd0PqpEDts=;
        b=MmnXcabMcBI+WEeJsRnfddqU+lstsU0ktKmJQSl7uzI8EtRq8qnyMA1cBgVBf32wcl
         Qf9naQEpc4VuIe9mIUYjZTAYExdOX+zopaT++YhS0Ah4GF/kzgFipzmfNcc72WyW0nU8
         9Ga3FDXngULiryXfN25QYjlUTI0Jg6KvDbl9WOhLzPtVw1d9KlKbjmBzwtppe6rpto3S
         CFWkdSmCO+oGvxbextYTgFnBuzzm+pV9u1qKr5cnN59/J3EO+LwtbbT84F903cE1Ise2
         4F66WtEzW9yL+mTT9IeSpAWeRAPUhoF88aRpMSrakmjlm6LHilud+/g/RB/GfPLBU+06
         Zyww==
X-Google-Smtp-Source: APXvYqzzWrckWdhlUjfKT+Mr6KWs7IdSOmIQyO0BsfKDrAL58MmE+qhRLg1+HDh+WeyceMc9FuBwfA==
X-Received: by 2002:a2e:8716:: with SMTP id m22mr8686777lji.128.1558949931317;
        Mon, 27 May 2019 02:38:51 -0700 (PDT)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id z26sm2176293lfg.31.2019.05.27.02.38.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 02:38:50 -0700 (PDT)
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
Subject: [PATCH v3 0/4] Some cleanups for the KVA/vmalloc
Date: Mon, 27 May 2019 11:38:38 +0200
Message-Id: <20190527093842.10701-1-urezki@gmail.com>
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

Patch [4] moves BUG_ON()/RB_EMPTY_NODE() checks under "unlink" logic.
After [3] merging path "unlink" only linked nodes. Therefore we can say
that removing detached object is a bug in all cases.

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
  mm/vmap: move BUG_ON() check to the unlink_va()

 mm/vmalloc.c | 115 +++++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 89 insertions(+), 26 deletions(-)

-- 
2.11.0

