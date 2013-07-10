Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id B49986B0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 22:50:11 -0400 (EDT)
Received: by mail-oa0-f54.google.com with SMTP id o6so9088780oag.27
        for <linux-mm@kvack.org>; Tue, 09 Jul 2013 19:50:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130709152836.GA10033@redhat.com>
References: <1372901537-31033-1-git-send-email-ccross@android.com>
 <20130704202232.GA19287@redhat.com> <CAMbhsRRjGjo_-zSigmdsDvY-kfBhmP49bDQzsgHfj5N-y+ZAdw@mail.gmail.com>
 <20130708180424.GA6490@redhat.com> <20130708180501.GB6490@redhat.com>
 <CAHGf_=qPuzH_R1Jfztnhj4JEAX9xfD37461LRKrhHgL4nq-eHg@mail.gmail.com> <20130709152836.GA10033@redhat.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 9 Jul 2013 22:49:50 -0400
Message-ID: <CAHGf_=okii403nAx9tO2B+yU571gOaFM9dthMdDXj520CsCjWA@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm: mempolicy: fix mbind_range() && vma_adjust() interaction
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Colin Cross <ccross@android.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Hampson, Steven T" <steven.t.hampson@intel.com>, lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Arnd Bergmann <arnd@arndb.de>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rusty Russell <rusty@rustcorp.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>

>> case 3 makes the same scenario?
>
> Not really, afaics. "case 3" is when vma_merge() "merges" a hole with
> vma, mbind_range() works with the already mmapped regions.

Oops, you are right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
