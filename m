From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH 0/3] swsusp: Do not use page flags (was: Re: Remove page flags for software suspend)
Date: Fri, 9 Mar 2007 00:34:57 +0100
References: <Pine.LNX.4.64.0702160212150.21862@schroedinger.engr.sgi.com> <20070308231512.GB1977@elf.ucw.cz> <1173396094.3831.42.camel@johannes.berg>
In-Reply-To: <1173396094.3831.42.camel@johannes.berg>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200703090034.57978.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Berg <johannes@sipsolutions.net>
Cc: Pavel Machek <pavel@ucw.cz>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org, pm list <linux-pm@lists.osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Friday, 9 March 2007 00:21, Johannes Berg wrote:
> On Fri, 2007-03-09 at 00:15 +0100, Pavel Machek wrote:
> 
> > That's a no-no. ATOMIC alocations can fail, and no, WARN_ON is not
> > enough. It is not a bug, they just fail.
> 
> But like I said in my post, there's no way we can disable suspend to
> disk when they do, right now anyway. Also, this can't be called any
> later than a late initcall or such since it's __init, and thus there
> shouldn't be memory pressure yet that would cause this to fail.

Exactly.  If an atomic allocation fails at this stage, there is a bug IMHO
(although not necessarily in our code).

Still, the patch is not sufficient, so that's just a theoretical thing.

> In any case, I'd be much happier with having a "disable suspend"
> variable so we could print a big warning and set that flag.

Well, I think that if we can't get so little memory at this early stage, the
kernel will have much more trouble anyway. ;-)

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
