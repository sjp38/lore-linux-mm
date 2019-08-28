Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CFDDC3A5A6
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 07:10:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52927217F5
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 07:10:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52927217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03F026B0008; Wed, 28 Aug 2019 03:10:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0A6D6B000C; Wed, 28 Aug 2019 03:10:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E1FE16B000D; Wed, 28 Aug 2019 03:10:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0052.hostedemail.com [216.40.44.52])
	by kanga.kvack.org (Postfix) with ESMTP id BA7866B0008
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 03:10:24 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 732259083
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 07:10:24 +0000 (UTC)
X-FDA: 75870963168.20.sack44_209b63d92be5e
X-HE-Tag: sack44_209b63d92be5e
X-Filterd-Recvd-Size: 2340
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 07:10:23 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5BB25B116;
	Wed, 28 Aug 2019 07:10:22 +0000 (UTC)
Date: Wed, 28 Aug 2019 09:10:21 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yi Wang <wang.yi59@zte.com.cn>
Cc: akpm@linux-foundation.org, penguin-kernel@I-love.SAKURA.ne.jp,
	guro@fb.com, shakeelb@google.com, yuzhoujian@didichuxing.com,
	jglisse@redhat.com, ebiederm@xmission.com, hannes@cmpxchg.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	xue.zhihong@zte.com.cn, up2wing@gmail.com, wang.liang82@zte.com.cn
Subject: Re: [PATCH] mm/oom_kill.c: fox oom_cpuset_eligible() comment
Message-ID: <20190828071021.GD7386@dhcp22.suse.cz>
References: <1566959929-10638-1-git-send-email-wang.yi59@zte.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1566959929-10638-1-git-send-email-wang.yi59@zte.com.cn>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

s@fox@fix@

On Wed 28-08-19 10:38:49, Yi Wang wrote:
> Commit ac311a14c682 ("oom: decouple mems_allowed from oom_unkillable_task")
> changed the function has_intersects_mems_allowed() to
> oom_cpuset_eligible(), but didn't change the comment meanwhile.
> 
> Let's fix this.
> 
> Signed-off-by: Yi Wang <wang.yi59@zte.com.cn>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  mm/oom_kill.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index eda2e2a..65c092e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -73,7 +73,7 @@ static inline bool is_memcg_oom(struct oom_control *oc)
>  /**
>   * oom_cpuset_eligible() - check task eligiblity for kill
>   * @start: task struct of which task to consider
> - * @mask: nodemask passed to page allocator for mempolicy ooms
> + * @oc: pointer to struct oom_control
>   *
>   * Task eligibility is determined by whether or not a candidate task, @tsk,
>   * shares the same mempolicy nodes as current if it is bound by such a policy
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

