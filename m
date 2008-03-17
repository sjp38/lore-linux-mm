Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id m2H1vdAP017046
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 18:57:39 -0700
Received: from py-out-1112.google.com (pyed32.prod.google.com [10.34.156.32])
	by zps75.corp.google.com with ESMTP id m2H1vcsf005517
	for <linux-mm@kvack.org>; Sun, 16 Mar 2008 18:57:39 -0700
Received: by py-out-1112.google.com with SMTP id d32so5253313pye.21
        for <linux-mm@kvack.org>; Sun, 16 Mar 2008 18:57:38 -0700 (PDT)
Message-ID: <6599ad830803161857r6d01f962vfd0f570e6124ab24@mail.gmail.com>
Date: Mon, 17 Mar 2008 09:57:37 +0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][0/3] Virtual address space control for cgroups
In-Reply-To: <47DDCDA7.4020108@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080316172942.8812.56051.sendpatchset@localhost.localdomain>
	 <6599ad830803161626q1fcf261bta52933bb5e7a6bdd@mail.gmail.com>
	 <47DDCDA7.4020108@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 17, 2008 at 9:47 AM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>
>  It will be code duplication to make it a new subsystem,

Would it? Other than the basic cgroup boilerplate, the only real
duplication that I could see would be that there'd need to be an
additional per-mm pointer back to the cgroup. (Which could be avoided
if we added a single per-mm pointer back to the "owning" task, which
would generally be the mm's thread group leader, so that you could go
quickly from an mm to a set of cgroup subsystems).

And the advantage would that you'd be able to more easily pick/choose
which bits of control you use (and pay for).

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
