Date: Fri, 27 Sep 2002 21:36:55 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.38-mm3
Message-ID: <20020928043655.GU3530@holomorphy.com>
References: <20020927152833.D25021@in.ibm.com> <Pine.LNX.4.44.0209280034101.32347-100000@montezuma.mastecende.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0209280034101.32347-100000@montezuma.mastecende.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zwane Mwaikambo <zwane@linuxpower.ca>
Cc: Dipankar Sarma <dipankar@in.ibm.com>, Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Fri, 27 Sep 2002, Dipankar Sarma wrote:
>> The counts are off by one.
>> With a UP kernel, I see that fget() cost is negligible.
>> So it is most likely the atomic operations for rwlock acquisition/release
>> in fget() that is adding to its cost. Unless of course my sampling
>> is too less.

On Sat, Sep 28, 2002 at 12:35:30AM -0400, Zwane Mwaikambo wrote:
> Mine is a UP box not an SMP kernel, although preempt is enabled;
> 0xc013d370 <fget>:      push   %ebx
> 0xc013d371 <fget+1>:    mov    %eax,%ecx
> 0xc013d373 <fget+3>:    mov    $0xffffe000,%edx
> 0xc013d378 <fget+8>:    and    %esp,%edx
> 0xc013d37a <fget+10>:   incl   0x4(%edx)

Do you have instruction-level profiles to show where the cost is on UP?


Thanks,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
