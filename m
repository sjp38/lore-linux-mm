Subject: Re: 2.5.69-mm8
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <17990000.1053670694@[10.10.2.4]>
References: <20030522021652.6601ed2b.akpm@digeo.com>
	 <17990000.1053670694@[10.10.2.4]>
Content-Type: text/plain
Message-Id: <1053673399.1547.27.camel@nighthawk>
Mime-Version: 1.0
Date: 23 May 2003 00:03:20 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2003-05-22 at 23:18, Martin J. Bligh wrote:
>       1004     2.0% default_idle
>        272     8.3% __copy_from_user_ll
>        129     1.7% __d_lookup
>         79     7.5% link_path_walk

I have to wonder if these are cache effects, or just noise.  Can you
give oprofile a try with one of the cache performance counters?

-- 
Dave Hansen
haveblue@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
