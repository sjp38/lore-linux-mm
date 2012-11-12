Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 7E2F86B0070
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 17:28:20 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so3188599dad.14
        for <linux-mm@kvack.org>; Mon, 12 Nov 2012 14:28:19 -0800 (PST)
Date: Mon, 12 Nov 2012 14:28:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/2] mm, oom: fix race when specifying a thread as the
 oom origin
In-Reply-To: <CACnwZYcUEmEStT7uwN3O3=m34uLi9YnJSYWFPZafuzCy_t4uaw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1211121427580.29870@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1211080125150.3450@chino.kir.corp.google.com> <alpine.DEB.2.00.1211080126390.3450@chino.kir.corp.google.com> <20121108155112.GN31821@dhcp22.suse.cz> <CACnwZYcUEmEStT7uwN3O3=m34uLi9YnJSYWFPZafuzCy_t4uaw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thiago Farina <tfransosi@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 12 Nov 2012, Thiago Farina wrote:

> > I didn't like the previous playing with the oom_score_adj and what you
> > propose looks much nicer.
> > Maybe s/oom_task_origin/task_oom_origin/ would be a better fit
> May be s/oom_task_origin/is_task_origin_oom? Just my 2 cents.
> 

I like to prefix oom killer functions in the global namespace with "oom_"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
