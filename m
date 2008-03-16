Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id m2GNQOUC002665
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 23:26:25 GMT
Received: from wx-out-0506.google.com (wxdh26.prod.google.com [10.70.134.26])
	by zps76.corp.google.com with ESMTP id m2GNQN57019660
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 16:26:23 -0700
Received: by wx-out-0506.google.com with SMTP id h26so5621490wxd.22
        for <linux-mm@kvack.org>; Sun, 16 Mar 2008 16:26:23 -0700 (PDT)
Message-ID: <6599ad830803161626q1fcf261bta52933bb5e7a6bdd@mail.gmail.com>
Date: Mon, 17 Mar 2008 07:26:22 +0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][0/3] Virtual address space control for cgroups
In-Reply-To: <20080316172942.8812.56051.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080316172942.8812.56051.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 17, 2008 at 1:29 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> This is an early patchset for virtual address space control for cgroups.
>  The patches are against 2.6.25-rc5-mm1 and have been tested on top of
>  User Mode Linux.

What's the performance hit of doing these accounting checks on every
mmap/munmap? If it's not totally lost in the noise, couldn't it be
made a separate control group, so that it could be just enabled (and
the performance hit taken) for users that actually want it?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
