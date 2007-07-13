Date: Fri, 13 Jul 2007 14:38:38 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 5/5] [hugetlb] Try to grow pool for MAP_SHARED mappings
Message-Id: <20070713143838.02c3fa95.pj@sgi.com>
In-Reply-To: <1184360742.16671.55.camel@localhost.localdomain>
References: <20070713151621.17750.58171.stgit@kernel>
	<20070713151717.17750.44865.stgit@kernel>
	<20070713130508.6f5b9bbb.pj@sgi.com>
	<1184360742.16671.55.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, apw@shadowen.org, wli@holomorphy.com, clameter@sgi.com, kenchen@google.com
List-ID: <linux-mm.kvack.org>

Adam wrote:
> To be honest, I just don't think a global hugetlb pool and cpusets are
> compatible, period.

It's not an easy fit, that's for sure ;).

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
