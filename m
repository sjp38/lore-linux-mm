Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id m549FXGn015495
	for <linux-mm@kvack.org>; Wed, 4 Jun 2008 10:15:34 +0100
Received: from an-out-0708.google.com (anac36.prod.google.com [10.100.54.36])
	by zps35.corp.google.com with ESMTP id m549FWE6020777
	for <linux-mm@kvack.org>; Wed, 4 Jun 2008 02:15:33 -0700
Received: by an-out-0708.google.com with SMTP id c36so126ana.36
        for <linux-mm@kvack.org>; Wed, 04 Jun 2008 02:15:32 -0700 (PDT)
Message-ID: <6599ad830806040215j4f49483bnfa474eb27120a5e3@mail.gmail.com>
Date: Wed, 4 Jun 2008 02:15:32 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 0/2] memcg: hierarchy support (v3)
In-Reply-To: <20080604181528.f4c94743.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830806040159o648392a1l3dbd84d9c765a847@mail.gmail.com>
	 <20080604181528.f4c94743.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 4, 2008 at 2:15 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> Should we try to support hierarchy and non-hierarchy cgroups in the
>> same tree? Maybe we should just enforce the restrictions that:
>>
>> - the hierarchy mode can't be changed on a cgroup if you have children
>> or any non-zero usage/limit
>> - a cgroup inherits its parent's hierarchy mode.
>>
> Ah, my patch does it (I think).  explanation is bad.
>
> - mem cgroup's mode can be changed against ROOT node which has no children.
> - a child inherits parent's mode.

But if it can only be changed for the root cgroup when it has no
children, than implies that all cgroups must have the same mode. I'm
suggesting that we allow non-root cgroups to change their mode, as
long as:

- they have no children

- they don't have any limit charged to their parent (which means that
either they have a zero limit, or they have no parent, or they're not
in hierarchy mode)

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
