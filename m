Date: Tue, 17 Sep 2002 14:42:31 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: RE: [Lse-tech] Re: Examining the Performance and Cost of Revesema	ps on 2.5.26 Under  Heavy DBWorkload
Message-ID: <129560000.1032298951@flay>
In-Reply-To: <39B5C4829263D411AA93009027AE9EBB13299719@fmsmsx35.fm.intel.com>
References: <39B5C4829263D411AA93009027AE9EBB13299719@fmsmsx35.fm.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Andrew Morton <akpm@digeo.com>, Peter Wong <wpeter@us.ibm.com>
Cc: linux-mm@kvack.org, lse-tech@lists.sourceforge.net, riel@nl.linux.org, wli@holomorphy.com, dmccr@us.ibm.com, gh@us.ibm.com, Bill Hartner <bhartner@us.ibm.com>, Troy C Wilson <wilsont@us.ibm.com>
List-ID: <linux-mm.kvack.org>

>> > That's a ton of memory.  Where do we stand wrt getting these
>> > applications to use large-tlb pages?
>> 
>> We need standard interfaces (like shmem) to get DB2 to port, and probably 
>> most other applications. Having magic system calls is all very well in
> theory,
>> but not much use in practice. 
>> 
>> And yes, we're still working on it.
> 
> Can't you use LD_PRELOAD tricks to sneak a different version shmget/shmat
> to your DB2 binary so that you can intercept the important calls and
> divert them to use huge tlb pages?

If we had a shmget/shmat call that supported large pages, that would 
probably make it easier ? ;-) That's the whole issue - large pages aren't
supported with standard syscalls, so every app is required to rewrite their
memory handling, which isn't going to happen.

M.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
