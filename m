Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA04189
	for <linux-mm@kvack.org>; Mon, 25 May 1998 10:33:10 -0400
Subject: Re: patch for 2.1.102 swap code
References: <356478F0.FE1C378F@star.net>
	<199805241728.SAA02816@dax.dcs.ed.ac.uk>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 25 May 1998 07:38:40 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of Sun, 24 May 1998 18:28:48 +0100
Message-ID: <m190nq4jan.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: Bill Hawes <whawes@star.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@dcs.ed.ac.uk> writes:

ST> On Thu, 21 May 1998 14:56:48 -0400, Bill Hawes <whawes@star.net> said:
>> In try_to_unuse_page there were some problems with swap counts still
>> non-zero after replacing all of the process references to a page,
>> apparently due to the swap map count being elevated while swapping is in
>> progress. (It shows up if a swapoff command is run while the system is
>> swapping heavily.) I've modified the code to make multiple passes in the
>> event that pages are still in use, and to report EBUSY if the counts
>> can't all be cleared.

ST> Hmm.  That shouldn't be a problem if everything is working correctly.
ST> However, your first change (the extra swap_duplicate) will leave the
ST> swap count elevated while swapin is occurring, and that could certainly
ST> lead to this symptom in swapoff().  Does the swapoff problem still occur
ST> on an unmodified kernel?

Note: there is a problem with swapoff that should at least be considered.
If you use have a SYSV shared memory, and don't map it into a process,
and that memory get's swapped out, swapoff will not be able to find it.

This is a very long standing bug and appears not to be a problem in practice.
But it is certainly a potential problem.

Eric
