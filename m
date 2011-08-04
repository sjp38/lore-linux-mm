Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id ADF256B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 21:59:35 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] mm/mempolicy.c: make sys_mbind & sys_set_mempolicy aware of task_struct->mems_allowed
References: <20110803123721.GA2892@x61.redhat.com>
Date: Wed, 03 Aug 2011 18:59:33 -0700
In-Reply-To: <20110803123721.GA2892@x61.redhat.com> (Rafael Aquini's message
	of "Wed, 3 Aug 2011 09:37:27 -0300")
Message-ID: <m2d3gm0we2.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

Rafael Aquini <aquini@redhat.com> writes:

> Among several other features enabled when CONFIG_CPUSETS is defined,
> task_struct is enhanced with the nodemask_t mems_allowed element that
> serves to register/report on which memory nodes the task may obtain
> memory. Also, two new lines that reflect the value registered at
> task_struct->mems_allowed are added to the '/proc/[pid]/status' file:

As Christoph said this was intentionally designed this way. Originally
there was some consideration of "relative policies", but that is not
implemented and had various issues. 

They're orthogonal mechanisms.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
