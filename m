Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id mA46QLt6017157
	for <linux-mm@kvack.org>; Mon, 3 Nov 2008 22:26:21 -0800
Received: from rv-out-0506.google.com (rvfb25.prod.google.com [10.140.179.25])
	by spaceape14.eur.corp.google.com with ESMTP id mA46Pl3Y021439
	for <linux-mm@kvack.org>; Mon, 3 Nov 2008 22:26:19 -0800
Received: by rv-out-0506.google.com with SMTP id b25so2943690rvf.41
        for <linux-mm@kvack.org>; Mon, 03 Nov 2008 22:26:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <6599ad830811032225w229d3a29k17b9a38cb76a521f@mail.gmail.com>
References: <20081101184812.2575.68112.sendpatchset@balbir-laptop>
	 <20081101184824.2575.5935.sendpatchset@balbir-laptop>
	 <6599ad830811032225w229d3a29k17b9a38cb76a521f@mail.gmail.com>
Date: Mon, 3 Nov 2008 22:26:19 -0800
Message-ID: <6599ad830811032226h4c4a81d4hb030953a4e0906db@mail.gmail.com>
Subject: Re: [mm] [PATCH 1/4] Memory cgroup hierarchy documentation
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 3, 2008 at 10:25 PM, Paul Menage <menage@google.com> wrote:
>
> That's not a very intuitive interface. Why not memory.use_hierarchy?

Or for consistency with the existing cpuset.memory_pressure_enabled,
just memory.hierarchy_enabled ?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
