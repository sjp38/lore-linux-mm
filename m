Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B9F626B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 11:38:13 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id u7-v6so11253330plr.13
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 08:38:13 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d17-v6si3292760pll.460.2018.04.04.08.38.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 08:38:12 -0700 (PDT)
Date: Wed, 4 Apr 2018 11:38:09 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180404113809.64955e93@gandalf.local.home>
In-Reply-To: <20180404152713.GM6312@dhcp22.suse.cz>
References: <20180403135607.GC5501@dhcp22.suse.cz>
	<20180403101753.3391a639@gandalf.local.home>
	<20180403161119.GE5501@dhcp22.suse.cz>
	<20180403185627.6bf9ea9b@gandalf.local.home>
	<20180404062039.GC6312@dhcp22.suse.cz>
	<20180404085901.5b54fe32@gandalf.local.home>
	<20180404141052.GH6312@dhcp22.suse.cz>
	<20180404102527.763250b4@gandalf.local.home>
	<20180404144255.GK6312@dhcp22.suse.cz>
	<20180404110442.4cf904ae@gandalf.local.home>
	<20180404152713.GM6312@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Wed, 4 Apr 2018 17:27:13 +0200
Michal Hocko <mhocko@kernel.org> wrote:


> I am afraid I cannot help you much more though.

No, you have actually been a great help. I'm finishing up a patch on
top of this one. I'll be posting it soon.

Thanks for your help and your time!

-- Steve
