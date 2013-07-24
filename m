Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 122486B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 16:05:10 -0400 (EDT)
Received: by mail-ob0-f181.google.com with SMTP id 16so14235180obc.12
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 13:05:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130724094035.GA28894@hal>
References: <1372901537-31033-1-git-send-email-ccross@android.com>
	<20130704202232.GA19287@redhat.com>
	<CAMbhsRRjGjo_-zSigmdsDvY-kfBhmP49bDQzsgHfj5N-y+ZAdw@mail.gmail.com>
	<20130724094035.GA28894@hal>
Date: Wed, 24 Jul 2013 13:05:09 -0700
Message-ID: <CAMbhsRQo6f5UnxmibrJPkmKbMscBAYq88y7vKtnxd5ctE=xvSA@mail.gmail.com>
Subject: Re: [PATCH] mm: add sys_madvise2 and MADV_NAME to name vmas
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Glauber <jan.glauber@gmail.com>
Cc: Oleg Nesterov <oleg@redhat.com>, lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rusty Russell <rusty@rustcorp.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>

On Wed, Jul 24, 2013 at 2:40 AM, Jan Glauber <jan.glauber@gmail.com> wrote:
> On Fri, Jul 05, 2013 at 12:40:50PM -0700, Colin Cross wrote:
>> On Thu, Jul 4, 2013 at 1:22 PM, Oleg Nesterov <oleg@redhat.com> wrote:
>> > On 07/03, Colin Cross wrote:
>> >>
>> >> The names of named anonymous vmas are shown in /proc/pid/maps
>> >> as [anon:<name>].  The name of all named vmas are shown in
>> >> /proc/pid/smaps in a new "Name" field that is only present
>> >> for named vmas.
>> >
>> > And this is the only purpose, yes?
>>
>
> The heuristics used for the thread stack annotation is not working always:
>
> https://lkml.org/lkml/2013/6/26/256
>
> Maybe we can get rid of the heuristic if there is an explicit interface to
> mark vma's?
>
> OTOH, a new flag bit instead of a string would be enough to mark the thread
> stacks correctly.

I noticed this possibility when looking at the stack naming code, but
I didn't have any evidence that it actually happens.  As my patch is
written (as well as the new version, see
http://permalink.gmane.org/gmane.linux.kernel.mm/103228) it will
ignore any vma that found a name any other way, but it could be
changed to override the automatic stack naming.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
