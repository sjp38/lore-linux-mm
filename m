Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 03B7B6B7FED
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 15:24:14 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id g77-v6so2923525lfg.21
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 12:24:13 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e11-v6sor4820051ljg.15.2018.09.07.12.24.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 12:24:12 -0700 (PDT)
Subject: Re: [RESEND PATCH] mm: percpu: remove unnecessary unlikely()
References: <20180907181035.1662-1-igor.stoppa@huawei.com>
 <20180907183909.GA84248@dennisz-mbp.dhcp.thefacebook.com>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <8df1c498-5e85-b058-c9a9-0b29d51b8df3@gmail.com>
Date: Fri, 7 Sep 2018 22:24:10 +0300
MIME-Version: 1.0
In-Reply-To: <20180907183909.GA84248@dennisz-mbp.dhcp.thefacebook.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisszhou@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Igor Stoppa <igor.stoppa@huawei.com>, zijun_hu <zijun_hu@htc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/09/18 21:39, Dennis Zhou wrote:

> Sorry for the delay. I'll be taking over the percpu tree and am in the
> process of getting a tree. I'm still keeping track of this and will take
> it for the next release.

ok, np!

--
thank you, igor
