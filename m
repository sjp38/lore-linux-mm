Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 5D3676B004D
	for <linux-mm@kvack.org>; Sun,  4 Mar 2012 19:46:37 -0500 (EST)
Received: by obbta14 with SMTP id ta14so4362424obb.14
        for <linux-mm@kvack.org>; Sun, 04 Mar 2012 16:46:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CABv5NL-SquBQH8W+K1CXNBQQWqHyYO+p3Y9sPqsbfZKp5EafTg@mail.gmail.com>
References: <CABv5NL-SquBQH8W+K1CXNBQQWqHyYO+p3Y9sPqsbfZKp5EafTg@mail.gmail.com>
Date: Mon, 5 Mar 2012 01:46:36 +0100
Message-ID: <CABv5NL-tAH3ph7UD5s77=ib_po+zp0XssLsf-ZqbPr2ZgZKOWg@mail.gmail.com>
Subject: Fwd: (un)loadable module support for zcache
From: Ilendir <ilendir@googlemail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: ngupta@vflare.org

While experimenting with zcache on various systems, we discovered what
seems to be a different impact on CPU and power consumption, varying
from system to system and workload. While there has been some research
effort about the effect of on-line memory compression on power
consumption [1], the trade-off, for example when using SSDs or on
mobile platforms (e.g. Android), remains still unclear. Therefore it
would be desirable to improve the possibilities to study this effects
on the example of zcache. But zcache is missing an important feature:
dynamic disabling and enabling. This is a big obstacle for further
analysis.
Since we have to do some free-to-choose work on a Linux related topic
while doing an internship at the University in Erlangen, we'd like to
implement this feature.

Moreover, if we achieve our goal, the way to an unloadable zcache
module isn=92t far way. If that is accomplished, one of the blockers to
get zcache out of the staging tree is gone.

Any advice is appreciated.

Florian Schmaus
Stefan Hengelein
Andor Daam


[1] http://ziyang.eecs.umich.edu/~dickrp/publications/yang-crames-tecs.pdf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
