Date: Mon, 25 Jun 2007 14:10:31 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH/RFC 10/11] Shared Policy: per cpuset shared file policy
 control
Message-Id: <20070625141031.904935b5.pj@sgi.com>
In-Reply-To: <20070625195335.21210.82618.sendpatchset@localhost>
References: <20070625195224.21210.89898.sendpatchset@localhost>
	<20070625195335.21210.82618.sendpatchset@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Lee wrote:
> +#ifdef CONFIG_NUMA

Hmmm ... our very first ifdef CONFIG_NUMA in kernel/cpuset.c,
and the second ifdef ever in that file.  (And I doubt that
the first ifdef, on CONFIG_MEMORY_HOTPLUG, is necessary.)

How about we just remove these ifdef CONFIG_NUMA's, and
let that per-cpuset 'shared_file_policy' always be present?
It just won't do a heck of a lot on non-NUMA systems.

No sense in breaking code that happens to access that file,
just because we're running on a system where it's useless.
It seems better to just simply, consistently, always have
that file present.

And I don't like ifdef's in kernel/cpuset.c.  If necessary,
put them in some header file, related to whatever piece of
code has to shrink down to nothingness when not configured.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
