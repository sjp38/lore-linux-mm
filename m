Received: from dreambringer (znmeb.cust.aracnet.com [216.99.196.115])
	(authenticated bits=0)
	by franka.aracnet.com (8.12.5/8.12.5) with ESMTP id g86DgPid021075
	for <linux-mm@kvack.org>; Fri, 6 Sep 2002 06:42:26 -0700
From: "M. Edward Borasky" <znmeb@aracnet.com>
Subject: RE: meminfo or Rephrased helping the Programmer's help themselves...
Date: Fri, 6 Sep 2002 06:44:16 -0700
Message-ID: <HBEHIIBBKKNOBLMPKCBBOEIKFFAA.znmeb@aracnet.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <Pine.LNX.4.44L.0209061010190.1857-100000@imladris.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Yes, it is a high-level proposal - I adhere to the top-down philosophy of
software design, as well as the SEI standards for software engineering
process. One does not communicate about large software objects like the
Linux kernel in small manageable chunks of C code in that process. Perhaps
the fact that I insist on a design specification, requirements documents,
code reviews, etc., is the reason nobody has volunteered to join the
project.

I think a team of three could pull it off in six months; there isn't that
much kernel code that has to be done. All the hooks are there in the /proc
filesystem, they just need to be organized in a rational manner. The scheme
Windows has for PerfMon is much better than the haphazard results in the
/proc filesystem, which have been submitted over the years in "manageable
chunks". The rest of Cougar is R code - R is extremely well documented - and
database work, for which any ODBC-compliant RDB will work.

The first task that needs to be done is to develop a high-level model of the
Linux kernel. There are numerous modeling/simulation/analysis techniques
that can be used for such models. Generalized Stochastic Petri Nets (GSPNs)
are probably the best known, and I believe a related package, DSPNExpress,
is available for Linux in an academic settings. See Christoph Lindemann's
home page at

http://ls4-www.cs.uni-dortmund.de/~Lindemann/

for the details.

M. Edward (Ed) Borasky
mailto: znmeb@borasky-research.net
http://www.pdxneurosemantics.com
http://www.meta-trading-coach.com
http://www.borasky-research.net

Coaching: It's Not Just for Athletes and Executives Any More!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
