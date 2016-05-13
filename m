Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id A53006B007E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 04:44:45 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id tb5so25032978lbb.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 01:44:45 -0700 (PDT)
Received: from smtp2-g21.free.fr (smtp2-g21.free.fr. [212.27.42.2])
        by mx.google.com with ESMTPS id g198si2577913wmd.58.2016.05.13.01.44.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 01:44:44 -0700 (PDT)
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net>
 <20160513080458.GF20141@dhcp22.suse.cz>
From: Mason <slash.tmp@free.fr>
Message-ID: <573593EE.6010502@free.fr>
Date: Fri, 13 May 2016 10:44:30 +0200
MIME-Version: 1.0
In-Reply-To: <20160513080458.GF20141@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Sebastian Frias <sf84@laposte.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 13/05/2016 10:04, Michal Hocko wrote:

> On Tue 10-05-16 13:56:30, Sebastian Frias wrote:
> [...]
>> NOTE: I understand that the overcommit mode can be changed dynamically thru
>> sysctl, but on embedded systems, where we know in advance that overcommit
>> will be disabled, there's no reason to postpone such setting.
> 
> To be honest I am not particularly happy about yet another config
> option. At least not without a strong reason (the one above doesn't
> sound that way). The config space is really large already.
> So why a later initialization matters at all? Early userspace shouldn't
> consume too much address space to blow up later, no?

One thing I'm not quite clear on is: why was the default set
to over-commit on?

I suppose the biggest use-case is when a "large" process forks
only to exec microseconds later into a "small" process, it would
be silly to refuse that fork. But isn't that what the COW
optimization addresses, without the need for over-commit?

Another issue with overcommit=on is that some programmers seem
to take for granted that "allocations will never fail" and so
neglect to handle malloc == NULL conditions gracefully.

I tried to run LTP with overcommit off, and I vaguely recall that
I had more failures than with overcommit on. (Perhaps only those
tests that tickle the dreaded OOM assassin.)

Regards.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
