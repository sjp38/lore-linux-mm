Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 34DDA6B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 02:56:52 -0400 (EDT)
Date: Wed, 14 Mar 2012 09:59:04 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: RCU stalls in linux-next
Message-ID: <20120314065904.GA3220@mwanda>
References: <20120313134822.GA5158@elgon.mountain>
 <20120313143327.GA2349@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="opJtzjQTFsWo+cga"
Content-Disposition: inline
In-Reply-To: <20120313143327.GA2349@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

I get these on my netbook as well if I run it for long enough.  I
just read email on that and do the occasional git pull.

regards,
dan carpenter

[ 3906.306118] eth0: no IPv6 routers present
[58395.111474] apt-get used greatest stack depth: 4032 bytes left
[231179.224907] apt-get used greatest stack depth: 3632 bytes left
[491541.321011] INFO: rcu_sched self-detected stall on CPU { 0}  (t=60000 jiffies)
[491541.321011] Pid: 576, comm: kswapd0 Not tainted 3.3.0-rc4-next-20120222+ #129
[491541.321011] Call Trace:
[491541.321011]  <IRQ>  [<ffffffff810ab6ea>] __rcu_pending+0x19a/0x4d0
[491541.321011]  [<ffffffff8106b1dc>] ? trigger_load_balance+0x5c/0x2e0
[491541.321011]  [<ffffffff810abd50>] rcu_check_callbacks+0xb0/0x1a0
[491541.321011]  [<ffffffff81043f73>] update_process_times+0x43/0x80
[491541.321011]  [<ffffffff8107e8cf>] tick_sched_timer+0x5f/0xb0
[491541.321011]  [<ffffffff81058c58>] __run_hrtimer+0x78/0x1d0
[491541.321011]  [<ffffffff8107e870>] ? tick_nohz_handler+0xf0/0xf0
[491541.321011]  [<ffffffff8103baa1>] ? __do_softirq+0xf1/0x210
[491541.321011]  [<ffffffff81059583>] hrtimer_interrupt+0xe3/0x200
[491541.321011]  [<ffffffff8170880c>] ? call_softirq+0x1c/0x30
[491541.321011]  [<ffffffff8101f564>] smp_apic_timer_interrupt+0x64/0xa0
[491541.321011]  [<ffffffff81707ecb>] apic_timer_interrupt+0x6b/0x70
[491541.321011]  <EOI>  [<ffffffff810d8203>] ? zone_watermark_ok_safe+0xe3/0x170
[491541.321011]  [<ffffffff810e6de8>] balance_pgdat+0x1a8/0x690
[491541.321011]  [<ffffffff810e7438>] kswapd+0x168/0x3f0
[491541.321011]  [<ffffffff816fea26>] ? __schedule+0x3a6/0x750
[491541.321011]  [<ffffffff810553a0>] ? add_wait_queue+0x60/0x60
[491541.321011]  [<ffffffff810e72d0>] ? balance_pgdat+0x690/0x690
[491541.321011]  [<ffffffff8105496e>] kthread+0x8e/0xa0
[491541.321011]  [<ffffffff81708714>] kernel_thread_helper+0x4/0x10
[491541.321011]  [<ffffffff810548e0>] ? kthread_freezable_should_stop+0x70/0x70
[491541.321011]  [<ffffffff81708710>] ? gs_change+0xb/0xb
[491721.324004] INFO: rcu_sched self-detected stall on CPU { 0}  (t=240003 jiffies)
[491721.324004] Pid: 576, comm: kswapd0 Not tainted 3.3.0-rc4-next-20120222+ #129
[491721.324004] Call Trace:
[491721.324004]  <IRQ>  [<ffffffff810ab6ea>] __rcu_pending+0x19a/0x4d0
[491721.324004]  [<ffffffff8106b1dc>] ? trigger_load_balance+0x5c/0x2e0
[491721.324004]  [<ffffffff810abd50>] rcu_check_callbacks+0xb0/0x1a0
[491721.324004]  [<ffffffff81043f73>] update_process_times+0x43/0x80
[491721.324004]  [<ffffffff8107e8cf>] tick_sched_timer+0x5f/0xb0
[491721.324004]  [<ffffffff81058c58>] __run_hrtimer+0x78/0x1d0
[491721.324004]  [<ffffffff8107e870>] ? tick_nohz_handler+0xf0/0xf0
[491721.324004]  [<ffffffff8103baa1>] ? __do_softirq+0xf1/0x210
[491721.324004]  [<ffffffff81059583>] hrtimer_interrupt+0xe3/0x200
[491721.324004]  [<ffffffff8170880c>] ? call_softirq+0x1c/0x30
[491721.324004]  [<ffffffff8101f564>] smp_apic_timer_interrupt+0x64/0xa0
[491721.324004]  [<ffffffff81707ecb>] apic_timer_interrupt+0x6b/0x70
[491721.324004]  <EOI>  [<ffffffff810d812d>] ? zone_watermark_ok_safe+0xd/0x170
[491721.324004]  [<ffffffff810e6de8>] balance_pgdat+0x1a8/0x690
[491721.324004]  [<ffffffff810e7438>] kswapd+0x168/0x3f0
[491721.324004]  [<ffffffff816fea26>] ? __schedule+0x3a6/0x750
[491721.324004]  [<ffffffff810553a0>] ? add_wait_queue+0x60/0x60
[491721.324004]  [<ffffffff810e72d0>] ? balance_pgdat+0x690/0x690
[491721.324004]  [<ffffffff8105496e>] kthread+0x8e/0xa0
[491721.324004]  [<ffffffff81708714>] kernel_thread_helper+0x4/0x10
[491721.324004]  [<ffffffff810548e0>] ? kthread_freezable_should_stop+0x70/0x70
[491721.324004]  [<ffffffff81708710>] ? gs_change+0xb/0xb
[491901.327003] INFO: rcu_sched self-detected stall on CPU { 0}  (t=420006 jiffies)


--opJtzjQTFsWo+cga
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPYEG3AAoJEOnZkXI/YHqRY+IP/jwWYrSLL37SY4UBaijc9pto
3OzVyaNqpdQ6Dt/y6iGRnPnmOkQclco4HdEwDDdImFvxifWr8fLp61p1Q0EZk9V0
anuICWVPRCE/51328+FEUnsNJaEG6UWgqRaTw1df27xpnlIsXPSQd6WwRkgzDzFc
WZxJSf8130nnmWGhlAZ9qypoFlJ2d6Rl8bSyFFC1XJn4R5RtAaQMAp4o//g/xBuW
EqN9CSD7Z0GSD9Mys1TEoRm9MuZxvzqSGRsRO+84w7P6eBO3qw9hIOQsYKMBfLRC
gIgPtK7fxf24mAgLFz2P2hUMA7ncNr7QbuZKRbM+EPSRQzp8Z6VTp+IFODW1qX9m
Jy/WypB5G/5x/vYyj86PqZ6VR8llDXpPRKxaYD9jb6IymJ8fX5CLKQEiz8j/h3UI
v2ZMxNMiGufnVkH0VJudtCd5a1pLIlp4iSq9FUb5iyAruWAi2YQ8aOjfuWMY7TQA
LYnnPXg97ThxdP8Z+G3LqhCQT3jp7TvZr/C5lmgGOTE3MLgA+Jt7XvxYea1cVcQh
QBaP49vzDMuhN2cmGNiVUUBA9NGOZ270XpOxNItC7+QxUW/poU/5ik+FCH0l0OwJ
R22G7QtZnXAe7jHQ05+wIj7KIHjxbxEDD+YUPMZMTlA7uLPr5a7nFljbOmoRDENX
EBTyDrLZRG4ZHYREk/Yc
=cX9e
-----END PGP SIGNATURE-----

--opJtzjQTFsWo+cga--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
