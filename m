Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_2 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B933AC4740A
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 20:56:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 774B62086D
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 20:56:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="rwBgReSr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 774B62086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1100C6B0003; Mon,  9 Sep 2019 16:56:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09A066B0006; Mon,  9 Sep 2019 16:56:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA3366B0007; Mon,  9 Sep 2019 16:56:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0044.hostedemail.com [216.40.44.44])
	by kanga.kvack.org (Postfix) with ESMTP id C66DB6B0003
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 16:56:37 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 3C3BE2DFD
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 20:56:37 +0000 (UTC)
X-FDA: 75916590834.17.pear30_56db818ff7d39
X-HE-Tag: pear30_56db818ff7d39
X-Filterd-Recvd-Size: 3608
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 20:56:36 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id j1so5258367qth.1
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 13:56:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=RXlau3Rrd1QkzYBs3/YzKpwSMvNufW/Fkto7D7l+o0I=;
        b=rwBgReSrqYoPp35fhsZ5W9cim4ISWGxbkkoCszbfB4IlFRT+o30kbtOHn5oAoJiyji
         Albhw/75KgNKa0mIsgpDIEir50zWsdOZdcSWV8yNfIRSBZilunq9HslJW96YLNjPOLHP
         v9qjT7n9yOQhEfL3P0U+anJ/KmLf+Jqp9l7I3OnYo3M37hOMdGj0o+YrxTtWhDy3eOBd
         DxLz9ltYiKVR/HWVpkkrAx4oNMWLUFwpEisY2R3OoU1hMTKG4jY6G4BGSU5q78de7KvA
         1oSusp3jDGaD2/xIDUZ8MgPPT9PBLB8sZKbfxB212liiU99FgAfCzMkOqy+62k+AkdB6
         0d7Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=RXlau3Rrd1QkzYBs3/YzKpwSMvNufW/Fkto7D7l+o0I=;
        b=EZNyQ2t09pgqHyuuHQda/MsD1CA8N+IiH7zh/wCNSHl8tkiQbIOGrPnedEuh5L8Fzl
         26HrsT8YZoy25T8HNpJc/XppMdRR7u7e0EiNvPaqWwmJSf/P83Z6COL5SkO9Nuh3h1IE
         6CegkMpYnolIbl0GtV4RfF4fux+0flHy2oG89XVHbeErOFbHnsvrKHXmfUhwo5lXEFzK
         TyK+mPdliY2pcl1ei6Lv7RYBcw6VbprIo6qlbw0vXa4GVbGuGq+cLKHmX+5ZjgQzfKmb
         /2TMEuC7Iq7+C/vFrYcjXxR2thbmtWtqDai8/VsB58M2DLroBnWLg8hBO1OkfFMF2L6t
         NDrw==
X-Gm-Message-State: APjAAAUH0iltpB5TxbjZ5eS0IfcZ4OZvZOZjJjLJTG0LQhj9hNDEvtTc
	vLA6y+nqmanfLzEme3GqrM1NR6Xgwec=
X-Google-Smtp-Source: APXvYqyOyA7lqoPpSDF6vbDU0D9w20PHHhNS/8uexb4YjdRCkfhPoE3JGtEXJjZ8+qQhlYIdEpvlCg==
X-Received: by 2002:ac8:2ae9:: with SMTP id c38mr25488158qta.311.1568062596086;
        Mon, 09 Sep 2019 13:56:36 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id t73sm7140006qke.113.2019.09.09.13.56.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Sep 2019 13:56:35 -0700 (PDT)
Message-ID: <1568062593.5576.123.camel@lca.pw>
Subject: Re: git.cmpxchg.org/linux-mmots.git repository corruption?
From: Qian Cai <cai@lca.pw>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton
	 <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org
Date: Mon, 09 Sep 2019 16:56:33 -0400
In-Reply-To: <1568037544.5576.119.camel@lca.pw>
References: <1568037544.5576.119.camel@lca.pw>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.003521, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-09-09 at 09:59 -0400, Qian Cai wrote:
> Tried a few times without luck. Anyone else has the same issue?
> 
> # git clone git://git.cmpxchg.org/linux-mmots.git
> Cloning into 'linux-mmots'...
> remote: Enumerating objects: 7838808, done.
> remote: Counting objects: 100% (7838808/7838808), done.
> remote: Compressing objects: 100% (1065702/1065702), done.
> remote: aborting due to possible repository corruption on the remote side.
> fatal: early EOF
> fatal: index-pack failed

It seems that it is just the remote server is too slow. Does anyone consider
moving it to a more popular place like git.kernel.org or github etc?

