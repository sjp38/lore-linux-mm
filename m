Date: Fri, 23 May 2003 07:32:31 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.5.69-mm8
Message-ID: <26160000.1053700350@[10.10.2.4]>
In-Reply-To: <1053673399.1547.27.camel@nighthawk>
References: <20030522021652.6601ed2b.akpm@digeo.com> <17990000.1053670694@[10.10.2.4]> <1053673399.1547.27.camel@nighthawk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>       1004     2.0% default_idle
>>        272     8.3% __copy_from_user_ll
>>        129     1.7% __d_lookup
>>         79     7.5% link_path_walk
> 
> I have to wonder if these are cache effects, or just noise.  Can you
> give oprofile a try with one of the cache performance counters?

No, but you can ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
