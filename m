Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA10431
	for <linux-mm@kvack.org>; Wed, 9 Oct 2002 15:51:16 -0700 (PDT)
Message-ID: <3DA4B2E3.4FB3BC52@digeo.com>
Date: Wed, 09 Oct 2002 15:51:15 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2.5.41-mm1] new snapshot of shared page tables
References: <228900000.1034197657@baldur.austin.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave McCracken wrote:
> 
> with the added feature that shared page tables are now a config option.

Good idea, that.   The ppc64 guys (guy) don't actually want the feature,
and it significantly de-risks things.  Although it's one more datapoint
to be gathered when pondering oops reports.

Stylistic trivia: When stubbing out a function it's cleaner (and faster)
to do:

#ifdef CONFIG_FOO
int my_function(arg1, arg2)
{
	...
}
#else
static inline int my_function(arg1, arg2)
{
	return 0;
}
#endif

Do we have any performance numbers on this yet?  Both for speed
and space?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
