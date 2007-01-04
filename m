Date: Thu, 4 Jan 2007 11:20:06 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] mbind: Restrict nodes to the currently allowed cpuset
Message-Id: <20070104112006.7c43e823.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0701041115220.22710@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0701041115220.22710@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: ak@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph wrote:
> Could mbind be used to set 
> up policies that are larger than the existing cpuset? Or could mbind be 
> used to set up a policy and then the cpuset would change?

My intention (hopefully the code matches this) is that mbind nodes are
constrained to fit in the cpuset.  If you ask to mbind more nodes, those
outside the cpuset are masked off.  If you later change the cpuset, then
we mask more nodes off to continue to fit in the cpuset.  If this gets us
down to an empty mbind list, then you get to use whatever memory nodes are
in your new cpuset.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
