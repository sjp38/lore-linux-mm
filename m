Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id AA84D6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 08:52:10 -0500 (EST)
Received: by mail-io0-f172.google.com with SMTP id 1so19953112ion.1
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 05:52:10 -0800 (PST)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id d1si43252012igc.46.2016.01.20.05.52.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 05:52:10 -0800 (PST)
Received: by mail-io0-x22a.google.com with SMTP id 1so19952870ion.1
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 05:52:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1512101441140.19122@east.gentwo.org>
References: <alpine.DEB.2.20.1512101441140.19122@east.gentwo.org>
Date: Wed, 20 Jan 2016 19:22:09 +0530
Message-ID: <CAPub148GRFho0oS9Vf0UdX+2Q84+031DE7jKj6Nxc0o0ZqWEmA@mail.gmail.com>
Subject: Re: vmstat: make vmstat_updater deferrable again and shut down on idle
From: Shiraz Hashim <shiraz.linux.kernel@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp

Hi Christoph,

On Fri, Dec 11, 2015 at 2:15 AM, Christoph Lameter <cl@linux.com> wrote:
> Currently the vmstat updater is not deferrable as a result of commit
> ba4877b9ca51f80b5d30f304a46762f0509e1635. This in turn can cause multiple
> interruptions of the applications because the vmstat updater may run at
> different times than tick processing. No good.
>
> Make vmstate_update deferrable again and provide a function that
> folds the differentials when the processor is going to idle mode thus
> addressing the issue of the above commit in a clean way.
>

The patch makes vmstat_shepherd deferable which if is quiesed
would not schedule vmstat update on other cpus. Wouldn't this
aggravate the problem of vmstat for rest cpus not gettng updated.

regards
Shiraz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
