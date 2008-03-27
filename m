Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id m2RDxsFW027427
	for <linux-mm@kvack.org>; Thu, 27 Mar 2008 06:59:54 -0700
Received: from py-out-1112.google.com (pyhn24.prod.google.com [10.34.240.24])
	by zps38.corp.google.com with ESMTP id m2RDxrh4027891
	for <linux-mm@kvack.org>; Thu, 27 Mar 2008 06:59:54 -0700
Received: by py-out-1112.google.com with SMTP id n24so4651821pyh.26
        for <linux-mm@kvack.org>; Thu, 27 Mar 2008 06:59:53 -0700 (PDT)
Message-ID: <6599ad830803270659s3e23edaava58d7403b7262369@mail.gmail.com>
Date: Thu, 27 Mar 2008 06:59:52 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][0/3] Virtual address space control for cgroups (v2)
In-Reply-To: <20080327190323.f55a73e9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080326184954.9465.19379.sendpatchset@localhost.localdomain>
	 <6599ad830803261522p45a9daddi8100a0635c21cf7d@mail.gmail.com>
	 <20080327190323.f55a73e9.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 27, 2008 at 3:03 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>  How about creating "rlimit controller" and expands rlimit to process groups ?
>  I think it's more straightforward to do this.
>

Yes, that could be useful - the only concern that I would have is that
putting all the rlimits in the same subsystem could limit flexibility.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
