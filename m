Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id A2FCE6B002B
	for <linux-mm@kvack.org>; Tue, 25 Dec 2012 21:56:39 -0500 (EST)
Message-ID: <50DA670C.4050704@redhat.com>
Date: Wed, 26 Dec 2012 10:55:08 +0800
From: Zhouping Liu <zliu@redhat.com>
MIME-Version: 1.0
Subject: Re: kernel BUG at mm/huge_memory.c:1798!
References: <1621091901.34838094.1356409676820.JavaMail.root@redhat.com> <535932623.34838584.1356410331076.JavaMail.root@redhat.com> <CAJd=RBB9Tqv9c_Wv+N8yJOftfkJeUS10vLuz14eoLH1eEtjmBQ@mail.gmail.com>
In-Reply-To: <CAJd=RBB9Tqv9c_Wv+N8yJOftfkJeUS10vLuz14eoLH1eEtjmBQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Johannes Weiner <jweiner@redhat.com>, mgorman@suse.de, hughd@google.com, Andrea Arcangeli <aarcange@redhat.com>

On 12/25/2012 08:05 PM, Hillf Danton wrote:
> On Tue, Dec 25, 2012 at 12:38 PM, Zhouping Liu <zliu@redhat.com> wrote:
>> Hello all,
>>
>> I found the below kernel bug using latest mainline(637704cbc95),
>> my hardware has 2 numa nodes, and it's easy to reproduce the issue
>> using LTP test case: "# ./mmap10 -a -s -c 200":
> Can you test with 5a505085f0 and 4fc3f1d66b1 reverted?

Hello Hillf, I tested it with 5a505085f0 and 4fc3f1d66b1 reverted, you 
are right, the issue is gone.

Thanks,
Zhouping

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
