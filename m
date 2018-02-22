Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 62BBB6B02C1
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 08:00:01 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id y130so920359wmd.6
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 05:00:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h184si222761wma.121.2018.02.22.04.59.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Feb 2018 04:59:59 -0800 (PST)
Date: Thu, 22 Feb 2018 13:59:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mmotm 2018-02-21-14-48 uploaded (mm/page_alloc.c on UML)
Message-ID: <20180222125955.GD30681@dhcp22.suse.cz>
References: <20180221224839.MqsDtkGCK%akpm@linux-foundation.org>
 <7bcc52db-57eb-45b0-7f20-c93a968599cd@infradead.org>
 <20180222072037.GC30681@dhcp22.suse.cz>
 <20180222103832.GA11623@vmlxhi-102.adit-jv.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180222103832.GA11623@vmlxhi-102.adit-jv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eugeniu Rosca <erosca@de.adit-jv.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org, broonie@kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, mm-commits@vger.kernel.org, sfr@canb.auug.org.au, richard -rw- weinberger <richard.weinberger@gmail.com>

On Thu 22-02-18 11:38:32, Eugeniu Rosca wrote:
> Hi Michal,
> 
> Please, let me know if any action is expected from my end.

I do not thing anything is really needed right now. If you have a strong
opinion about the solution (ifdef vs. noop stub) then speak up.

> Thank you for your support and sorry for the ifdef troubles.

No troubles at all. It was me who pushed you this direction...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
