Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C57318D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 13:06:40 -0400 (EDT)
Message-ID: <4D878564.6080608@fiec.espol.edu.ec>
Date: Mon, 21 Mar 2011 12:05:40 -0500
From: =?ISO-8859-15?Q?Alex_Villac=ED=ADs_Lasso?=
 <avillaci@fiec.espol.edu.ec>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
References: <20110316150208.7407c375.akpm@linux-foundation.org> <4D827CC1.4090807@fiec.espol.edu.ec> <20110317144727.87a461f9.akpm@linux-foundation.org> <20110318111300.GF707@csn.ul.ie> <4D839EDB.9080703@fiec.espol.edu.ec> <20110319134628.GG707@csn.ul.ie> <4D84D3F2.4010200@fiec.espol.edu.ec> <20110319235144.GG10696@random.random> <20110321094149.GH707@csn.ul.ie> <20110321134832.GC5719@random.random> <20110321163742.GA24244@csn.ul.ie>
In-Reply-To: <20110321163742.GA24244@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

El 21/03/11 11:37, Mel Gorman escribio:
> On Mon, Mar 21, 2011 at 02:48:32PM +0100, Andrea Arcangeli wrote:
>
> Nothing bad jumped out at me. Lets see how it gets on with testing.
>
> Thanks
>
As with the previous patch, this one did not completely solve the freezing tasks issue. However, as with the previous patch, the freezes took longer to appear, and now lasted less (10 to 12 seconds instead of freezing until the end of the usb copy).

I have attached the new sysrq-w trace to the bug report.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
