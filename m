Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 6C8508D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 06:43:23 -0400 (EDT)
Received: by dakp5 with SMTP id p5so4081583dak.14
        for <linux-mm@kvack.org>; Fri, 11 May 2012 03:43:22 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 11 May 2012 12:43:22 +0200
Message-ID: <CADLDEKu-Dt-R2-jcOEk4adE2WzK8V8a_UFhtbw4-UTr3N=wr9Q@mail.gmail.com>
Subject: General protection fault in ksmd
From: Juerg Haefliger <juergh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi,

We're running a 2.6.38 derivative (Ubuntu kernel 2.6.38-8-server) and
we're seeing quite a few of the following. Yes I know it's an old
kernel but I'm hoping that it might ring a bell with somebody who can
point me at a patch (or shed some light).


[22946.698115] general protection fault: 0000 [#1] SMP
[22946.700264] last sysfs file:
/sys/devices/system/cpu/cpu23/cache/index2/shared_cpu_map
[22946.703589] CPU 11
[22946.704437] Modules linked in: xt_comment act_police cls_u32
sch_ingress cls_fw sch_htb ebt_arp ebt_ip ipmi_devintf ipmi_si
ipmi_msghandler xt_recent xt_multiport ebtable_nat ebtables
ipt_MASQUERADE iptable_nat xt_CHECKSUM iptable_mangle bridge kvm_intel
kvm nbd 8021q garp stp ib_iser rdma_cm ib_cm iw_cm ipt_REJECT ib_sa
ib_mad ipt_LOG vesafb ib_core ib_addr xt_limit iscsi_tcp xt_tcpudp
libiscsi_tcp libiscsi ipt_addrtype scsi_transport_iscsi xt_state
ip6table_filter ip6_tables nf_nat_irc nf_conntrack_irc nf_nat_ftp
nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack_ftp nf_conntrack
iptable_filter ip_tables x_tables i7core_edac serio_raw ghes lp
edac_core hed parport xfs exportfs usbhid hid igb hpsa dca
[22946.733651]
[22946.734244] Pid: 96, comm: ksmd Not tainted 2.6.38-8-server
#42-Ubuntu HP SE2170s             /SE2170s
[22946.738822] RIP: 0010:[<ffffffff8114f74e>]  [<ffffffff8114f74e>]
remove_rmap_item_from_tree+0x9e/0x140
[22946.864990] RSP: 0018:ffff880bdc3dbdf0  EFLAGS: 00010286
[22946.929703] RAX: ffff880b0ef3b7f0 RBX: ffff880b082d3fc0 RCX: ffffea00534c94e0
[22946.994971] RDX: 0000880b081ef670 RSI: ffff8817de31ff53 RDI: ffffea00534c94d8
[22947.058724] RBP: ffff880bdc3dbe10 R08: 000000000001b555 R09: ffff880bc4a83ffc
[22947.121702] R10: ffff880bc4a83000 R11: 0000000000000001 R12: ffff8817de31ff50
[22947.185048] R13: ffffea00534c94d8 R14: ffff880bdc3dbe98 R15: ffff880bdc3d2dc0
[22947.249391] FS:  0000000000000000(0000) GS:ffff88183fca0000(0000)
knlGS:0000000000000000
[22947.380838] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[22947.449947] CR2: 00007f8b66bebd00 CR3: 0000000001a03000 CR4: 00000000000026e0
[22947.521049] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[22947.592299] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[22947.661556] Process ksmd (pid: 96, threadinfo ffff880bdc3da000,
task ffff880bdc3d2dc0)
[22947.796881] Stack:
[22947.863663]  ffffffff81074b10 ffff880bdc3d2dc0 ffffea0027eba0a0
ffff880b082d3fc0
[22947.999100]  ffff880bdc3dbe70 ffffffff8115030c ffff880bdc3dbe70
ffffffff8114fdcc
[22948.134245]  ffff880b082d3fc0 0000000000000000 0000000000000000
ffff880bdc3d2dc0
[22948.269277] Call Trace:
[22948.334258]  [<ffffffff81074b10>] ? process_timeout+0x0/0x10
[22948.399750]  [<ffffffff8115030c>] cmp_and_merge_page+0x2c/0x3f0
[22948.463915]  [<ffffffff8114fdcc>] ? scan_get_next_rmap_item+0x29c/0x450
[22948.527601]  [<ffffffff8115077f>] ksm_scan_thread+0xaf/0x2a0
[22948.590328]  [<ffffffff81087940>] ? autoremove_wake_function+0x0/0x40
[22948.652426]  [<ffffffff811506d0>] ? ksm_scan_thread+0x0/0x2a0
[22948.713048]  [<ffffffff810871f6>] kthread+0x96/0xa0
[22948.771932]  [<ffffffff8100cde4>] kernel_thread_helper+0x4/0x10
[22948.830631]  [<ffffffff81087160>] ? kthread+0x0/0xa0
[22948.887967]  [<ffffffff8100cde0>] ? kernel_thread_helper+0x0/0x10
[22948.945959] Code: 28 4c 89 e7 e8 f4 f8 ff ff 48 85 c0 49 89 c5 74
d2 f0 0f ba 28 00 19 c0 85 c0 0f 85 99 00 00 00 48 8b 43 30 48 8b 53
38 48 85 c0 <48> 89 02 74 04 48 89 50 08 48 b8 00 01 10 00 00 00 ad de
48 ba
[22949.127753] RIP  [<ffffffff8114f74e>] remove_rmap_item_from_tree+0x9e/0x140
[22949.188851]  RSP <ffff880bdc3dbdf0>

What I've learned so far from the crash dump is the following. We
crash in ksm.c:remove_rmap_item_from_tree() trying to remove an
rmap_item from a linked list:

536 static void remove_rmap_item_from_tree(struct rmap_item *rmap_item)
537 {
538         if (rmap_item->address & STABLE_FLAG) {
539                 struct stable_node *stable_node;
540                 struct page *page;
541
542                 stable_node = rmap_item->head;
543                 page = get_ksm_page(stable_node);
544                 if (!page)
545                         goto out;
546
547                 lock_page(page);
548                 hlist_del(&rmap_item->hlist);		<-- this is where we crash

When looking at that particular rmap_item, the list node pprev address
seems corrupted (its upper 2 bytes are zeroed out):

crash> rmap_item ffff880b082d3fc0
struct rmap_item {
  rmap_list = 0xffff880b081ef000,
  anon_vma = 0xffff8817ddaac2a8,
  mm = 0xffff8817de07ad80,
  address = 140436244759040,
  oldchecksum = 833604096,
  {
    node = {
      rb_parent_color = 18446612234826284880,
      rb_right = 0xffff880b0ef3b7f0,
      rb_left = 0x880b081ef670
    },
    {
      head = 0xffff8817de31ff50,
      hlist = {
        next = 0xffff880b0ef3b7f0,
        pprev = 0x880b081ef670 		<-- corrupt address?
      }
    }
  }
}

And the list node by itself:

crash> hlist_node 0xffff880b082d3ff0
struct hlist_node {
  next = 0xffff880b0ef3b7f0,
  pprev = 0x880b081ef670                <-- corrupt address?
}

The list seems to be intact except for this one address. A fragment of
the list with the corrupted node in the middle:

crash> list -s hlist_node ffff880b08311630
ffff880b08311630
struct hlist_node {
  next = 0xffff880b083115f0,
  pprev = 0xffff880b08311a30
}
ffff880b083115f0
struct hlist_node {
  next = 0xffff880b081ef9b0,
  pprev = 0xffff880b08311630
}
ffff880b081ef9b0
struct hlist_node {
  next = 0xffff880b081ef670,
  pprev = 0xffff880b083115f0
}
ffff880b081ef670
struct hlist_node {
  next = 0xffff880b082d3ff0,
  pprev = 0xffff880b081ef9b0
}
ffff880b082d3ff0
struct hlist_node {
  next = 0xffff880b0ef3b7f0,
  pprev = 0x880b081ef670 		<-- memory corruption? upper 2 bytes are
zeroed out but should be ff ff.
}
ffff880b0ef3b7f0
struct hlist_node {
  next = 0xffff8817b6ed8eb0,
  pprev = 0xffff880b082d3ff0
}
ffff8817b6ed8eb0
struct hlist_node {
  next = 0xffff8817b6ed8e70,
  pprev = 0xffff880b0ef3b7f0
}
ffff8817b6ed8e70
struct hlist_node {
  next = 0xffff880b1202e2b0,
  pprev = 0xffff8817b6ed8eb0
}
ffff880b1202e2b0
struct hlist_node {
  next = 0xffff8817187c6b30,
  pprev = 0xffff8817b6ed8e70
}

If I'm not mistaken, the upper 2 bytes of the pprev address are at the
end of the rmap_item struct. Could this be a memory
corruption/overwrite?


Thanks
...Juerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
