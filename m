Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA11775
	for <linux-mm@kvack.org>; Tue, 26 May 1998 17:52:26 -0400
Date: Tue, 26 May 1998 22:52:21 +0100
Message-Id: <199805262152.WAA02934@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: patch for 2.1.102 swap code
In-Reply-To: <m190nq4jan.fsf@flinx.npwt.net>
References: <356478F0.FE1C378F@star.net>
	<199805241728.SAA02816@dax.dcs.ed.ac.uk>
	<m190nq4jan.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@npwt.net>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, Bill Hawes <whawes@star.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

> Note: there is a problem with swapoff that should at least be considered.
> If you use have a SYSV shared memory, and don't map it into a process,
> and that memory get's swapped out, swapoff will not be able to find it.

> This is a very long standing bug and appears not to be a problem in practice.
> But it is certainly a potential problem.

Thanks; it's added to my list.

--Stephen
