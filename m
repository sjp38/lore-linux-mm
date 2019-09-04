Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07333C3A5AA
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 07:00:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF1262339E
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 07:00:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="c0ktxI2d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF1262339E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 426776B0003; Wed,  4 Sep 2019 03:00:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B00F6B000C; Wed,  4 Sep 2019 03:00:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2775D6B000D; Wed,  4 Sep 2019 03:00:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0238.hostedemail.com [216.40.44.238])
	by kanga.kvack.org (Postfix) with ESMTP id 00A9D6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 03:00:48 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 9D8C6B2B3
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 07:00:48 +0000 (UTC)
X-FDA: 75896340576.22.mark10_4134684d4ee28
X-HE-Tag: mark10_4134684d4ee28
X-Filterd-Recvd-Size: 4270
Received: from mail-pg1-f193.google.com (mail-pg1-f193.google.com [209.85.215.193])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 07:00:47 +0000 (UTC)
Received: by mail-pg1-f193.google.com with SMTP id n9so10718659pgc.1
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 00:00:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=0jgAF8J58aWl0sjFxiXtsOlB308+Q67iE1jg4iTF8/A=;
        b=c0ktxI2d6mLipekS0Gyb/pF9PPPM9kTMCdtTBrqZBmBoxhFgDHL83YHdISem/zmndi
         fBr3HDDmvC8mM9PrN+jNEE/b7TQdwSH6nFsLgKiypVevSXBsgFhioq5L0YuMud4RK9pq
         rLzDgafT+CKTGnz2+oMYSHtS7Chx2y3X0aA1JZL8qd7BfgqkpDHTKc6xfogU+w8mxAv+
         ohessldjc/M4d0bn7Bvpz/dEzgLdiH7/QoPXMumNToUidXiX0sVXd9Vcxp7cA+reoZ3g
         v9Egr9JYvBeb7/D3e4X9Qc0yZDXmzMwBo25ujSNXQKfiTjsmYQegHGBR+0qQJpSb1YVX
         PByA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=0jgAF8J58aWl0sjFxiXtsOlB308+Q67iE1jg4iTF8/A=;
        b=ByDJL40AzfG+z4q4W5EMZYRWv0p2N9Isbyyd1JoueWx7oukCs6ZpWw1Yn4L5ziooHP
         4L5bGxUxjOKBe/n8qC1v/b3mnELHCpm+lMHuQOjQfP4dZRFQ3U7oj+ZPzl7NrQtOQtAd
         7U7zERxZqVMuKiggRrePH2A9YlvQlXBwWXzlw8vfvLc48F4Qh1mVh5jcOWv5I3AteVD7
         pRttpNTionM6VkAmKy46FQznnqzTJ/Db7+kN9Xe0Vf9WRj20L/Z7NlkWyJOiiP1RB62+
         TDBFpNkKUm1MFbTa0soencu49C2sun8W4rpDiK2is4yiZP6NsEgdCc8/F83Q2s0tUFks
         zKUA==
X-Gm-Message-State: APjAAAVOGYfHNZRlpLN3pXNmJRT/GqXxZCNBO0nvpZiOmuiMZHyB3aaQ
	ewptx2ooP3m/30lHhXpdqrY=
X-Google-Smtp-Source: APXvYqwzHahC/ZrTpolUl6fKkmnQKYzORYyELnj9JSN1bbSC7s7LQjrvvGR6/yrUpDLjvrNjP3jOyg==
X-Received: by 2002:a62:7790:: with SMTP id s138mr42802476pfc.243.1567580447147;
        Wed, 04 Sep 2019 00:00:47 -0700 (PDT)
Received: from localhost ([175.223.23.37])
        by smtp.gmail.com with ESMTPSA id v20sm18223934pfm.63.2019.09.04.00.00.45
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 04 Sep 2019 00:00:46 -0700 (PDT)
Date: Wed, 4 Sep 2019 16:00:42 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Qian Cai <cai@lca.pw>, Eric Dumazet <eric.dumazet@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Petr Mladek <pmladek@suse.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] net/skbuff: silence warnings under memory pressure
Message-ID: <20190904070042.GA11968@jagdpanzerIV>
References: <1567177025-11016-1-git-send-email-cai@lca.pw>
 <6109dab4-4061-8fee-96ac-320adf94e130@gmail.com>
 <1567178728.5576.32.camel@lca.pw>
 <229ebc3b-1c7e-474f-36f9-0fa603b889fb@gmail.com>
 <20190903132231.GC18939@dhcp22.suse.cz>
 <1567525342.5576.60.camel@lca.pw>
 <20190903185305.GA14028@dhcp22.suse.cz>
 <1567546948.5576.68.camel@lca.pw>
 <20190904061501.GB3838@dhcp22.suse.cz>
 <20190904064144.GA5487@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190904064144.GA5487@jagdpanzerIV>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On (09/04/19 15:41), Sergey Senozhatsky wrote:
> But the thing is different in case of dump_stack() + show_mem() +
> some other output. Because now we ratelimit not a single printk() line,
> but hundreds of them. The ratelimit becomes - 10 * $$$ lines in 5 seconds
> (IOW, now we talk about thousands of lines).

And on devices with slow serial consoles this can be somewhat close to
"no ratelimit". *Suppose* that warn_alloc() adds 700 lines each time.
Within 5 seconds we can call warn_alloc() 10 times, which will add 7000
lines to the logbuf. If printk() can evict only 6000 lines in 5 seconds
then we have a growing number of pending logbuf messages.

	-ss

