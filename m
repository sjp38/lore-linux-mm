Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E8EBC76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 12:05:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2A0821849
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 12:05:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OCSDzRUY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2A0821849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91FCB6B0005; Tue, 16 Jul 2019 08:05:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D2426B0006; Tue, 16 Jul 2019 08:05:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E7018E0001; Tue, 16 Jul 2019 08:05:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 204556B0005
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 08:05:32 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id u10so1780182lfl.19
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 05:05:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=Ftt1779R51gta0ONtQpJxcZlohE8KMN91kUXHGSN1G8=;
        b=VjRicaxemwW7SFLDah4OQfxnaOU9g6KWjE+0MjWlXaOOXPY6HVLQ5PTOTbYTPi3K4V
         1RoHnw74Vw9TD7lC4zna7xKg7GagpSiXoUCT73cySWDf/uO1DtUNYp79f1reM8svv3Dv
         4lFOr+vQ2CgftqchDxZSIw8Eor445K9KgttJJLmAn0opcHsAh0k9zwC9azkFkggZZpug
         2L15ApX+/d0PL0YR4p1isvEIdW1bofs7l9zci1Quexe/KXwYxGlk5Bik/ojULkxPXrh5
         h884aOZ5rLAULMyYOxTFcQnqLbKHRWLXyF+ICT6LTqBd7IAHZYr0KgoiryuQqNsBtx3Q
         Q0og==
X-Gm-Message-State: APjAAAXcBJfNYgUxiHuNga2qqZTpis6jXg0DQZxfYisNuyBFJ6eqMc0g
	Ob/6Ku4UaYhYrT4JqfPnoZXNfeqdA6aEm4jZ9YmCIPvCZWiCPbp21ZjbtxqGLLPYPh2+YasxjOf
	GTe4Vjc/Z+UneyBbSECADh53RiLTdOOPM9MgqRez+u+1rvx9VdRWeB4RihzZlHquNWQ==
X-Received: by 2002:a2e:8449:: with SMTP id u9mr17247333ljh.104.1563278731620;
        Tue, 16 Jul 2019 05:05:31 -0700 (PDT)
X-Received: by 2002:a2e:8449:: with SMTP id u9mr17247082ljh.104.1563278726411;
        Tue, 16 Jul 2019 05:05:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563278726; cv=none;
        d=google.com; s=arc-20160816;
        b=yHyv7gstYkPS5FYreCaLrYnnv5ZAkNAIPxpatoxr17qTHiG9y0tGQ73Y/w0ioThwCw
         Ab6p1BXHfvecaZDWv96x41IEtq/KH5DI8FUh1+ePKS0Jv9Fy8EUADrLk9NaQ6J1uaVYw
         iqGTkuEuDgciLsIS5AAIZG5oL6gKO9eOwdoJcExN10WUAC+n5nXhYlWeBTcIHLtxIl2G
         Szngjvid4p/y41g+K4ssUDaq0s59VxYpMEKFW63ezq2G9XzIAUWrAtB6JK20xuqVxACf
         hE7LKud4c525F2jaDwhg1MjD55iJsPySCT9x2kevnRuZdQ6JYJSQARVioJygW5+YgErT
         GWZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=Ftt1779R51gta0ONtQpJxcZlohE8KMN91kUXHGSN1G8=;
        b=nTlqWXKxa0fy3XiBtFFy3uS0ulV3++YJkJC2wRuQKCUhXfJBrl+cCvLBuAgRjB8s1O
         u54T8eCZ6MSRb6Z8Z55HnLfHmNCKx/siWK+k09+pP9/472zvhenz05r+nicmU3c8vCm1
         +51vPEJqsUSfa5nfPbPMURMz20aW2IxHjdc+s8q8NemaQoyPVsApWVnihOCDwqMrN1Vp
         gLYs2f1bqaSzClG9iRdOJ7eJPdb2MfMaJBS2e4IWfbSM8vBYcY092mckol5NHzCYrv43
         Gd41y+JR1WTFl0TG3Ui/nNnnD/p0XMQf166c/orFyr7OrninaYOtEiW06gDhWgQM0Bhw
         vJ0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OCSDzRUY;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y136sor5098292lfa.8.2019.07.16.05.05.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 05:05:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=OCSDzRUY;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=Ftt1779R51gta0ONtQpJxcZlohE8KMN91kUXHGSN1G8=;
        b=OCSDzRUYihs3uGng7Kzdsuxey5RVjgG88OT9erKMhdNE3sOyD4A2P8nnnPSC7Dm1R+
         5fkyGF8HSWIoWXxvgj57ekP/cnqTXWUUFHwgPaAoeRvymD4g9FW+NHks2dO8V5pokzBs
         y4SuwipG3n7rtiZGNd66qz5NHAyFTNEVqyDUYDjphzMWCFmjoQc6GrVWV6Yy3OcCf69V
         ao+48jEl4Y+c87PS377+nI5FyuNwWnUSQRIxdWGTUT1dp81b0E5QAbXHcYIHlQ3h7ftU
         /+U2gNjwb0Y6iJGJrd7lYw6sHI26WBV0qThyk8GIHz87vo8EmXeEk7O/cKxT9+HkGmwW
         MmAQ==
X-Google-Smtp-Source: APXvYqzmBP2Yrflx/y4/1oJ33vbI3SI1S9SGmHyT5/NPrhg5FX/1X78drUf1FNH6z/oAP67epWO3Fg==
X-Received: by 2002:ac2:5231:: with SMTP id i17mr14619779lfl.39.1563278725971;
        Tue, 16 Jul 2019 05:05:25 -0700 (PDT)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id t23sm3686410ljd.98.2019.07.16.05.05.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 05:05:25 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Pengfei Li <lpf.vector@gmail.com>,
	Hillf Danton <hdanton@sina.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH v2 0/1] do not keep unpurged areas in the busy tree
Date: Tue, 16 Jul 2019 14:05:16 +0200
Message-Id: <20190716120517.10305-1-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The aim of this patch is to split "unpurged" objects and allocated
ones, that gives us some boost in performance, because of less number
of objects in the "busy" tree, i.e. insert/lookup/remove operations
become faster, what is obvious. The splitting is possible because
"purge list", "busy tree" and "free tree" are three separate entities.

Number of "unpurged" objects depends on num_online_cpus() and how many
pages each objects holds. For example on my 4xCPUs system the value
of lazy_max_pages() is 24576, i.e. in case of one object per one page
we get 24576 "unpurged" nodes in the rb-tree. 

v1 -> v2:
a) directly use merge_or_add_vmap_area() function in  __purge_vmap_area_lazy(),
   because VA is detached, i.e. there is no need to "unlink" it;

b) because of (a), we can avoid of modifying unlink_va() and keep
   WARN_ON(RB_EMPTY_NODE(&va->rb_node) in place as it used to be.

Appreciate for any comments and review.

Uladzislau Rezki (Sony) (1):
  mm/vmalloc: do not keep unpurged areas in the busy tree

 mm/vmalloc.c | 52 ++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 44 insertions(+), 8 deletions(-)

-- 
2.11.0

