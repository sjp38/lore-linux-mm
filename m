Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 1E83C6B00FE
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 12:12:25 -0500 (EST)
Date: Wed, 22 Feb 2012 18:12:21 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [PATCH] thp: 'transparent_hugepage=' can also be specified on
 cmdline
In-Reply-To: <20120222170315.GJ10222@redhat.com>
Message-ID: <alpine.LNX.2.00.1202221811380.31150@pobox.suse.cz>
References: <alpine.LNX.2.00.1202221710050.31150@pobox.suse.cz> <20120222170315.GJ10222@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>

On Wed, 22 Feb 2012, Andrea Arcangeli wrote:

> > diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
> > index 29bdf62..4a3816d 100644
> > --- a/Documentation/vm/transhuge.txt
> > +++ b/Documentation/vm/transhuge.txt
> > @@ -103,6 +103,9 @@ echo always >/sys/kernel/mm/transparent_hugepage/enabled
> >  echo madvise >/sys/kernel/mm/transparent_hugepage/enabled
> >  echo never >/sys/kernel/mm/transparent_hugepage/enabled
> >  
> > +The always/madvise/never value can also be specified on the kernel boot
> > +commandline using 'transparent_hugepage=' parameter.
> > +
> >  It's also possible to limit defrag efforts in the VM to generate
> 
> This is a dup.

I am blind and you are right.

v2 below. Thanks.



From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH] thp: 'transparent_hugepage=' can also be specified on cmdline

Behavior of THP can either be toggled through sysfs in runtime or using a 
kernel cmdline parameter 'transparent_hugepage='. Document the latter in 
kernel-parameters.txt

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 Documentation/kernel-parameters.txt |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 033d4e6..a4de9b9 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -2629,6 +2629,13 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 			to facilitate early boot debugging.
 			See also Documentation/trace/events.txt
 
+	transparent_hugepage=
+			[KNL]
+			Format: [always|madvise|never]
+			Can be used to control the default behavior of the system
+			with respect to transparent hugepages.
+			See Documentation/vm/transhuge.txt for more details.
+
 	tsc=		Disable clocksource stability checks for TSC.
 			Format: <string>
 			[x86] reliable: mark tsc clocksource as reliable, this

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
