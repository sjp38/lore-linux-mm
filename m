Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D633FC31E50
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 16:29:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A227204EC
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 16:29:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="h/sR59wJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A227204EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D79E8E0003; Sun, 16 Jun 2019 12:29:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 387E18E0001; Sun, 16 Jun 2019 12:29:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2772D8E0003; Sun, 16 Jun 2019 12:29:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id B6CA68E0001
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 12:29:44 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id o184so661808lfa.12
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 09:29:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=ROe9l7rmNkgoXM5ZdfPpWNA4ZJ7+sjLyBm3rIg5S9KA=;
        b=Ttw+0oKiQ91BYA3e9sIw+c5Fti44qqVLaGxZk0Q+y4Lx+bDKQGDQpWQksnsMHKUJqV
         mdK7Z7TCQzUR3q5qTQ/grVGteOb3VRrNpU7z2HsUjToLGLVxAVksm441mZyQMh/WPyBp
         LvMBCSvdJx+ft2dVl/uYyEbVtJvpdET1/qd/KoGQxDeR7Ph3PgDSW8u+s4VVoyklESvG
         w1ootZTEf6E4HVDEddvU5jEbJ4CflD0OI5q2H8avDaQ3e5LDwwKaGMQika0Gz5CnQSWY
         TkEsqykGidbhMqJZlnl2G1ARSQdmMhxhvZejnIAQfQwzYVk2GQp9BBd3LXd6bU8vt8Td
         A/yA==
X-Gm-Message-State: APjAAAWZ5O7WTk4rtjMOcUy3TxWKl168lVCrj8zuA8tf48D8PibljXmC
	pZKzVnTT7IHrhPsBr4rmTEEJIyJ4DN82PorsWqHmxVqrkWjrz/u/JKq2/Zp3KrG3TglVZmerhss
	dUwvuEe++Isz0ZTuQIgoUllQd/sRxTiNAZF6NLJ1eOBJl6y+EZKOlBGJQXe52dlSI7Q==
X-Received: by 2002:ac2:5e9b:: with SMTP id b27mr46460593lfq.45.1560702584175;
        Sun, 16 Jun 2019 09:29:44 -0700 (PDT)
X-Received: by 2002:ac2:5e9b:: with SMTP id b27mr46460572lfq.45.1560702583485;
        Sun, 16 Jun 2019 09:29:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560702583; cv=none;
        d=google.com; s=arc-20160816;
        b=V545N++Nq4r/bYqOX3C+jsPW3EblNgWsEUJaq9HvLBOlpks5vLyYDkWU7c5lKi/FuM
         sVOoJe+np9u8eIhGTz4P+CyKThk3Xyyh4tYaSgMzWr3C3cGXWVa///tMJNvioXYQDLTR
         t0DRHK8EmEaxobDyi4fRChN/oFJVd8VkaFbfGdrXppGWkTC1q5/dt838vbhyY/e1xCp9
         7zSTXpuwqVOl2TDGs7F8CI1xw9c5CmAN2ZFIWk9dEBY/SBVc/s/iIOuwsjh5qXh/KqJv
         gS51ysnLebWmea0pyZ6Ri6g3dRil//pTn3D2MmymSDjTwIo3qIPwxzrpWPI8wfJElISZ
         /MSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=ROe9l7rmNkgoXM5ZdfPpWNA4ZJ7+sjLyBm3rIg5S9KA=;
        b=fH58bKfSjxoqChMc4CmKiodtUk9QX2h2mB0Kit5gCNVpbqJaWMOwlrXrfb9loPM8oH
         DNWe2XC8rUMsZz5bw+klzT/QXiuJdx7Y2Xci0jXhA0FgqQ0ZfH9Zfn4cowtmkX/7dWM3
         eOi4FJ3eOHPD8E12LBHagVetKchj1sE30Fj0ruZkhMeYw5YuwgUo0GEEZpTjJf5XUEMX
         nziIXk5w1MSPtP1vP/OZN+Wyv/2C7nMYzi9jcLXNwfTm7TfglhWnp1B6Tea0KN51XAE9
         feWRhAcQMHMAbGlvoangn/GeSaBNAl5pipOeuAt0mqu4PCVn1TAq98rIF8NrDy46p6TT
         V7ug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="h/sR59wJ";
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 9sor4563774ljh.27.2019.06.16.09.29.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 16 Jun 2019 09:29:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="h/sR59wJ";
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=ROe9l7rmNkgoXM5ZdfPpWNA4ZJ7+sjLyBm3rIg5S9KA=;
        b=h/sR59wJK+fRC3mRDJUs7YbyyNEHv8XpFqQto+pIOpDJRMFMGXKdTxTZAireTGxWI7
         FiwYLSr2JON5mEQW2DXWE7T8sKIn1R0ReRXD5pwqAVNuRR8sz89cbggeLHCju6kvpUAD
         1ja4b8jol2zMk/o5ykuyNrTYJOMC4nQs3gM6GOvIuLdZHdSfereMItNivftbGHTijBQP
         0UcvIB9QCMSfYiXgJIMozMimRf/z2poqJKiEzgAm8hX4YL94zxvC5YVcufmTAcrCx7mm
         109jh1L0ci4SmEfT27NtHD5LOcG1rXp2M0z8qHkzSJ1Oy6lmw/MYZAwE2vQpbf4O1+ma
         ziJw==
X-Google-Smtp-Source: APXvYqz3gJlQxLnmSB1YMDld8wbounFH1DdB5g8n3krY1uyci2h9hWjnE9Hq3gAA/X85j5ZNacy3cg==
X-Received: by 2002:a2e:93c5:: with SMTP id p5mr22338427ljh.79.1560702583227;
        Sun, 16 Jun 2019 09:29:43 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id 25sm1660372ljv.40.2019.06.16.09.29.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 16 Jun 2019 09:29:42 -0700 (PDT)
Date: Sun, 16 Jun 2019 19:29:41 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Shakeel Butt <shakeelb@google.com>,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v7 10/10] mm: reparent memcg kmem_caches on cgroup removal
Message-ID: <20190616162941.aqa4ae5j63nmjlp6@esperanza>
References: <20190611231813.3148843-1-guro@fb.com>
 <20190611231813.3148843-11-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190611231813.3148843-11-guro@fb.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 04:18:13PM -0700, Roman Gushchin wrote:
> Let's reparent non-root kmem_caches on memcg offlining. This allows us
> to release the memory cgroup without waiting for the last outstanding
> kernel object (e.g. dentry used by another application).
> 
> Since the parent cgroup is already charged, everything we need to do
> is to splice the list of kmem_caches to the parent's kmem_caches list,
> swap the memcg pointer, drop the css refcounter for each kmem_cache
> and adjust the parent's css refcounter.
> 
> Please, note that kmem_cache->memcg_params.memcg isn't a stable
> pointer anymore. It's safe to read it under rcu_read_lock(),
> cgroup_mutex held, or any other way that protects the memory cgroup
> from being released.
> 
> We can race with the slab allocation and deallocation paths. It's not
> a big problem: parent's charge and slab global stats are always
> correct, and we don't care anymore about the child usage and global
> stats. The child cgroup is already offline, so we don't use or show it
> anywhere.
> 
> Local slab stats (NR_SLAB_RECLAIMABLE and NR_SLAB_UNRECLAIMABLE)
> aren't used anywhere except count_shadow_nodes(). But even there it
> won't break anything: after reparenting "nodes" will be 0 on child
> level (because we're already reparenting shrinker lists), and on
> parent level page stats always were 0, and this patch won't change
> anything.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

