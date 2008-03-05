Date: Wed, 5 Mar 2008 06:17:54 -0600
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 2/2] Cpuset hardwall flag:  Add a mem_hardwall flag to
 cpusets
Message-Id: <20080305061754.61133079.pj@sgi.com>
In-Reply-To: <20080305080000.432133000@menage.corp.google.com>
References: <20080305075237.608599000@menage.corp.google.com>
	<20080305080000.432133000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: menage@google.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul M wrote:
> This flag provides the hardwalling properties of mem_exclusive,
> without enforcing the exclusivity. Either mem_hardwall or ...

Acked-by: Paul Jackson <pj@sgi.com>

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
