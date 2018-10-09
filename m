Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0F6ED6B000C
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 04:02:56 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w42-v6so780616edd.0
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 01:02:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g44-v6si6190724eda.217.2018.10.09.01.02.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 01:02:54 -0700 (PDT)
Date: Tue, 9 Oct 2018 10:02:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: [PATCH] mm, oom_adj: avoid meaningless loop to find
 processes sharing mm
Message-ID: <20181009080253.GD8528@dhcp22.suse.cz>
References: <67eedc4c-7afa-e845-6c88-9716fd820de6@i-love.sakura.ne.jp>
 <af7ae9c4-d7f1-69af-58fa-ec6949161f5b@I-love.SAKURA.ne.jp>
 <20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p8>
 <20181008061407epcms1p519703ae6373a770160c8f912c7aa9521@epcms1p5>
 <CGME20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p2>
 <20181008083855epcms1p20e691e5a001f3b94b267997c24e91128@epcms1p2>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181008083855epcms1p20e691e5a001f3b94b267997c24e91128@epcms1p2>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yong-Taek Lee <ytk.lee@samsung.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon 08-10-18 17:38:55, Yong-Taek Lee wrote:
> Do you have any other idea to avoid meaningless loop ? 

I have already asked in the earlier posting but let's follow up here.
Could you please expand on why this actually matters and what are the
consequences please?
-- 
Michal Hocko
SUSE Labs
