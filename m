Date: Fri, 18 Nov 2005 16:10:34 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC][PATCH 0/8] Critical Page Pool
Message-Id: <20051118161034.4ea38a09.pj@sgi.com>
In-Reply-To: <437E3CC2.6000003@argo.co.il>
References: <437E2C69.4000708@us.ibm.com>
	<437E2F22.6000809@argo.co.il>
	<437E30A8.1040307@us.ibm.com>
	<437E3CC2.6000003@argo.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@argo.co.il>
Cc: colpatch@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Avi wrote:
> This may not be possible. What if subsystem A depends on subsystem B to 
> do its work, both are critical, and subsystem A allocated all the memory 
> reserve?

Apparently Matthew's subsystems have some knowable upper limits on
their critical memory needs, so that your scenario can be avoided.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
