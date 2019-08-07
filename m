Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B8C2C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 00:58:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3ACEB208C3
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 00:58:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3ACEB208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE0376B0003; Tue,  6 Aug 2019 20:58:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C3FEC6B0006; Tue,  6 Aug 2019 20:58:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B55E56B0007; Tue,  6 Aug 2019 20:58:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0706B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 20:58:11 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y15so55080263edu.19
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 17:58:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=oPphY2Bcj1ThkmQcDJlPcxdQAKN59jmHHjA71UAnvss=;
        b=dHY98bNKXvZGEiJTilOYq8ltDR6rrdSkqqmvD0c/8LPK5W+5qqZuXWn/eFKiNTKTqd
         YTPCxUe2X5BHYDcAGKpIwON2C+PD9wgP+RTipRCr8SP8We3KfbaKWFBzPUA3PDpJBCx+
         SnKf0uPjISF4RFFvrW3A5eUB4Xwag781+PRwooCy5xe4fneiol9KUsaz3occrtKcuVe8
         sj41JeDng7O1NcBRwpSMDb1c5jFaLvayrMaXrpCyZS3jdVRKN66K3YxEiLzGA1QjcbDJ
         9nxCQZ+8Ud3cK6slsvFzKsF2MkffwGwmAS7SR6Xb6+9fox01vWQimAhqVc8Eaf9OWLd8
         brAg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of wangkefeng.wang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=wangkefeng.wang@huawei.com
X-Gm-Message-State: APjAAAXZ6V4jiQm7uDvILUJh+cCZ7ITkDgF3vOfGcl8ngcvSgSXWiuJs
	gFFc1fm80AzLJMOsVTaZcxjlmZ0SOfIj5mkbPStASsNgH1PSlVvpns/BOpbJTpRTDnrl/QD/e4k
	PA146xBvS8zFHCuBwIpGT5rEuYUtrzMY3NRnxU8WcAXB2BC3GmPRyhBdUvhZeyiKBNg==
X-Received: by 2002:a50:b1db:: with SMTP id n27mr6965269edd.62.1565139490968;
        Tue, 06 Aug 2019 17:58:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxv1t68DKsJoogrbOB+Z4W3D95UNq7PpftozeJH7Nfg6JA0U5XUrCwjjfx9yKB/lzStF5y5
X-Received: by 2002:a50:b1db:: with SMTP id n27mr6965239edd.62.1565139490265;
        Tue, 06 Aug 2019 17:58:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565139490; cv=none;
        d=google.com; s=arc-20160816;
        b=vYcdU4JjJmZh0VyNm2pZaV9ZCFuuCEZNVXnLxJBsYCm0u7BG20hxa2Ea/S8+vNTa0h
         z1SIRZooYtOsg2IH3VW6Mrhnpbh14nJIVwa4TKdizyyiZDHFX1eT4qZwRy8Va3j8mHPS
         jj4qjrM/pmvT3/V71cOHRcsJAWwNj9mqS57R50SY2bz7I8UmP8zm07YMbLxZWrh6jRCA
         l4cVpTfzDxvlGjF/9666vMk480rTtOfkPp35+bL5vSqxVddCnG1YryoYDfCpeXWImFKS
         BACV7h1IxbRLx8B12a2UxH2bA9J79KT7cUtMwcFLe4vDDhrhgZa+SKfLwKlyMIyIVhD4
         CTlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=oPphY2Bcj1ThkmQcDJlPcxdQAKN59jmHHjA71UAnvss=;
        b=FH//RgFEO84Xj+EwC37M8Zsgl/CE8PvB7b+iZtfmHujH6IS1r8skkx+v9tMqimMMqO
         z31V6pRmE2S4TdzjrMH7aOvVf3eO6gi7GSKwnM+Qu3GMr1hHQn/Ivli0BGs7Z9FJgZvD
         bUcQqLGCOZ9n9x/B1rZwJafdggs78LGpfGctZeH7Nu7MqNyTqbxDy4uHq2wPYZOziFyw
         e3mzX76ujePKKRrYYAS+Zra220W6KbdQI3jRrtqUHqE9qul7+KcQsnOBAGzRSnlf2s9L
         cVbPWic/AnnOtwJDDjXLPnSU3Nbl56WdM+ImAOHw/YBVzEBwoRMDehT3aDsss/EH15aa
         smLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of wangkefeng.wang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=wangkefeng.wang@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id oq27si27913893ejb.277.2019.08.06.17.58.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 17:58:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of wangkefeng.wang@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of wangkefeng.wang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=wangkefeng.wang@huawei.com
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 91ABC144364FA1DEF3CB;
	Wed,  7 Aug 2019 08:58:07 +0800 (CST)
Received: from [127.0.0.1] (10.133.217.137) by DGGEMS410-HUB.china.huawei.com
 (10.3.19.210) with Microsoft SMTP Server id 14.3.439.0; Wed, 7 Aug 2019
 08:58:03 +0800
Subject: Re: [PATCH] mm/mempolicy.c: Remove unnecessary nodemask check in
 kernel_migrate_pages()
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton
	<akpm@linux-foundation.org>, <linux-kernel@vger.kernel.org>
CC: Andrea Arcangeli <aarcange@redhat.com>, Dan Williams
	<dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, Oscar Salvador
	<osalvador@suse.de>, <linux-mm@kvack.org>, Linux API
	<linux-api@vger.kernel.org>, "linux-man@vger.kernel.org"
	<linux-man@vger.kernel.org>
References: <20190806023634.55356-1-wangkefeng.wang@huawei.com>
 <80f8da83-f425-1aab-f47e-8da41ec6dcbf@suse.cz>
From: Kefeng Wang <wangkefeng.wang@huawei.com>
Message-ID: <34880869-49a1-86c6-9345-2a01da7fbb9b@huawei.com>
Date: Wed, 7 Aug 2019 08:58:03 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <80f8da83-f425-1aab-f47e-8da41ec6dcbf@suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.133.217.137]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/8/6 16:36, Vlastimil Babka wrote:
> On 8/6/19 4:36 AM, Kefeng Wang wrote:
[...]
>>
>> [QUESTION]
>>
>> SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
>>                 const unsigned long __user *, old_nodes,
>>                 const unsigned long __user *, new_nodes)
>> {
>>         return kernel_migrate_pages(pid, maxnode, old_nodes, new_nodes);
>> }
>>
>> The migrate_pages() takes pid argument, witch is the ID of the process
>> whose pages are to be moved. should the cpuset_mems_allowed(current) be
>> cpuset_mems_allowed(task)?
> 
> The check for cpuset_mems_allowed(task) is just above the code you change, so
> the new nodes have to be subset of the target task's cpuset.
> But they also have to be allowed by the calling task's cpuset. In manpage of
> migrate_pages(2), this is hinted by the NOTES "Use get_mempolicy(2) with the
> MPOL_F_MEMS_ALLOWED flag to obtain the set of nodes that are allowed by the
> calling process's cpuset..."
> 
> But perhaps the manpage should be better clarified:
> 
> - the EINVAL case includes "Or, none of the node IDs specified by new_nodes are
> on-line and allowed by the process's current cpuset context, or none of the
> specified nodes contain memory." - this should probably say "calling process" to
> disambiguate
> - the EPERM case should mention that new_nodes have to be subset of the target
> process' cpuset context. The caller should also have CAP_SYS_NICE and
> ptrace_may_access()

Get it, thanks for your detail explanation.

> 


