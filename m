Date: Fri, 21 Sep 2007 11:39:35 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] hotplug cpu: move tasks in empty cpusets to parent
Message-Id: <20070921113935.94a56c8c.pj@sgi.com>
In-Reply-To: <20070921164255.44676149779@attica.americas.sgi.com>
References: <20070921164255.44676149779@attica.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cliff Wickman <cpw@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Cliff wrote:
> This patch corrects a situation that occurs when one disables all the cpus
> in a cpuset.

Acked-by: Paul Jackson <pj@sgi.com>

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
