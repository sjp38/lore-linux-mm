Date: Mon, 11 Aug 2003 16:00:44 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.6.0-test3-mm1
Message-ID: <886340000.1060642844@flay>
In-Reply-To: <884580000.1060642229@flay>
References: <20030811113943.47e5fd85.akpm@osdl.org> <873510000.1060633024@flay> <20030811221628.GR1715@holomorphy.com> <884580000.1060642229@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> On Mon, Aug 11, 2003 at 01:17:04PM -0700, Martin J. Bligh wrote:
>>> Buggered if I know what Letext is doing there ???
>>>       6577     3.9% total
>>>       1157     0.0% Letext
>>>        937     0.0% direct_strnlen_user
>>>        748   440.0% filp_close
>>>        722    21.2% __copy_from_user_ll
>>>        610     2.6% page_remove_rmap
>>>        492   487.1% file_ra_state_init
>>>        452    12.4% find_get_page
>>>        405     7.6% __copy_to_user_ll
>>>        402    28.6% schedule
>>>        386     0.0% kpmd_ctor
>>>        348     4.4% __d_lookup
>>>        310    16.6% atomic_dec_and_lock
>>>        300   174.4% may_open
>> 
>> You can figure out what it is by reading addresses directly out of
>> /proc/profile that would correspond to it (i.e. modifying readprofile)
>> and correlating it with an area of text in a disassembled kernel.
> 
> Was more interested in which patch screwed up the profiling really ...
> I suspect someone knows already ;-)

Looks to me like all the .text.lock.foo stuff got dumped under Letext
actually .... oops. Sometime between test2-mm1 and test2-mm3, I think?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
