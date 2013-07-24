Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 0E5216B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 05:40:41 -0400 (EDT)
Received: by mail-bk0-f43.google.com with SMTP id jm2so78687bkc.30
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 02:40:40 -0700 (PDT)
Date: Wed, 24 Jul 2013 11:40:36 +0200
From: Jan Glauber <jan.glauber@gmail.com>
Subject: Re: [PATCH] mm: add sys_madvise2 and MADV_NAME to name vmas
Message-ID: <20130724094035.GA28894@hal>
References: <1372901537-31033-1-git-send-email-ccross@android.com>
 <20130704202232.GA19287@redhat.com>
 <CAMbhsRRjGjo_-zSigmdsDvY-kfBhmP49bDQzsgHfj5N-y+ZAdw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMbhsRRjGjo_-zSigmdsDvY-kfBhmP49bDQzsgHfj5N-y+ZAdw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: Oleg Nesterov <oleg@redhat.com>, lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rusty Russell <rusty@rustcorp.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>

On Fri, Jul 05, 2013 at 12:40:50PM -0700, Colin Cross wrote:
> On Thu, Jul 4, 2013 at 1:22 PM, Oleg Nesterov <oleg@redhat.com> wrote:
> > On 07/03, Colin Cross wrote:
> >>
> >> The names of named anonymous vmas are shown in /proc/pid/maps
> >> as [anon:<name>].  The name of all named vmas are shown in
> >> /proc/pid/smaps in a new "Name" field that is only present
> >> for named vmas.
> >
> > And this is the only purpose, yes?
> 

The heuristics used for the thread stack annotation is not working always:

https://lkml.org/lkml/2013/6/26/256

Maybe we can get rid of the heuristic if there is an explicit interface to
mark vma's?

OTOH, a new flag bit instead of a string would be enough to mark the thread
stacks correctly.

--Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
