Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF416C282E3
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 04:15:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CAE32075B
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 04:15:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CAE32075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0456C6B0272; Wed, 29 May 2019 00:15:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEA246B0273; Wed, 29 May 2019 00:15:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8A946B0275; Wed, 29 May 2019 00:15:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9AF416B0272
	for <linux-mm@kvack.org>; Wed, 29 May 2019 00:15:06 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id r4so898606pfh.16
        for <linux-mm@kvack.org>; Tue, 28 May 2019 21:15:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version:list-id
         :archived-at:list-archive:list-post:content-transfer-encoding;
        bh=r5/OjtXFuUE+uWCMge6H1dbZg9/1vgpsiaMnC8Ch1NQ=;
        b=mmQO3+PvwyBCSDGxmYEZHyzvCTWsfLI4kp3pHZxfubY8GXBDerPf1Z1sgJs9qCcoeT
         3nO5hNQs56pdLQMeSrgDlTp8UG+bt2BcYmvIgQdZ/rlrFHBgvadHc1ml/kSS/MLxcVvS
         sgF/a1y8Yr99RrpNAvDF2QKozsAVV8mnmjtbHnRqJmvPh/Khagw7wPF1taKV9Hrm1iCH
         UEFuJETow+3iczZCIaojyA6gB5i4N1wvBcL08e+jk/bqejAhUffn/y1yx/S9L773HmPv
         cGZIXRAj6KQLyFDjcK8x4Ga4psdK2yDIeFRILibuWen/qcJFHiE8b4FOTxLiiMOHdazz
         yIOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAVnZLI0mig4muzPpJ++Z5OLGYMFVrz/7PINgPw5qa7Mbq5Oix6c
	Kt+Ih4zlbzdm17k88mvXuGKP+ptTdZbXS59VPEYFSfnHnd+IZhjtK+G0iJl+AtiMaOYzoeqwpjA
	rJMlM+YfgbMiyVhhvhx7QutuzZfvbwuLC3DXP3JVV1i9ZLw89Sz1VvN48VWBVIxvaqQ==
X-Received: by 2002:a65:6543:: with SMTP id a3mr107669718pgw.300.1559103306164;
        Tue, 28 May 2019 21:15:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybiCnDs5fyZtwA4OjRhM4+Gd4LW3IAIosuCN526ckdDWGUr9zoDg1yA+UzgBfvqG/EDXSU
X-Received: by 2002:a65:6543:: with SMTP id a3mr107669677pgw.300.1559103305502;
        Tue, 28 May 2019 21:15:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559103305; cv=none;
        d=google.com; s=arc-20160816;
        b=KbLTXKNPmUq0mTwJbkDYBqyhzurtd4yvFvy8c4ll4+RoHwc35BGafvIZmPB18C0n7K
         rrOgd7i6iuJ+DNqlyB6WOL3LAWyLn2ymQJW7WMLdO5UW7M2e2V3vSelPfkY0nu96lw2A
         KHj2BtnaWGpvqAgqIVji2aETBAPA6JtT7JwBWvZlj9+d9SpGKpLqouPXtGNDcNpM4UI3
         lxqv4a7drcN9KdxepgkzPaMIL79SAIeHO2PfXmr9s+K1z+1Lu6byTwhVYliRO1LBqrKz
         axMzC3e72wZ7HLadjdXxavbzZVoPSSEMKXu0xQvmAdCXrkfOJxc/3ecm3nwHM8XwQhFq
         7sZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:list-post:list-archive:archived-at
         :list-id:mime-version:references:in-reply-to:message-id:date:subject
         :cc:to:from;
        bh=r5/OjtXFuUE+uWCMge6H1dbZg9/1vgpsiaMnC8Ch1NQ=;
        b=oJ8ORMJmSlVwmYq0U0bTCwqI2E8dciVYgjVANqKW0mnY+LQzpdNfxDRwAvwLXXIXl5
         qn/dOthMHBaoQeCyLpQxHM2pBS2QmchLiWluaKb96FDU+Q3I95d5d3Cx7uE8uJVlE4OP
         lciXE0CwQVsxWiQiMTNVhJXkkfOgUr4huQkavE3APmGPh5w+yryvaxLHJEvQiVPl8ALD
         PDcCGcCi2yn6vU4mMck6hMC27q9MA9LqTaktYOkUdPcql6F70VGt/LcSPL29wQZ7YG0L
         zrknUGal77rNimIuI62Nsh2wShF7EhfHAdYkq+2dy7vVV34JRxsVf3s/7JjwDv7gs7xl
         Kzvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-165.sinamail.sina.com.cn (mail3-165.sinamail.sina.com.cn. [202.108.3.165])
        by mx.google.com with SMTP id 204si22894960pga.373.2019.05.28.21.15.04
        for <linux-mm@kvack.org>;
        Tue, 28 May 2019 21:15:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) client-ip=202.108.3.165;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.165 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([123.112.52.157])
	by sina.com with ESMTP
	id 5CEE073F00004B7C; Wed, 29 May 2019 12:15:02 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 564143396047
From: Hillf Danton <hdanton@sina.com>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 6/7] mm: extend process_madvise syscall to support vector arrary
Date: Wed, 29 May 2019 12:14:47 +0800
Message-Id: <20190520035254.57579-7-minchan@kernel.org>
In-Reply-To: <20190520035254.57579-1-minchan@kernel.org>
References: <20190520035254.57579-1-minchan@kernel.org>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
MIME-Version: 1.0
List-ID: <linux-kernel.vger.kernel.org>
X-Mailing-List: linux-kernel@vger.kernel.org
Archived-At: <https://lore.kernel.org/lkml/20190520035254.57579-7-minchan@kernel.org/>
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190529041447.yS-hNnmHaZzavxxZ3nqUepUZaP3KF5kZrSyKZcKdKIQ@z>


On Mon, 20 May 2019 12:52:53 +0900 Minchan Kim wrote:
> Example)
> 
Better if the following stuff is stored somewhere under the
tools/testing directory.

BR
Hillf

> struct pr_madvise_param {
>         int size;
>         const struct iovec *vec;
> };
> 
> int main(int argc, char *argv[])
> {
>         struct pr_madvise_param retp, rangep;
>         struct iovec result_vec[2], range_vec[2];
>         int hints[2];
>         long ret[2];
>         void *addr[2];
> 
>         pid_t pid;
>         char cmd[64] = {0,};
>         addr[0] = mmap(NULL, ALLOC_SIZE, PROT_READ|PROT_WRITE,
>                           MAP_POPULATE|MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
> 
>         if (MAP_FAILED == addr[0])
>                 return 1;
> 
>         addr[1] = mmap(NULL, ALLOC_SIZE, PROT_READ|PROT_WRITE,
>                           MAP_POPULATE|MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
> 
>         if (MAP_FAILED == addr[1])
>                 return 1;
> 
>         hints[0] = MADV_COLD;
> 	range_vec[0].iov_base = addr[0];
>         range_vec[0].iov_len = ALLOC_SIZE;
>         result_vec[0].iov_base = &ret[0];
>         result_vec[0].iov_len = sizeof(long);
> 	retp.vec = result_vec;
>         retp.size = sizeof(struct pr_madvise_param);
> 
>         hints[1] = MADV_COOL;
>         range_vec[1].iov_base = addr[1];
>         range_vec[1].iov_len = ALLOC_SIZE;
>         result_vec[1].iov_base = &ret[1];
>         result_vec[1].iov_len = sizeof(long);
>         rangep.vec = range_vec;
>         rangep.size = sizeof(struct pr_madvise_param);
> 
>         pid = fork();
>         if (!pid) {
>                 sleep(10);
>         } else {
>                 int pidfd = open(cmd,  O_DIRECTORY | O_CLOEXEC);
>                 if (pidfd < 0)
>                         return 1;
> 
>                 /* munmap to make pages private for the child */
>                 munmap(addr[0], ALLOC_SIZE);
>                 munmap(addr[1], ALLOC_SIZE);
>                 system("cat /proc/vmstat | egrep 'pswpout|deactivate'");
>                 if (syscall(__NR_process_madvise, pidfd, 2, behaviors,
> 						&retp, &rangep, 0))
>                         perror("process_madvise fail\n");
>                 system("cat /proc/vmstat | egrep 'pswpout|deactivate'");
>         }
> 
>         return 0;
> }

