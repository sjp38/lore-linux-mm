Date: Mon, 9 Oct 2006 23:45:30 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] memory page_alloc zonelist caching speedup
Message-Id: <20061009234530.f895d5f0.pj@sgi.com>
In-Reply-To: <20061009150259.d5b87469.pj@sgi.com>
References: <20061009105451.14408.28481.sendpatchset@jackhammer.engr.sgi.com>
	<20061009105457.14408.859.sendpatchset@jackhammer.engr.sgi.com>
	<20061009111203.5dba9cbe.akpm@osdl.org>
	<20061009150259.d5b87469.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, rientjes@google.com, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

pj wrote:
> 2) Let's say you just got a sample petahertz processor from your
>    favorite CPU vendor, with 64 cores and 4 TBytes of 10 picosecond
>    RAM, all in one package.  You can built, boot and test your entire
>    distro in 4.2 seconds. 

This silly example motivates changing my one second (1 * HZ) constant
timeout on the zonelist cache to a variable, computed at boottime as a
simple minded function of bogomips or clock speed or some such.

At the (slow) rate of CPU frequency increases the last few years, we've
got a while before we need to worry about this change.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
