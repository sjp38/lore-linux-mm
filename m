Message-ID: <46E97125.8080302@google.com>
Date: Thu, 13 Sep 2007 10:19:33 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 4/5] Mem Policy:  cpuset-independent interleave	policy
References: <20070830185053.22619.96398.sendpatchset@localhost>	 <20070830185122.22619.56636.sendpatchset@localhost>	 <46E86148.9060400@google.com> <1189690357.5013.19.camel@localhost>
In-Reply-To: <1189690357.5013.19.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, clameter@sgi.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn wrote:
> On Wed, 2007-09-12 at 14:59 -0700, Ethan Solomita wrote:
>> 	Just one code note:
>>
>> Lee Schermerhorn wrote:
>>> -		return nodes_equal(a->v.nodes, b->v.nodes);
>>> +		return a->policy & MPOL_CONTEXT ||
>>> +			nodes_equal(a->v.nodes, b->v.nodes);
>> 	For the sake of my sanity, can we add () around a->policy & 
>> MPOL_CONTEXT? 8-) This falls into order of precedence that I don't trust 
>> myself to memorize.
> 
> I agree and I would have done that, but then someone would have dinged
> me for "unneeded parentheses"--despite the fact that I can't find
> anything in the style guide about this [except in the bit about macro
> definitions that says to always add parentheses around expressions
> defining constants].  Can't win for losin' :-(.

	Don't despair! :-)

	You could do:

#if CONFIG_ILIKEPARENTHESIS
	return (a->policy & MPOL_CONTEXT) ||
#else
	return a->policy & MPOL_CONTEXT ||
#endif

	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
