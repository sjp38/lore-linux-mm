Subject: Re: meminfo or Rephrased helping the Programmer's help themselves...
References: <HBEHIIBBKKNOBLMPKCBBOEIKFFAA.znmeb@aracnet.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 09 Sep 2002 08:07:31 -0600
In-Reply-To: <HBEHIIBBKKNOBLMPKCBBOEIKFFAA.znmeb@aracnet.com>
Message-ID: <m1ptvnntng.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "M. Edward Borasky" <znmeb@aracnet.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"M. Edward Borasky" <znmeb@aracnet.com> writes:

> Yes, it is a high-level proposal - I adhere to the top-down philosophy of
> software design, as well as the SEI standards for software engineering
> process. One does not communicate about large software objects like the
> Linux kernel in small manageable chunks of C code in that process. 

No but you merge with people in small manageable chunks of C code.

> Perhaps
> the fact that I insist on a design specification, requirements documents,
> code reviews, etc., is the reason nobody has volunteered to join the
> project.

All you currently have is a slide show.  I see nothing that even clearly
states the problem you are trying to solve.

> I think a team of three could pull it off in six months; there isn't that
> much kernel code that has to be done. All the hooks are there in the /proc
> filesystem, they just need to be organized in a rational manner. The scheme
> Windows has for PerfMon is much better than the haphazard results in the
> /proc filesystem, which have been submitted over the years in "manageable
> chunks". The rest of Cougar is R code - R is extremely well documented - and
> database work, for which any ODBC-compliant RDB will work.

In Linux the emphasis has been a system that doesn't need tuning, for
most tasks.  So it is no surprise the tuning nobs and the monitoring
you need to apply them are underdeveloped.  They haven't been much
used or needed.  

As for your comments on an ascii text version of /proc being
inefficient, that is an assertion that needs backing up.  There are
some inefficiencies in /proc but I have not seen ascii text being the
primary problem.

And with that observation I place an extreme doubt you have the skills
to accomplish what you would like to accomplish.  

> The first task that needs to be done is to develop a high-level model of the
> Linux kernel.

You obviously are clear what you are thinking of here, but I am not.
You need a high-level model of the Linux kernel in what sense?


Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
