Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCA51C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:35:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1D9C20869
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:35:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="bzuk+pZX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1D9C20869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43B908E0003; Wed, 30 Jan 2019 13:35:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C2FA8E0001; Wed, 30 Jan 2019 13:35:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23E648E0003; Wed, 30 Jan 2019 13:35:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id A582C8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:35:30 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id y24so86360lfh.4
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:35:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=zCIG9VzWuYh+4Bf06Auxq3qGZen7OwOELA8vsXd/35o=;
        b=hDw3g7IymGDKKmMkY0VZuK6I0si5XgBhANZ5c/QZLm2mZtogQUAvHC3gMiu5KaCBzt
         9NazF1WWYzAVP8NNTSUH2Jt8rQ7ZNWPIkrxHs67R3VM87Jx/hoS+VcTa4/GVKG/zMs/q
         yvX//36Ob3Dg+vTGiys00wsR4rZTBiBl0yZhR6o/VIaQ+P8JQXszfuANa8c9Llw9rMe6
         VhwSU3clDF0xO0cgyEfb/62F6eeY1mUCIOn8gRqhDR9sOF3mfzRhPd2Ckcs6H0mufWTj
         0oXE+BdDApKOCcWVNvEZoyjjbxbjWS9BAMS+Ep4OU9bEzjNV1PV0dxt9xMjpbesDPZAw
         1NZA==
X-Gm-Message-State: AJcUukfZ8qZ2J6sCgQfOzarOh2nsQFMGegZZ8M2mYcp1tGQ19icuVZv5
	wsJMxzYkLsNfd33HINQOBWOunTmBINFQ9SQXgsGEqsuSkWIperc84KqbMuwgA3RIj/2oeJOFShr
	XhTc8C6jm8rmAXPTRjFN8e823IStQGa8+7RjbTygNOwXnj4nE03VqH6c5e5oXRgiSNDWeMD1agl
	2TJCTk87ttaIVu4SASCCnoGOSUFTWepp9eGkbTs6h04Nw84y2H8IbDs2tdaUefSInF6yGQ+fcuZ
	0JYYYiE+GQGMP97pQNP5s/GIZD4nBo810vLj/07p/7colWxEdqN33U4SG8ILH5jDfZ1ii07NrEA
	3XjEtGv0GBO7QOGsoQB3ORqPOrctNR/g4Tf6vHpCQSMsCMDAlw9RkZivh+qZlUUf7CNQvO8M3AS
	r
X-Received: by 2002:a19:c4cc:: with SMTP id u195mr25922300lff.141.1548873329694;
        Wed, 30 Jan 2019 10:35:29 -0800 (PST)
X-Received: by 2002:a19:c4cc:: with SMTP id u195mr25922246lff.141.1548873328754;
        Wed, 30 Jan 2019 10:35:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548873328; cv=none;
        d=google.com; s=arc-20160816;
        b=unyayeHhLEMCZwylnsXLwJZEm/DjB7b76i7/u+vYRwymxQks1PVOFj5p3vX7nMxIs5
         NycYuTU/VlCS77UuK2IsvXHuzz7Xww1ZYdqkWUyWx3euD1wegkH+a5Ptm16tT+TlpsLO
         4RwLW0+7HANYSX7TNEM+M9xlxHa17FCc5CDP0XnKRDfckRop6d86K+Y3GL/WBmVzA4qv
         3KMy1VZ/8SIVPv01C0WlYzh6pfT8fqc1p/O8cgq4HNqipuD8CXIU2+YtRMw8u71zVE6B
         9W+u/xWcethG9/wKhizGNLOAojMMLY5MdRSiHR5dtBbXw/vR3m1pLn6B/xnvkbm13l9r
         UHhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=zCIG9VzWuYh+4Bf06Auxq3qGZen7OwOELA8vsXd/35o=;
        b=U2MnWevmtbunD05Jng2YeFZHknBjghuUbarhnAhwna2NmUJ3aDmWgHet1xg0EoxRLK
         vBIySGAEdiSmVxINFyJQ7XQd1GAsc5n6GXYNSgAJTJ/8bfmg+3ZXzmcHj3aSZYMqk1tp
         VAwqCfrpgS1xUbZhhAEL2VSB04Pc6LpPUTksjTmwfMpgpzdbRPqr89NGq6jgD/AU7FcD
         TB1LzWXhmW7OIMAvnCUjHVMBOP/X2xgKystyXWwUJ27BRT1YvNvWI03A6xjS9iDOUqf2
         XdDivLJoS27eLJQiDMQ1O987RHAoS8Cw7um9wr+Tz3tvt9AwHp6VFe5DXgWt9fA4Jq62
         hEdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=bzuk+pZX;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h14sor754941lfc.14.2019.01.30.10.35.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 10:35:28 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=bzuk+pZX;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=zCIG9VzWuYh+4Bf06Auxq3qGZen7OwOELA8vsXd/35o=;
        b=bzuk+pZXi21YAEqDDpBSJtx9ETbV3TvSPPgDua49V5H1nPuLiSNyTMzEwu9o6wqcBT
         2Af5cWanIGXkR2qaTuvjKsVwQa8DDgjqvGHCq1zl/tUs9v05MjF+k1Imnz+LGUQDOypo
         sXJI6OZvqz5CzhCSD/SmkcWXJQcZcH2BuZqVM=
X-Google-Smtp-Source: ALg8bN5IhDonX+qPvMNa5GMrySbozfcwSsIaZCL73664l9mV3YfFImaZ0x3rgqKYgiDqd33wWJNU0A==
X-Received: by 2002:a19:24c6:: with SMTP id k189mr24750792lfk.77.1548873327044;
        Wed, 30 Jan 2019 10:35:27 -0800 (PST)
Received: from mail-lj1-f176.google.com (mail-lj1-f176.google.com. [209.85.208.176])
        by smtp.gmail.com with ESMTPSA id a18-v6sm395612ljk.86.2019.01.30.10.35.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 10:35:25 -0800 (PST)
Received: by mail-lj1-f176.google.com with SMTP id x85-v6so488881ljb.2
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:35:24 -0800 (PST)
X-Received: by 2002:a2e:3509:: with SMTP id z9-v6mr26573226ljz.54.1548873324599;
 Wed, 30 Jan 2019 10:35:24 -0800 (PST)
MIME-Version: 1.0
References: <1544824384-17668-1-git-send-email-longman@redhat.com>
 <CAHk-=wi-V7LjAAzFuxg+eLQAdp+Ay4WmVJdTNxgPjqKXaj-3Xw@mail.gmail.com>
 <0433488a-c8ad-e31a-6144-648e45478c07@redhat.com> <260e6cdb-42b7-1891-e525-54048d168b5c@redhat.com>
In-Reply-To: <260e6cdb-42b7-1891-e525-54048d168b5c@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 30 Jan 2019 10:35:08 -0800
X-Gmail-Original-Message-ID: <CAHk-=wi1raFRkRH1HEe_awy7HVy7XWxFRv9aZY-cgNL5zMqW4A@mail.gmail.com>
Message-ID: <CAHk-=wi1raFRkRH1HEe_awy7HVy7XWxFRv9aZY-cgNL5zMqW4A@mail.gmail.com>
Subject: Re: [RESEND PATCH v4 0/3] fs/dcache: Track # of negative dentries
To: Waiman Long <longman@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, 
	Jonathan Corbet <corbet@lwn.net>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-doc@vger.kernel.org, mcgrof@kernel.org, 
	Kees Cook <keescook@chromium.org>, Jan Kara <jack@suse.cz>, 
	Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, 
	Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, lwoodman@redhat.com, 
	James Bottomley <James.Bottomley@hansenpartnership.com>, wangkai86@huawei.com, 
	Michal Hocko <mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 8:40 AM Waiman Long <longman@redhat.com> wrote:
>
> Ping. Will this patch be picked up?

Can you re-send the patch-set and I'll just apply it directly since it
seems to be languishing otherwise.

                Linus

