Date: Fri, 27 Sep 2002 08:04:31 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.5.38-mm3
Message-ID: <502559422.1033113869@[10.10.2.3]>
In-Reply-To: <20020927152833.D25021@in.ibm.com>
References: <20020927152833.D25021@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: dipankar@in.ibm.com, William Lee Irwin III <wli@holomorphy.com>, Zwane Mwaikambo <zwane@linuxpower.ca>, Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> > What application were you all running ?

Kernel compile on NUMA-Q looks like this:

125673 total
82183 default_idle
6134 do_anonymous_page
4431 page_remove_rmap
2345 page_add_rmap
2288 d_lookup
1921 vm_enough_memory
1883 __generic_copy_from_user
1566 file_read_actor
1381 .text.lock.file_table           <-------------
1168 find_get_page
1116 get_empty_filp

Presumably that's the same thing? Interestingly, if I look back at 
previous results, I see it's about twice the cost in -mm as it is 
in mainline, not sure why ... at least against 2.5.37 virgin it was.

> Please try running the files_struct_rcu patch where fget() is lockfree
> and let me know what you see.

Will do ... if you tell me where it is ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
