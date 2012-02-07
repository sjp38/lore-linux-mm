Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id DB8446B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 20:29:12 -0500 (EST)
Message-ID: <4F307EFC.5010400@redhat.com>
Date: Tue, 07 Feb 2012 09:31:40 +0800
From: Dave Young <dyoung@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] move hugepage test examples to tools/testing/selftests/vm
References: <20120205081555.GA2249@darkstar.redhat.com> <20120206155340.b9075240.akpm@linux-foundation.org>
In-Reply-To: <20120206155340.b9075240.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, penberg@kernel.org, fengguang.wu@intel.com, cl@linux.com, Frederic Weisbecker <fweisbec@gmail.com>

On 02/07/2012 07:53 AM, Andrew Morton wrote:

> On Sun, 5 Feb 2012 16:15:55 +0800
> Dave Young <dyoung@redhat.com> wrote:
> 
>> hugepage-mmap.c, hugepage-shm.c and map_hugetlb.c in Documentation/vm are
>> simple pass/fail tests, It's better to promote them to tools/testing/selftests
>>
>> Thanks suggestion of Andrew Morton about this. They all need firstly setting up
>> proper nr_hugepages and hugepage-mmap need to mount hugetlbfs. So I add a shell
>> script run_test to do such work which will call the three test programs and
>> check the return value of them.
>>
>> Changes to original code including below:
>> a. add run_test script
>> b. return error when read_bytes mismatch with writed bytes.
>> c. coding style fixes: do not use assignment in if condition
>>
> 
> I think Frederic is doing away with tools/testing/selftests/run_tests
> in favour of a Makefile target?  ("make run_tests", for example).

>

> Until we see such a patch we cannot finalise your patch and if I apply
> your patch, his patch will need more work.  Not that this is rocket
> science ;)


Understand.

> 
>>
>> ...
>>
>> --- /dev/null
>> +++ b/tools/testing/selftests/vm/run_test
> 
> (We now have a "run_tests" and a "run_test".  The difference in naming
> is irritating)


Yes, I'm just refer to the breakpoints/Makefile which will make a target
breakpoints/run_test

> 
> Your vm/run_test file does quite a lot of work and we couldn't sensibly
> move all its functionality into Makefile, I expect.
> 
> So I think it's OK to retain a script for this, but I do think that we
> should think up a standardized way of invoking it from vm/Makefile, so
> the top-level Makefile in tools/testing/selftests can simply do "cd
> vm;make run_test", where the run_test target exists in all
> subdirectories.  The vm/Makefile run_test target can then call out to
> the script.


Frederic, do you have any idea about this?

> 
> Also, please do not assume that the script has the x bit set.  The x
> bit easily gets lost on kernel scripts (patch(1) can lose it) so it is
> safer to invoke the script via "/bin/sh script-name" or $SHELL or
> whatever.


Agree, and quilt can not keep the x bit as well, I have to use git to
create a executable shell script

> 
> Anyway, we should work with Frederic on sorting out some standard
> behavior before we can finalize this work, please.
> 


Fine, I can redo this after the standard behavior is out

-- 
Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
