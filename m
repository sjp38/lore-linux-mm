Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA11932
	for <linux-mm@kvack.org>; Fri, 12 Jun 1998 17:29:39 -0400
Date: Fri, 12 Jun 1998 22:29:14 +0100
Message-Id: <199806122129.WAA02233@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: patch for 2.1.102 swap code
In-Reply-To: <m167i857t1.fsf@flinx.npwt.net>
References: <356478F0.FE1C378F@star.net>
	<199805241728.SAA02816@dax.dcs.ed.ac.uk>
	<m190nq4jan.fsf@flinx.npwt.net>
	<199805262152.WAA02934@dax.dcs.ed.ac.uk>
	<m167i857t1.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 11 Jun 1998 09:31:22 -0500, ebiederm+eric@npwt.net (Eric W. Biederman) said:

>>>>>> "ST" == Stephen C Tweedie <sct@dcs.ed.ac.uk> writes:
ST> Hi,
>>> Note: there is a problem with swapoff that should at least be considered.
>>> If you use have a SYSV shared memory, and don't map it into a process,
>>> and that memory get's swapped out, swapoff will not be able to find it.

ST> Thanks; it's added to my list.

> Here is a preliminary patch that should fix the problem.

Thanks; it's queued for attention.  I'm off to Usenix tomorrow, but
I'll be doing lots and lots of VM stuff when I get back (I'm going
full time courtesy of Red Hat --- yay!), so I'll check and test and
then submit to Linus if all looks OK.

--Stephen
