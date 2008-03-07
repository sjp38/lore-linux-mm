Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id m278f0YU021490
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 08:41:00 GMT
Received: from wx-out-0506.google.com (wxcs9.prod.google.com [10.70.120.9])
	by zps78.corp.google.com with ESMTP id m278ewJn022804
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 00:40:59 -0800
Received: by wx-out-0506.google.com with SMTP id s9so582224wxc.32
        for <linux-mm@kvack.org>; Fri, 07 Mar 2008 00:40:58 -0800 (PST)
Message-ID: <6599ad830803070040i5e54f5f3u9b4c753ac5a87771@mail.gmail.com>
Date: Fri, 7 Mar 2008 00:40:58 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] Add cgroup support for enabling controllers at boot time
In-Reply-To: <alpine.DEB.1.00.0803062111560.26462@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080306185952.23290.49571.sendpatchset@localhost.localdomain>
	 <alpine.DEB.1.00.0803061108370.13110@chino.kir.corp.google.com>
	 <47D0C76D.8050207@linux.vnet.ibm.com>
	 <alpine.DEB.1.00.0803062111560.26462@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 6, 2008 at 9:14 PM, David Rientjes <rientjes@google.com> wrote:
>
>  Since the command line is logically delimited by spaces, you can
>  accidently disable a subsystem if its name appears in any of your kernel
>  options following your cgroup_disable= option.

I think that you're confusing this with things like the very early
memory init setup parameters, which do operate on the raw commandline.

By the time anything is passed to a __setup() function, it's already
been split into separate strings at space boundaries.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
