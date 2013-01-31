Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id CE2626B0005
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 13:45:19 -0500 (EST)
Subject: next-20130128 lockdep whinge in sys_swapon()
From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1359657914_4017P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Thu, 31 Jan 2013 13:45:14 -0500
Message-ID: <5595.1359657914@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

--==_Exmh_1359657914_4017P
Content-Type: text/plain; charset=us-ascii

Seen in my linux-next dmesg.  I'm suspecting commit ac07b1ffc:

commit ac07b1ffc27d575013041fb5277dab02c661d9c2
Author: Shaohua Li <shli@kernel.org>
Date:   Thu Jan 24 13:13:50 2013 +1100

    swap: add per-partition lock for swapfile

as (a) it was OK in -20130117, and (b) 'git blame mm/swapfile.c | grep 2013'
shows that commit as the vast majority of changes.

[   42.498669] INFO: trying to register non-static key.
[   42.498670] the code is fine but needs lockdep annotation.
[   42.498671] turning off the locking correctness validator.
[   42.498674] Pid: 1035, comm: swapon Not tainted 3.8.0-rc5-next-20130128 #52
[   42.498675] Call Trace:
[   42.498681]  [<ffffffff81073dc8>] register_lock_class+0x103/0x2ad
[   42.498685]  [<ffffffff812493ad>] ? __list_add_rcu+0xc4/0xdf
[   42.498688]  [<ffffffff81075573>] __lock_acquire+0x108/0xd63
[   42.498691]  [<ffffffff810b482b>] ? trace_preempt_on+0x12/0x2f
[   42.498695]  [<ffffffff81608e6e>] ? sub_preempt_count+0x31/0x43
[   42.498699]  [<ffffffff810fda36>] ? sys_swapon+0x6f9/0x9d9
[   42.498701]  [<ffffffff810764f2>] lock_acquire+0xc7/0x14a
[   42.498703]  [<ffffffff810fda62>] ? sys_swapon+0x725/0x9d9
[   42.498706]  [<ffffffff81605023>] _raw_spin_lock+0x34/0x41
[   42.498708]  [<ffffffff810fda62>] ? sys_swapon+0x725/0x9d9
[   42.498710]  [<ffffffff810fda62>] sys_swapon+0x725/0x9d9
[   42.498712]  [<ffffffff8107520a>] ? trace_hardirqs_on_caller+0x149/0x165
[   42.498715]  [<ffffffff8160be92>] system_call_fastpath+0x16/0x1b
[   42.498719] Adding 2097148k swap on /dev/mapper/vg_blackice-swap.  Priority:-1 extents:1 across:2097148k

Somebody care to sprinkle the appropriate annotations on that code?

--==_Exmh_1359657914_4017P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBUQq7ugdmEQWDXROgAQKt3g/9F4yr/b69rt372P1tQKoIutq2R7IPJP5u
nF0InlWjs0WHvnRHMwzV8ppTtrTJ7J1f33HZbwydrTl1HzKS/GZbctNNbIgUvs84
a6XNM+2zYQmhcDndxgj5bc+hCHiO2aNS80i7gQ4NhIV7JePCWVc+mBdh3X0I0B25
2ynj8tswIYpdILOU4xGfVlTNKFipnTpKJrAtN5Ve8FLuoFOG+uUbHrg03pWjKApb
A6p64ZP7tHVy8tP10P5g0RfGucwXj0vfZHkGMHZ/ThN0wl4/Dpay0+4xfWiEosmb
ZJzPO0B9Y7JkAf6XnG3kEt5km9qt+3czyjT6GrWQRSPGEYZxw41wDI0Z+sLYCeon
x5w5bODZJUGyaUhoNTxsAtQ3U22wAzUiwycjZ3qX21q7uPUPlMQIUdcimhV2pxC1
OvltdmceUVmzpKCcbBKVPLdH7gdlwS1P6Bo4xM/DynN6D8juY3vS/gqfsIC6tIIE
wDQ/NtzO+mIGviN20lla88AvRbK2rzpyZa4fo4Ys26v0Cp0YIOcjj2Zh9e7UcJur
/1yeOrbYfUphr5Z5BXMZrx23EJthfvEmsqjdwLP2Ex0TcVVqu7Y77bqWu3h8LiVm
y08WDBoyzn4Pf2D38I/ADXl1D75j7hAonstE7Lu8+qDWwRvbL3/ZCLYCzA2JlYvv
5DNNQ1bduOo=
=qfQ8
-----END PGP SIGNATURE-----

--==_Exmh_1359657914_4017P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
