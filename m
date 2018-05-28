Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 08D9F6B0003
	for <linux-mm@kvack.org>; Mon, 28 May 2018 09:05:40 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id w6-v6so5601318plp.14
        for <linux-mm@kvack.org>; Mon, 28 May 2018 06:05:40 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 1-v6si29637371plo.20.2018.05.28.06.05.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 May 2018 06:05:37 -0700 (PDT)
Subject: [PATCH] kmemleak: don't use __GFP_NOFAIL
References: <CA+7wUswp_Sr=hHqi1bwRZ3FE2wY5ozZWZ8Z1BgrFnSAmijUKjA@mail.gmail.com>
 <20180528083451.GE1517@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <f054219d-6daa-68b1-0c60-0acd9ad8c5ab@i-love.sakura.ne.jp>
Date: Mon, 28 May 2018 22:05:21 +0900
MIME-Version: 1.0
In-Reply-To: <20180528083451.GE1517@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Mathieu Malaterre <malat@debian.org>, Dmitry Vyukov <dvyukov@google.com>
Cc: linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>

