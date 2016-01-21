Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 06B6E6B0005
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 01:24:50 -0500 (EST)
Received: by mail-io0-f181.google.com with SMTP id q21so44562620iod.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 22:24:50 -0800 (PST)
Received: from mail-ig0-x243.google.com (mail-ig0-x243.google.com. [2607:f8b0:4001:c05::243])
        by mx.google.com with ESMTPS id z197si2595711iod.89.2016.01.20.22.24.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 22:24:49 -0800 (PST)
Received: by mail-ig0-x243.google.com with SMTP id h5so3452825igh.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 22:24:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1601200910480.21388@east.gentwo.org>
References: <alpine.DEB.2.20.1512101441140.19122@east.gentwo.org>
	<CAPub148GRFho0oS9Vf0UdX+2Q84+031DE7jKj6Nxc0o0ZqWEmA@mail.gmail.com>
	<alpine.DEB.2.20.1601200910480.21388@east.gentwo.org>
Date: Thu, 21 Jan 2016 11:54:49 +0530
Message-ID: <CAPub14_S6swU_SPzZjx_OwyWhPBzXsfaoQ4Xc4qAKTDbtmjPSA@mail.gmail.com>
Subject: Re: vmstat: make vmstat_updater deferrable again and shut down on idle
From: Shiraz Hashim <shiraz.linux.kernel@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp

On Wed, Jan 20, 2016 at 8:42 PM, Christoph Lameter <cl@linux.com> wrote:
> On Wed, 20 Jan 2016, Shiraz Hashim wrote:
>
>> The patch makes vmstat_shepherd deferable which if is quiesed
>> would not schedule vmstat update on other cpus. Wouldn't this
>> aggravate the problem of vmstat for rest cpus not gettng updated.
>
> Its only "deferred" in order to make it at the next tick and not cause an
> extra event. This means that vmstat will run periodically from tick
> processing. It merely causes a synching so that we have one interruption
> that does both.
>
> On idle we fold counters immediately. So there is no loss of accuracy.
>

vmstat is scheduled by shepherd or by itself (conditionally). In case shepherd
is deferred and vmstat doesn't schedule itself, then vmstat needs to wait
for shepherd to be up and then schedule it. This may end up in delayed status
update for all live cpus. Isn't it ?

-- 
regards
Shiraz Hashim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
