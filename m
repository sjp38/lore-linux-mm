Date: Fri, 28 Jul 2006 02:06:11 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [patch 3/9] cpuset: oom panic fix
Message-Id: <20060728020611.67ad343a.pj@sgi.com>
In-Reply-To: <20060515210556.30275.63352.sendpatchset@linux.site>
References: <20060515210529.30275.74992.sendpatchset@linux.site>
	<20060515210556.30275.63352.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick wrote:
> Change to returning 0 in this case.

I think that comment is a typo, and should be instead:

> Change to returning 1 in this case.

Other than that nit:

Acked-by: Paul Jackson <pj@sgi.com>

I haven't actually seen a test case in hand for this one,
but it sure seems like "the right thing to do (tm)", and
I understand Nick has seen it fix a real problem.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
