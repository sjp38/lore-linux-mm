Date: Tue, 17 Sep 2002 14:58:41 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [Lse-tech] Re: Examining the Performance and Cost of Revesema	ps on 2.5.26 Under  Heavy DBWorkload
Message-ID: <130970000.1032299921@flay>
In-Reply-To: <20020917214753.GA2179@holomorphy.com>
References: <39B5C4829263D411AA93009027AE9EBB13299719@fmsmsx35.fm.intel.com> <129560000.1032298951@flay> <20020917214753.GA2179@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andrew Morton <akpm@digeo.com>, Peter Wong <wpeter@us.ibm.com>, linux-mm@kvack.org, lse-tech@lists.sourceforge.net, riel@nl.linux.org, dmccr@us.ibm.com, gh@us.ibm.com, Bill Hartner <bhartner@us.ibm.com>, Troy C Wilson <wilsont@us.ibm.com>
List-ID: <linux-mm.kvack.org>

>>> Can't you use LD_PRELOAD tricks to sneak a different version shmget/shmat
>>> to your DB2 binary so that you can intercept the important calls and
>>> divert them to use huge tlb pages?
> 
> On Tue, Sep 17, 2002 at 02:42:31PM -0700, Martin J. Bligh wrote:
>> If we had a shmget/shmat call that supported large pages, that would 
>> probably make it easier ? ;-) That's the whole issue - large pages aren't
>> supported with standard syscalls, so every app is required to rewrite their
>> memory handling, which isn't going to happen.
>> M.
> 
> The pressure on this never lets up. It's being done, though I can't say
> I'm entirely happy with how quickly/slowly I'm getting it done myself.

Sorry, I wasn't trying to harrass you - was trying to emphasize how important
it is that this gets accepted once it's complete.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
