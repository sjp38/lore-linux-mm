Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 910F69000C6
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 14:44:37 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] HWPOISON: Convert pr_debug()s to pr_info()s
References: <20110920183254.3926.59134.email-sent-by-dnelson@localhost6.localdomain6>
Date: Tue, 20 Sep 2011 11:44:35 -0700
In-Reply-To: <20110920183254.3926.59134.email-sent-by-dnelson@localhost6.localdomain6>
	(Dean Nelson's message of "Tue, 20 Sep 2011 14:32:55 -0400")
Message-ID: <m27h53dpf0.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dean Nelson <dnelson@redhat.com>
Cc: linux-mm@kvack.org, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

Dean Nelson <dnelson@redhat.com> writes:

> Commit fb46e73520940bfc426152cfe5e4a9f1ae3f00b6 authored by Andi Kleen
> converted a number of pr_debug()s to pr_info()s.
>
> About the same time additional code with pr_debug()s was added by
> two other commits 8c6c2ecb44667f7204e9d2b89c4c1f42edc5a196 and
> d950b95882f3dc47e86f1496cd3f7fef540d6d6b. And these pr_debug()s
> failed to get converted to pr_info()s.
>
> This patch converts them as well. And does some minor related
> whitespace cleanup.
>
> Signed-off-by: Dean Nelson <dnelson@redhat.com>

Looks good. Andrew please merge.

Reviewed-by: Andi Kleen <ak@linux.intel.com>

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
