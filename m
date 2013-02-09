Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 7A75A6B0002
	for <linux-mm@kvack.org>; Sat,  9 Feb 2013 01:05:15 -0500 (EST)
Received: by mail-vc0-f178.google.com with SMTP id m8so2799648vcd.23
        for <linux-mm@kvack.org>; Fri, 08 Feb 2013 22:05:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5114DF05.7070702@mellanox.com>
References: <5114DF05.7070702@mellanox.com>
Date: Fri, 8 Feb 2013 22:05:14 -0800
Message-ID: <CANN689Ff6vSu4ZvHek4J4EMzFG7EjF-Ej48hJKV_4SrLoj+mCA@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Hardware initiated paging of user process pages,
 hardware access to the CPU page tables of user processes
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Roland Dreier <roland@purestorage.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Liran Liss <liranl@mellanox.com>

On Fri, Feb 8, 2013 at 3:18 AM, Shachar Raindel <raindel@mellanox.com> wrote:
> Hi,
>
> We would like to present a reference implementation for safely sharing
> memory pages from user space with the hardware, without pinning.
>
> We will be happy to hear the community feedback on our prototype
> implementation, and suggestions for future improvements.
>
> We would also like to discuss adding features to the core MM subsystem to
> assist hardware access to user memory without pinning.

This sounds kinda scary TBH; however I do understand the need for such
technology.

I think one issue is that many MM developers are insufficiently aware
of such developments; having a technology presentation would probably
help there; but traditionally LSF/MM sessions are more interactive
between developers who are already quite familiar with the technology.
I think it would help if you could send in advance a detailed
presentation of the problem and the proposed solutions (and then what
they require of the MM layer) so people can be better prepared.

And first I'd like to ask, aren't IOMMUs supposed to already largely
solve this problem ? (probably a dumb question, but that just tells
you how much you need to explain :)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
