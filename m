Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 61CBF900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 11:32:39 -0400 (EDT)
Message-ID: <4E035C8B.1080905@draigBrady.com>
Date: Thu, 23 Jun 2011 16:32:27 +0100
From: =?ISO-8859-15?Q?P=E1draig_Brady?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: Re: sandy bridge kswapd0 livelock with pagecache
References: <20110621103920.GF9396@suse.de> <4E0076C7.4000809@draigBrady.com> <20110621113447.GG9396@suse.de> <4E008784.80107@draigBrady.com> <20110621130756.GH9396@suse.de> <4E00A96D.8020806@draigBrady.com> <20110622094401.GJ9396@suse.de> <4E01C19F.20204@draigBrady.com> <20110623114646.GM9396@suse.de> <4E0339CF.8080407@draigBrady.com> <20110623152418.GN9396@suse.de>
In-Reply-To: <20110623152418.GN9396@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org

On 23/06/11 16:24, Mel Gorman wrote:
> 
> Theory 2 it is then. This is to be applied on top of the patch for
> theory 1.
> 
> ==== CUT HERE ====
> mm: vmscan: Prevent kswapd doing excessive work when classzone is unreclaimable

No joy :(

cheers,
Padraig.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
