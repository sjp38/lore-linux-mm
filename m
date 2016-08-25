Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC7D83093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 07:45:22 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id e7so30427243lfe.0
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 04:45:22 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id k5si31226425wmc.122.2016.08.25.04.45.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 25 Aug 2016 04:45:21 -0700 (PDT)
Date: Thu, 25 Aug 2016 13:44:34 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH v6 20/20] thermal/intel_powerclamp: Convert the kthread
 to kthread worker API
Message-ID: <20160825114434.m7rhladpllj54rtb@linutronix.de>
References: <1460646879-617-1-git-send-email-pmladek@suse.com>
 <1460646879-617-21-git-send-email-pmladek@suse.com>
 <20160825083316.myqbas7d6gtv62c6@linutronix.de>
 <20160825113708.GH4866@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20160825113708.GH4866@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>, Eduardo Valentin <edubezval@gmail.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-pm@vger.kernel.org

On 2016-08-25 13:37:08 [+0200], Petr Mladek wrote:
> There were still some discussions about the kthread worker API.
> Anyway, the needed kthread API changes are in Andrew's -mm tree now
> and will be hopefully included in 4.9.

Thanks for the update.

> I did not want to send the patches using the API before the API
> changes are upstream. But I could send the two intel_powerclamp
> patches now if you are comfortable with having them on top of
> the -mm tree or linux-next.

I am refreshing my hotplug queue and stumbled over my old powerclamp
patch. Please send them (offline) so I can have a look :) And I add a
note for powerclaml to be v4.9 or so.

> Best Regards,
> Petr

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
