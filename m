Date: Thu, 26 Sep 2002 05:42:44 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.38-mm3
Message-ID: <20020926124244.GO3530@holomorphy.com>
References: <3D92BE07.B6CDFE54@digeo.com> <20020926175445.B18906@in.ibm.com> <20020926122909.GN3530@holomorphy.com> <20020926181052.C18906@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020926181052.C18906@in.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dipankar Sarma <dipankar@in.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 26, 2002 at 05:29:09AM -0700, William Lee Irwin III wrote:
>> Is there an update to the files_struct stuff too? I'm seeing large
>> overheads there also.

On Thu, Sep 26, 2002 at 06:10:52PM +0530, Dipankar Sarma wrote:
> files_struct_rcu is not in mm kernels, but I will upload the most
> recent version to the same download directory in LSE.
> I would be interested in fget() profile count change with that patch.

In my experience fget() is large even on UP kernels. For instance, a UP
profile from a long-running interactive load UP box (my home machine):

228542527 total                                    169.5902
216163353 default_idle                             4503403.1875
850707 number                                   781.8998
829885 handle_IRQ_event                         8644.6354
687351 proc_getdata                             1227.4125
454401 system_call                              8114.3036
446452 csum_partial_copy_generic                1800.2097
330157 tcp_sendmsg                               76.4252
300022 vsnprintf                                284.1117
271134 __generic_copy_to_user                   3389.1750
237151 fget                                     3705.4844
222390 proc_pid_stat                            308.8750
210759 fput                                     878.1625
186408 tcp_ioctl                                314.8784
179146 sys_ioctl                                238.2261
177419 do_softirq                               1232.0764
167881 kmem_cache_free                          1165.8403
154854 skb_clone                                387.1350
149377 d_lookup                                 444.5744
139131 kmem_cache_alloc                         668.8990
138638 kfree                                    866.4875
132555 sys_write                                637.2837

This is only aggravated by cacheline bouncing on SMP. The reductions
of system cpu time will doubtless be beneficial for all.


Thanks,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
