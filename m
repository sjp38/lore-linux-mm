Received: by gxk8 with SMTP id 8so12777516gxk.14
        for <linux-mm@kvack.org>; Wed, 10 Sep 2008 00:26:45 -0700 (PDT)
Message-ID: <48C776B0.9070703@gmail.com>
Date: Wed, 10 Sep 2008 09:26:40 +0200
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH -mm] cgroup: limit the amount of dirty file pages
References: <48C6987D.2050905@gmail.com> <1220982584.23386.219.camel@nimitz>
In-Reply-To: <1220982584.23386.219.camel@nimitz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Radford <dradford@bluehost.com>, Marco Innocenti <m.innocenti@cineca.it>, =?ISO-8859-1?Q?Fernando_Luis_?= =?ISO-8859-1?Q?V=E1zquez_Cao?= <fernando@oss.ntt.co.jp>, containers@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, Carl Henrik Lunde <chlunde@ping.uio.no>, linux-mm@kvack.org, Divyesh Shah <dpshah@google.com>, Matt Heaton <matt@bluehost.com>, Andrew Morton <akpm@linux-foundation.org>, Naveen Gupta <ngupta@google.com>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Tue, 2008-09-09 at 17:38 +0200, Andrea Righi wrote:
>> It allows to control how much dirty file pages a cgroup can have at any
>> given time. This feature is supposed to be strictly connected to a
>> generic cgroup IO controller (see below).
> 
> So, this functions similarly to our global dirty ratio?  Is it just
> intended to keep a cgroup from wedging itself too hard with too many
> dirty pages, just like the global ratio?
> 
> -- Dave

Correct, it's the same functionality provided by vm.dirty_ratio and
vm.dirty_background_ratio, except that is intended to be per-cgroup.

Without this functionality, a cgroup can even dirty all its memory,
allocated by the memory controller, since statistics and writeback
configurations are global.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
