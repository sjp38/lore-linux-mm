Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9DAB28D0039
	for <linux-mm@kvack.org>; Sun,  6 Feb 2011 11:02:56 -0500 (EST)
Date: Sun, 6 Feb 2011 08:01:12 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH -mmotm] staging/easycap: fix build when SND is not
 enabled
Message-Id: <20110206080112.22f858e6.randy.dunlap@oracle.com>
In-Reply-To: <AANLkTikt=Ytey-n-YYGuXzJWNprEb-_zjuP5YjJGuvgK@mail.gmail.com>
References: <201102042349.p14NnQEm025834@imap1.linux-foundation.org>
	<20110205093632.b76be846.randy.dunlap@oracle.com>
	<AANLkTikt=Ytey-n-YYGuXzJWNprEb-_zjuP5YjJGuvgK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tomas Winkler <tomasw@gmail.com>
Cc: akpm@linux-foundation.org, rmthomas@sciolus.org, driverdevel <devel@driverdev.osuosl.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 6 Feb 2011 09:25:28 +0200 Tomas Winkler wrote:

> On Sat, Feb 5, 2011 at 7:36 PM, Randy Dunlap <randy.dunlap@oracle.com> wrote:
> > From: Randy Dunlap <randy.dunlap@oracle.com>
> >
> > Fix easycap build when CONFIG_SOUND is enabled but CONFIG_SND is
> > not enabled.
> >
> > These functions are only built when CONFIG_SND is enabled, so the
> > driver should depend on SND.
> > This means that having SND enabled is required for the (obsolete)
> > EASYCAP_OSS config option.
> 
> Actually SND enabled is needed when EASYCAP_OSS is NOT set.

I suspected that might be the case.

> I'm not sure, though how to force it in Kconfig,
> I didn't want to use choice ALSA, OSS as the OSS will be removed later.
> 
> Unfortunately I cannot do something like
> if EASYCAP_OSS == n
>     select SND
> endif

You can do
	select SND if !EASYCAP_OSS
but that may be too late or in the wrong location.

> I will try to come with proper fix

Thanks.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
