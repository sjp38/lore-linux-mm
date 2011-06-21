Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 27C016B017B
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 06:51:52 -0400 (EDT)
Message-ID: <4E0076C7.4000809@draigBrady.com>
Date: Tue, 21 Jun 2011 11:47:35 +0100
From: =?ISO-8859-15?Q?P=E1draig_Brady?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: Re: sandy bridge kswapd0 livelock with pagecache
References: <4E0069FE.4000708@draigBrady.com> <20110621103920.GF9396@suse.de>
In-Reply-To: <20110621103920.GF9396@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org

On 21/06/11 11:39, Mel Gorman wrote:
> On Tue, Jun 21, 2011 at 10:53:02AM +0100, P?draig Brady wrote:
>> I tried the 2 patches here to no avail:
>> http://marc.info/?l=linux-mm&m=130503811704830&w=2
>>
>> I originally logged this at:
>> https://bugzilla.redhat.com/show_bug.cgi?id=712019
>>
>> I can compile up and quickly test any suggestions.
>>
> 
> I recently looked through what kswapd does and there are a number
> of problem areas. Unfortunately, I haven't gotten around to doing
> anything about it yet or running the test cases to see if they are
> really problems. In your case, the following is a strong possibility
> though. This should be applied on top of the two patches merged from
> that thread.
> 
> This is not tested in any way, based on 3.0-rc3

This does not fix the issue here.

cheers,
Padraig.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
