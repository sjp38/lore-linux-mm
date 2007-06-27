Date: Wed, 27 Jun 2007 13:36:35 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH/RFC 10/11] Shared Policy: per cpuset shared file policy
 control
Message-Id: <20070627133635.9eae8ee4.pj@sgi.com>
In-Reply-To: <1182975731.6539.3.camel@localhost>
References: <20070625195224.21210.89898.sendpatchset@localhost>
	<20070625195335.21210.82618.sendpatchset@localhost>
	<20070625141031.904935b5.pj@sgi.com>
	<1182965584.4948.13.camel@localhost>
	<20070627125242.f195b5ce.pj@sgi.com>
	<1182975731.6539.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

> The resulting #ifdefs will be in the header.  Are
> you "OK" with that?

Yes - headers are the right place for this.

No need to re-release your patch set just for this;
I'll be quite happy if it makes your next round.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
