Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3B9146B00AC
	for <linux-mm@kvack.org>; Wed, 17 Dec 2008 17:02:58 -0500 (EST)
Date: Wed, 17 Dec 2008 14:03:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] CGroups: Hierarchy locking/refcount changes
Message-Id: <20081217140318.c6832440.akpm@linux-foundation.org>
In-Reply-To: <20081216113055.713856000@menage.corp.google.com>
References: <20081216113055.713856000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: menage@google.com
Cc: kamezawa.hiroyu@jp.fujitsu.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Dec 2008 03:30:55 -0800
menage@google.com wrote:

> These patches introduce new locking/refcount support for cgroups to
> reduce the need for subsystems to call cgroup_lock(). This will
> ultimately allow the atomicity of cgroup_rmdir() (which was removed
> recently) to be restored.

OK, they merged OK.  We're accumulating rather a lot of cgroups work.

I have a question mark over these:

cgroups-make-root_list-contains-active-hierarchies-only.patch
cgroups-add-inactive-subsystems-to-rootnodesubsys_list.patch
cgroups-add-inactive-subsystems-to-rootnodesubsys_list-fix.patch
cgroups-introduce-link_css_set-to-remove-duplicate-code.patch
cgroups-introduce-link_css_set-to-remove-duplicate-code-fix.patch

it wasn't clear to me whether you still had issues with them, or
whether updates were expected?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
