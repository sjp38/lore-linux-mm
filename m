Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D41A68D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 19:21:13 -0400 (EDT)
Date: Tue, 15 Mar 2011 16:19:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
Message-Id: <20110315161926.595bdb65.akpm@linux-foundation.org>
In-Reply-To: <4D7FEDDC.3020607@fiec.espol.edu.ec>
References: <bug-31142-10286@https.bugzilla.kernel.org/>
	<20110315135334.36e29414.akpm@linux-foundation.org>
	<4D7FEDDC.3020607@fiec.espol.edu.ec>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex =?ISO-8859-1?Q?Villac=ED=ADs?= Lasso <avillaci@fiec.espol.edu.ec>
Cc: avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Tue, 15 Mar 2011 17:53:16 -0500
Alex Villac____s Lasso <avillaci@fiec.espol.edu.ec> wrote:

> El 15/03/11 15:53, Andrew Morton escribi__:
> >
> > rofl, will we ever fix this.
> Does this mean there is already a duplicate of this issue? If so, which one?

Nothing specific.  Nonsense like this has been happening for at least a
decade and it never seems to get a lot better.

> > Please enable sysrq and do a sysrq-w when the tasks are blocked so we
> > can find where things are getting stuck.  Please avoid email client
> > wordwrapping when sending us the sysrq output.
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
