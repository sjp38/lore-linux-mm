Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0163C6B7896
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 01:44:05 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id m1-v6so16626731plb.13
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 22:44:04 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id l6si18584690pgg.592.2018.12.05.22.44.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 22:44:03 -0800 (PST)
Message-ID: <1544078602.3228.3.camel@suse.com>
Subject: Re: [RFC PATCH] hwpoison, memory_hotplug: allow hwpoisoned pages to
 be offlined
From: osalvador <osalvador@suse.com>
Date: Thu, 06 Dec 2018 07:43:22 +0100
In-Reply-To: <20181205165716.GS1286@dhcp22.suse.cz>
References: <20181203100309.14784-1-mhocko@kernel.org>
	 <20181205122918.GL1286@dhcp22.suse.cz>
	 <20181205165716.GS1286@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@gmail.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>


> Btw. the way how we drop all the work on the first page that we
> cannot
> isolate is just goofy. Why don't we simply migrate all that we
> already
> have on the list and go on? Something for a followup cleanup though.

Indeed, that is just wrong.
I will try to send a followup cleanup to fix that.


> Debugged-by: Oscar Salvador <osalvador@suse.com>
> Cc: stable
> Signed-off-by: Michal Hocko <mhocko@suse.com>

It has been a fun bug to chase down, thanks for the patch ;-)

Reviewed-by: Oscar Salvador <osalvador@suse.com>
Tested-by: Oscar Salvador <osalvador@suse.com>
