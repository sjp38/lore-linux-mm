Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id BA5F46B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 17:32:51 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so9524361pdj.1
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 14:32:51 -0700 (PDT)
Message-ID: <525DB45B.4080908@intel.com>
Date: Tue, 15 Oct 2013 14:32:11 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous
 memory
References: <1381800678-16515-1-git-send-email-ccross@android.com>	<1381800678-16515-2-git-send-email-ccross@android.com> <20131015142132.853f383980be58e18fa3c60a@linux-foundation.org>
In-Reply-To: <20131015142132.853f383980be58e18fa3c60a@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Jan Glauber <jan.glauber@gmail.com>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Kees Cook <keescook@chromium.org>, "Serge E. Hallyn" <serge.hallyn@ubuntu.com>, David Rientjes <rientjes@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Tang Chen <tangchen@cn.fujitsu.com>, Robin Holt <holt@sgi.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, open@kvack.org, list@kvack.org, DOCUMENTATION <linux-doc@vger.kernel.org>open@kvack.orglist@kvack.org, MEMORY MANAGEMENT <linux-mm@kvack.org>

On 10/15/2013 02:21 PM, Andrew Morton wrote:
> - Fishing around in another process's user memory for /proc strings
>   is unusual and problems might crop up if we missed something.  

FWIW, it might not be the _most_ common thing, but there is quite a bit
of precedent provided by /proc/$pid/cmdline.  We can be at least assured
that if we follow the same rules as that file we shouldn't be making the
situation any worse.  The cmdline mm->arg_start is just as
user-controlled as the pointers are in this new case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
