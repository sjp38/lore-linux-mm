Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10698C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:52:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF77820883
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:52:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sf4Wv0oO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF77820883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 592736B0006; Tue, 11 Jun 2019 15:52:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 543166B0008; Tue, 11 Jun 2019 15:52:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 431AA6B000A; Tue, 11 Jun 2019 15:52:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0FF816B0006
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 15:52:15 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a21so9757908pgh.11
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 12:52:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=cHQwQdsrkTpqJAyug+FT0E9rG91BoWa0X7Lnvcu63U0=;
        b=TQYBbdBlzUVDBschfDXL3vAJvdflU+zxRS+qmWIfnqkbt2FDtVZADh9HUQY7yYs+N4
         ldBJTvD4BSfPN3GvPCweFjE0QOWDlJq3nlnfJA1nQz/5v0c3Cc2plxbObZ+u69OvJYnf
         aZw/9JcWVW7UXoAmX/MJn0jxdkRu6GgSpDEB7hsststXEeT9oX6q7Tou1QOxttzT+YeJ
         cwPoJGAFLY5h11FBe7KqAuf00FTzoyaLjzn9nRoLI/6DMsC8N4ygWwXDOXz/NGhIFEXr
         t30fmyDInB7xN0/YecgWsPTAzR5HMQEKPXlRpGxYyfeo3aEQvTU3lYcbZ724a1GvNeea
         rD8w==
X-Gm-Message-State: APjAAAX4GdzfDoMGd4k1FZhuAi7YdeoGY5GUvjiFLNw/fAlfZZ0nu47Y
	dlrBVoFHY6KanWiNEgkBo6chAmRn0jDvvqhwPp2mushFcmj3af/wETdRNuu0LinXmtX05mFjKqI
	QZdNNhSRkf93tHaPa8EeyjRjIThKlQWTdAWGJ/4k3D0NSURY8L2xkb5GH/qRiPRM=
X-Received: by 2002:a17:90a:a09:: with SMTP id o9mr16910050pjo.95.1560282734748;
        Tue, 11 Jun 2019 12:52:14 -0700 (PDT)
X-Received: by 2002:a17:90a:a09:: with SMTP id o9mr16910011pjo.95.1560282734125;
        Tue, 11 Jun 2019 12:52:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560282734; cv=none;
        d=google.com; s=arc-20160816;
        b=KCjXibh6TLvQUFvbLIlB1WDJJj/c6/Mp3eqn4K6/KM5tKQZ8EhLhMXYg39MxT6R55F
         bzhZM22W8TBC1eTa53hmd7YuB/Pca0QQw6qoZwN/+uNrgrMRNIhskVwyg8AMe1GZaRvJ
         h3e4WPBPO5FxP07i3HvKaFyZAHV1ILIJm75qdJxp2nuPWxBjgA9hv7JLRUKSY5onUEWx
         NLq1+jdBupMSWBhFkytGuAAkQTEUkPlDMvLT99u+65/IN13sf31SiO5XzUL+cqtWnyg9
         3aA9z/DjJPHw2Z/JJS4aAgSRWSlSdWQWY95+xNCw4scluhspCvlCunKi4J0nCI/Dyayl
         SHCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=cHQwQdsrkTpqJAyug+FT0E9rG91BoWa0X7Lnvcu63U0=;
        b=Usdc1nFggIGABwzWJEfkdpLxUdfOiBG7rzW3jIc7KqJJ+dWv2yM6OgxZ8YRgCR1N7t
         NngRmKcUJhz/lS9rjekh/eYXnbXmCepE+U39q6g4XsquOsDk0M344nfc2mlC9Ch0gPq1
         aokF6sQlz+NzTQDAT03CvLW4Uwej48WFXjhOMr9cjWtKTgSaPHfG7qj7jXfAdxVRvcRL
         CwjkTcII6+72qNidXK68OX7OhxjB/784J6xtArSLiyQraT/cui4zi/efyJz45D4dsGFf
         BMQfmy49rcxNL/9k6y2PZI7BNbkurHSBverIL/J9q/8ob3TpmPXj7Yt5NFX+DGWCwVNK
         Y6ww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sf4Wv0oO;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h3sor2688530plr.54.2019.06.11.12.52.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 12:52:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sf4Wv0oO;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=cHQwQdsrkTpqJAyug+FT0E9rG91BoWa0X7Lnvcu63U0=;
        b=sf4Wv0oOKP6ccpJ9YkQOGUDhSjYMBG+KudnxXTcqLAYPTss2vsI1fbeHmcwPPphcXk
         eATLNIRLct9/VRTkALmNlWMYfZd4ArOl2dDKv2RD398ontULghP25qT50pgbWNv4RPRF
         77gUEK//iTYsdIcrlUK0eU8HjK4D6OkpZM4MQ+WSPhskB0w41UOsJhrx8kG0Sn5KXqpg
         W30qKAytIPB0KJaNA2/a92tHIIvpb7rkfdOzP2u/VtulBlUvKeF5aRsPWlUK4K9CTGn2
         50YrHtyYEwlfXxS0bAkqes8kZlPigVckJQmBPYD/bHVUi4pGGlu4cvhg22lMAOvYaJt0
         lHAw==
X-Google-Smtp-Source: APXvYqwtr7AdbQtXCjzK5M7+YTkrqbJhHbXBQ3iF70ArYweFUb7ISFWWhnZBb2Wk9bDXh3r0GQsgfw==
X-Received: by 2002:a17:902:b592:: with SMTP id a18mr52750895pls.278.1560282733634;
        Tue, 11 Jun 2019 12:52:13 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:1677])
        by smtp.gmail.com with ESMTPSA id d4sm18814972pfc.149.2019.06.11.12.52.12
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 12:52:12 -0700 (PDT)
Date: Tue, 11 Jun 2019 12:52:10 -0700
From: Tejun Heo <tj@kernel.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, hannes@cmpxchg.org,
	jiangshanlai@gmail.com, lizefan@huawei.com, bsd@redhat.com,
	dan.j.williams@intel.com, dave.hansen@intel.com,
	juri.lelli@redhat.com, mhocko@kernel.org, peterz@infradead.org,
	steven.sistare@oracle.com, tglx@linutronix.de,
	tom.hromatka@oracle.com, vdavydov.dev@gmail.com,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [RFC v2 0/5] cgroup-aware unbound workqueues
Message-ID: <20190611195210.GK3341036@devbig004.ftw2.facebook.com>
References: <20190605133650.28545-1-daniel.m.jordan@oracle.com>
 <20190605135319.GK374014@devbig004.ftw2.facebook.com>
 <20190606061525.GD23056@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606061525.GD23056@rapoport-lnx>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Thu, Jun 06, 2019 at 09:15:26AM +0300, Mike Rapoport wrote:
> > Can you please go into more details on the use cases?
> 
> If I remember correctly, the original Bandan's work was about using
> workqueues instead of kthreads in vhost. 

For vhosts, I think it might be better to stick with kthread or
kthread_worker given that they can consume lots of cpu cycles over a
long period of time and we want to keep persistent track of scheduling
states.

Thanks.

-- 
tejun

