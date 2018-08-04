Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 147296B0005
	for <linux-mm@kvack.org>; Sat,  4 Aug 2018 06:18:36 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id p5-v6so5087743pfh.11
        for <linux-mm@kvack.org>; Sat, 04 Aug 2018 03:18:36 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id v1-v6si5510578plo.380.2018.08.04.03.18.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Aug 2018 03:18:34 -0700 (PDT)
Subject: Re: [4.18 rc7] possible circular locking dependency detected
References: <CABXGCsOOBH6SW6=Z6Rw21cg_CKF_GZW7yP1v+L8pDK3MNykShw@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <cd557d30-8306-52de-09af-28e4d847219a@I-love.SAKURA.ne.jp>
Date: Sat, 4 Aug 2018 19:18:26 +0900
MIME-Version: 1.0
In-Reply-To: <CABXGCsOOBH6SW6=Z6Rw21cg_CKF_GZW7yP1v+L8pDK3MNykShw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org

On 2018/08/04 17:18, Mikhail Gavrilov wrote:
> Hi guys I see this warning already several times when use latest 4.18 kernel.
> May be this is well know issue, I don't know.
> Hope this can fixed soon.

https://marc.info/?l=linux-xfs&m=152954339303385

And since I can't afford fixing lockdep, we can't fix this soon...
