Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id m2H33ps6031678
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 20:03:51 -0700
Received: from py-out-1112.google.com (pybp76.prod.google.com [10.34.92.76])
	by zps75.corp.google.com with ESMTP id m2H33oUJ011918
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 20:03:51 -0700
Received: by py-out-1112.google.com with SMTP id p76so5963942pyb.6
        for <linux-mm@kvack.org>; Sun, 16 Mar 2008 20:03:50 -0700 (PDT)
Message-ID: <6599ad830803162003u63589715i7d06c8b271c22160@mail.gmail.com>
Date: Mon, 17 Mar 2008 11:03:49 +0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][2/3] Account and control virtual address space allocations
In-Reply-To: <47DDDE0B.4010809@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080316172942.8812.56051.sendpatchset@localhost.localdomain>
	 <20080316173005.8812.88290.sendpatchset@localhost.localdomain>
	 <6599ad830803161902r8f9a274t246a25b3d337fee8@mail.gmail.com>
	 <47DDDE0B.4010809@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 17, 2008 at 10:57 AM, Balbir Singh
<balbir@linux.vnet.ibm.com> wrote:
>
>  1. We want to be able to support hierarchial accounting and control

>  2. We want to track usage of the root cgroup and report it back to the user

What use cases do you have for that?

>  3. We don't want to treat the root cgroup as a special case.

Why? It is a special case, in that in a lot of machines there's only
going to be the root cgroup, and the subsystem won't be mounted. So in
those cases, paying any overhead is a cost without a benefit.

Alternatively, how about you skip tracking virtual address space
changes if the virtual address cgroup isn't mounted on any hierarchy?
When you mount it, you can do a pass across all mms and set the root
cgroup usage to their total.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
