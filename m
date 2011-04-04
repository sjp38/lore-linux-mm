Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DC8CE8D003B
	for <linux-mm@kvack.org>; Mon,  4 Apr 2011 11:38:59 -0400 (EDT)
Message-ID: <4D99E5C8.7090505@fiec.espol.edu.ec>
Date: Mon, 04 Apr 2011 10:37:44 -0500
From: =?ISO-8859-1?Q?Alex_Villac=ED=ADs_Lasso?=
 <avillaci@fiec.espol.edu.ec>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 31142] New: Large write to USB stick freezes
 unrelated tasks for a long time
References: <20110319235144.GG10696@random.random> <20110321094149.GH707@csn.ul.ie> <20110321134832.GC5719@random.random> <20110321163742.GA24244@csn.ul.ie> <4D878564.6080608@fiec.espol.edu.ec> <20110321201641.GA5698@random.random> <20110322112032.GD24244@csn.ul.ie> <20110322150314.GC5698@random.random> <4D8907C2.7010304@fiec.espol.edu.ec> <20110322214020.GD5698@random.random> <20110323003718.GH5698@random.random> <4D8A2517.3090403@fiec.espol.edu.ec>
In-Reply-To: <4D8A2517.3090403@fiec.espol.edu.ec>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, avillaci@ceibo.fiec.espol.edu.ec, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org

Latest update: with 2.6.39-rc1 the stalls only last for a few seconds, but they are still there. So, as I said before, they are reduced but not eliminated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
