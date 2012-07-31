Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 83C116B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 09:07:21 -0400 (EDT)
Message-ID: <5017D882.6040007@redhat.com>
Date: Tue, 31 Jul 2012 09:07:14 -0400
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
References: <20120720134937.GG9222@suse.de> <20120720141108.GH9222@suse.de> <20120720143635.GE12434@tiehlicka.suse.cz> <20120720145121.GJ9222@suse.de> <alpine.LSU.2.00.1207222033030.6810@eggly.anvils> <50118E7F.8000609@redhat.com> <50120FA8.20409@redhat.com> <20120727102356.GD612@suse.de> <5016DC5F.7030604@redhat.com> <20120731124650.GO612@suse.de>
In-Reply-To: <20120731124650.GO612@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On 07/31/2012 08:46 AM, Mel Gorman wrote:
> On Mon, Jul 30, 2012 at 03:11:27PM -0400, Larry Woodman wrote:
>>> <SNIP>
>>> That is a surprise. Can you try your test case on 3.4 and tell us if the
>>> patch fixes the problem there? I would like to rule out the possibility
>>> that the locking rules are slightly different in RHEL. If it hits on 3.4
>>> then it's also possible you are seeing a different bug, more on this later.
>>>
>> Sorry for the delay Mel, here is the BUG() traceback from the 3.4
>> kernel with your
>> patches:
>>
>> --------------------------------------------------------------------------------------------------------------------------------------------
>> [ 1106.156569] ------------[ cut here ]------------
>> [ 1106.161731] kernel BUG at mm/filemap.c:135!
>> [ 1106.166395] invalid opcode: 0000 [#1] SMP
>> [ 1106.170975] CPU 22
>> [ 1106.173115] Modules linked in: bridge stp llc sunrpc binfmt_misc
>> dcdbas microcode pcspkr acpi_pad acpi]
>> [ 1106.201770]
> Thanks, looks very similar.
>
>> [ 1106.203426] Pid: 18001, comm: mpitest Tainted: G        W
>> 3.3.0+ #4 Dell Inc. PowerEdge R620/07NDJ2
> You say this was a 3.4 kernel but the message says 3.3. Probably not
> relevant, just interesting.
>
Oh, sorry I posted the wrong traceback.  I tested both 3.3 & 3.4 and had 
the same results.
I'll do it again and post the 3.4 traceback for you,

Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
