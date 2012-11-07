Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 0C7786B002B
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 14:31:08 -0500 (EST)
Date: Wed, 7 Nov 2012 11:31:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2 0/2] Provide more precise dump info for memcg-oom
Message-Id: <20121107113107.d91eba43.akpm@linux-foundation.org>
In-Reply-To: <1352277602-21687-1-git-send-email-handai.szj@taobao.com>
References: <1352277602-21687-1-git-send-email-handai.szj@taobao.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, rientjes@google.com, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On Wed,  7 Nov 2012 16:40:02 +0800
Sha Zhengju <handai.szj@gmail.com> wrote:

> When memcg oom is happening the current memcg related dump information
> is limited for debugging. The patches provide more detailed memcg page statistics
> and also take hierarchy into consideration.

Within the changelogs, please include a sample of the proposed output
so we can properly review the proposal.

Also it would be useful to provide some justification for the decisions
in this patch: which data is displayed and, particularly, which is not?
Why is the displayed information useful to developers, etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
