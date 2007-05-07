Date: Mon, 7 May 2007 21:23:22 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC][PATCH] VM: per-user overcommit policy
Message-ID: <20070507212322.6d60210b@the-village.bc.nu>
In-Reply-To: <463F764E.5050009@users.sourceforge.net>
References: <463F764E.5050009@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: righiandr@users.sourceforge.net
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> - allow uid=1001 and uid=1002 (common users) to allocate memory only if the
>   total committed space is below the 50% of the physical RAM + the size of
>   swap:
> root@host # echo 1001:2:50 > /proc/overcommit_uid
> root@host # echo 1002:2:50 > /proc/overcommit_uid

There are some fundamental problems with this model - the moment you mix
strict overcommit with anything else it ceases to be a strict overcommit
and you might as well use existing overcommit rules for most stuff

The other thing you are sort of faking is per user resource management -
which is a subset of per group of users resource management which is
useful - eg "students can't hog the machine"

I don't see that this is the right approach compared with the container
work and openvz work that is currently active and far more flexible.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
