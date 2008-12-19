Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E880A6B0047
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 21:04:52 -0500 (EST)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id mBJ26oPK015342
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 18:06:51 -0800
Received: from qyk13 (qyk13.prod.google.com [10.241.83.141])
	by wpaz24.hot.corp.google.com with ESMTP id mBJ26mUr032441
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 18:06:49 -0800
Received: by qyk13 with SMTP id 13so783257qyk.5
        for <linux-mm@kvack.org>; Thu, 18 Dec 2008 18:06:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20081217140318.c6832440.akpm@linux-foundation.org>
References: <20081216113055.713856000@menage.corp.google.com>
	 <20081217140318.c6832440.akpm@linux-foundation.org>
Date: Thu, 18 Dec 2008 18:06:48 -0800
Message-ID: <6599ad830812181806h461ef9d6xb3b99da290ae521f@mail.gmail.com>
Subject: Re: [PATCH 0/3] CGroups: Hierarchy locking/refcount changes
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kamezawa.hiroyu@jp.fujitsu.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Dec 17, 2008 at 2:03 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> cgroups-make-root_list-contains-active-hierarchies-only.patch
> cgroups-add-inactive-subsystems-to-rootnodesubsys_list.patch
> cgroups-add-inactive-subsystems-to-rootnodesubsys_list-fix.patch
> cgroups-introduce-link_css_set-to-remove-duplicate-code.patch
> cgroups-introduce-link_css_set-to-remove-duplicate-code-fix.patch
>
> it wasn't clear to me whether you still had issues with them, or
> whether updates were expected?

I think that with the fix patches they should be fine.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
