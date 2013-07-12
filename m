Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id E762F6B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 03:03:33 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id v20so7399288lbc.3
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 00:03:31 -0700 (PDT)
Message-ID: <51DFAA41.7040204@kernel.org>
Date: Fri, 12 Jul 2013 10:03:29 +0300
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous
 memory
References: <1373596462-27115-1-git-send-email-ccross@android.com> <1373596462-27115-2-git-send-email-ccross@android.com> <51DF9794.4010000@kernel.org> <CAMbhsRRybw+7wyNMrnnu+DMfDSGyMzrqidiY1tNXiTQBYkAsTw@mail.gmail.com>
In-Reply-To: <CAMbhsRRybw+7wyNMrnnu+DMfDSGyMzrqidiY1tNXiTQBYkAsTw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Dave Hansen <dave.hansen@intel.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Oleg Nesterov <oleg@redhat.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 07/12/2013 09:18 AM, Colin Cross wrote:
> This operates on vmas, so it can only handle naming page aligned
> regions.  It would work fine to identify the regions that contain JIT
> code, but not to identify individual functions.

Right. The obvious question is: does this need to be attached to
VMAs or could it be a separate data structure that can be used for
both?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
