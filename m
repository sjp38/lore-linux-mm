Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0636B0005
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 12:59:20 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 1-v6so10532401plv.6
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 09:59:20 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a9si2217599pgu.454.2018.04.03.09.59.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 09:59:18 -0700 (PDT)
Date: Tue, 3 Apr 2018 12:59:14 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180403125914.66f8abbb@gandalf.local.home>
In-Reply-To: <20180403161119.GE5501@dhcp22.suse.cz>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
	<20180330102038.2378925b@gandalf.local.home>
	<20180403110612.GM5501@dhcp22.suse.cz>
	<20180403075158.0c0a2795@gandalf.local.home>
	<20180403121614.GV5501@dhcp22.suse.cz>
	<20180403082348.28cd3c1c@gandalf.local.home>
	<20180403123514.GX5501@dhcp22.suse.cz>
	<20180403093245.43e7e77c@gandalf.local.home>
	<20180403135607.GC5501@dhcp22.suse.cz>
	<20180403101753.3391a639@gandalf.local.home>
	<20180403161119.GE5501@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Tue, 3 Apr 2018 18:11:19 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> yes a fallback is questionable. Whether to make the batch size
> configuration is a matter of how much internal details you want to
> expose to userspace.

Well, it is tracing the guts of the kernel, so internal details are
generally exposed to userspace ;-)

-- Steve
