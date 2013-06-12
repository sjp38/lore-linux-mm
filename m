Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 82C796B0034
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 00:15:07 -0400 (EDT)
Message-ID: <1371010505.2069.3.camel@joe-AO722>
Subject: Re: [checkpatch] - Confusion
From: Joe Perches <joe@perches.com>
Date: Tue, 11 Jun 2013 21:15:05 -0700
In-Reply-To: <8a2ec29d-e6d8-44ed-a70d-2273848706ce@VA3EHSMHS029.ehs.local>
References: <1370843475.58124.YahooMailNeo@web160106.mail.bf1.yahoo.com>
	 <CAK7N6vrQFK=9OQi7dDUgGWWNQk71x3BeqPA9x3Pq66baA61PrQ@mail.gmail.com>
	 <1370890140.99216.YahooMailNeo@web160102.mail.bf1.yahoo.com>
	 <8a2ec29d-e6d8-44ed-a70d-2273848706ce@VA3EHSMHS029.ehs.local>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?S=F6ren?= Brinkmann <soren.brinkmann@xilinx.com>
Cc: PINTU KUMAR <pintu_agarwal@yahoo.com>, Andy Whitcroft <apw@canonical.com>, anish singh <anish198519851985@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 2013-06-11 at 17:54 -0700, Soren Brinkmann wrote:
> Hi Pintu,
> 
> On Mon, Jun 10, 2013 at 11:49:00AM -0700, PINTU KUMAR wrote:
> > >________________________________
> > > From: anish singh <anish198519851985@gmail.com>
> > >To: PINTU KUMAR <pintu_agarwal@yahoo.com> 
> > >Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>; "linux-mm@kvack.org" <linux-mm@kvack.org> 
> > >Sent: Sunday, 9 June 2013 10:58 PM
> > >Subject: Re: [checkpatch] - Confusion
> > > 
> > >
> > >On Mon, Jun 10, 2013 at 11:21 AM, PINTU KUMAR <pintu_agarwal@yahoo.com> wrote:
> > >> Hi,
> > >>
> > >> I wanted to submit my first patch.
> > >> But I have some confusion about the /scripts/checkpatch.pl errors.
> > >>
> > >> After correcting some checkpatch errors, when I run checkpatch.pl, it showed me 0 errors.
> > >> But when I create patches are git format-patch, it is showing me 1 error.
> > >did  you run the checkpatch.pl on the file which gets created
> > >after git format-patch?
> > >If yes, then I think it is not necessary.You can use git-am to apply
> > >your own patch on a undisturbed file and if it applies properly then
> > >you are good to go i.e. you can send your patch.
> > 
> > Yes, first I ran checkpatch directly on the file(mm/page_alloc.c) and fixed all the errors.
> > It showed me (0) errors.
> > Then I created a patch using _git format-patch_ and ran checkpatch again on the created patch.
> > But now it is showing me 1 error.
> > According to me this error is false positive (irrelevant), because I did not change anything related to the error and also the similar change already exists somewhere else too.
> > Do you mean, shall I go ahead and submit the patch with this 1 error??
> > ERROR: need consistent spacing around '*' (ctx:WxV)
> > 
> > #153: FILE: mm/page_alloc.c:5476:
> > +int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
> Rather a shot into the dark, but it looks like checkpatch is
> misinterpreting 'ctl_table' as an arithmetic operand instead of a type.
> I don't know how checkpatch learns about types created by typedefs, but
> my guess is, that this line
> 	typedef struct ctl_table ctl_table; (include/linux/sysctl.h)
> is not correctly picked up by checkpatch.

checkpatch isn't a c compiler.
It assumes any <foo>_t is a typedef.

> So, I assume this actually is a false positive.

Yup.

Maybe this would work?
---
 scripts/checkpatch.pl | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index b954de5..e673bec 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -264,7 +264,7 @@ our $UTF8	= qr{
 
 our $typeTypedefs = qr{(?x:
 	(?:__)?(?:u|s|be|le)(?:8|16|32|64)|
-	atomic_t
+	atomic_t|ctl_table
 )};
 
 our $logFunctions = qr{(?x:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
