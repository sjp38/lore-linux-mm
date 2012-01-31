Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 9F7BD6B002C
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 16:15:09 -0500 (EST)
Date: Tue, 31 Jan 2012 15:15:07 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: [LSF/MM TOPIC][ATTEND] Linux, give me back my processor: Memory
 management interfering with user space code
Message-ID: <alpine.DEB.2.00.1201311512340.31760@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>

Faults, reclaim, IPI's, system daemons: They all take away the processor
from the code that the user wants to run. In many areas the processing
latencies requirements are now calcualted in microseconds. The
indeterminism caused by memory management becomes a significant headache
for HPC apps that need to rendevouz in deterministic intervals or for HFT
apps that need to complete a trade ASAP.

Isnt there a way that we can get the OS out of the hair of the
applications? Maybe only temporary so that the app can process undisturbed
for some time? Or is it possible to shift processing to a dedicated
processor that is dedicated to the OS?

This becomes more severe each year as the complexity of memory management
and therefore the overhead created by OS grows.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
