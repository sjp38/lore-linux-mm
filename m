Message-ID: <47E9482B.7050005@cosmosbay.com>
Date: Tue, 25 Mar 2008 19:44:59 +0100
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 10318] New: WARNING: at arch/x86/mm/highmem_32.c:43
 kmap_atomic_prot+0x87/0x184()
References: <bug-10318-10286@http.bugzilla.kernel.org/> <20080325105750.ff913a83.akpm@linux-foundation.org>
In-Reply-To: <20080325105750.ff913a83.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org, pstaszewski@artcom.pl, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Andrew Morton a ecrit :
> On Tue, 25 Mar 2008 02:50:54 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
>
>   
>> http://bugzilla.kernel.org/show_bug.cgi?id=10318
>>
>>            Summary: WARNING: at arch/x86/mm/highmem_32.c:43
>>                     kmap_atomic_prot+0x87/0x184()
>>            Product: Networking
>>            Version: 2.5
>>      KernelVersion: 2.6.25-rc6-git7
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: IPV4
>>         AssignedTo: shemminger@linux-foundation.org
>>         ReportedBy: pstaszewski@artcom.pl
>>
>>
>> Latest working kernel version: 2.6.24
>>     
>
> This is a post-2.6.24 regression.
>
>   
>> Software Environment: bgp/quagga
>>     
>
> The app does a lot of route management stuff.
>
>   
>> Problem Description:
>> Pid: 0, comm: swapper Not tainted 2.6.25-rc6-git7 #1
>>  [<c021a0bf>] warn_on_slowpath+0x40/0x4f
>>  [<c043c372>] fn_trie_lookup+0xe3/0x288
>>  [<c043d61a>] fib4_rule_action+0x3d/0x4d
>>  [<c03f6417>] fib_rules_lookup+0x71/0xb6
>>  [<c043d652>] fib_lookup+0x28/0x36
>>  [<c023f126>] __rmqueue_smallest+0x83/0xe1
>>  [<c023f197>] __rmqueue+0x13/0x172
>>  [<c0211806>] kmap_atomic_prot+0x87/0x184
>>  [<c023fe7c>] get_page_from_freelist+0x2c5/0x358
>>  [<c023ff92>] __alloc_pages+0x71/0x2cf
>>  [<c0240229>] __get_free_pages+0x39/0x47
>>  [<c03f10d0>] neigh_create+0x2d8/0x40e
>>  [<c045b85b>] _read_unlock_bh+0x5/0xd
>>  [<c03f0539>] neigh_lookup+0x92/0x9b
>>  [<c03f1241>] neigh_event_ns+0x3b/0x70
>>  [<c0432523>] arp_process+0x1e5/0x534
>>  [<c03edd5a>] dev_queue_xmit+0x279/0x29f
>>  [<c0419415>] ip_finish_output+0x1c6/0x1fc
>>  [<c03f81d5>] tc_classify+0x14/0x6b
>>  [<c03eb578>] netif_receive_skb+0x29f/0x30e
>>  [<c0357e63>] e1000_receive_skb+0x132/0x14c
>>  [<c0359ecf>] e1000_clean_rx_irq+0x1fa/0x29c
>>  [<c0356f82>] e1000_clean+0x29f/0x427
>>  [<c03ed3ee>] net_rx_action+0x5c/0x14a
>>  [<c021e25e>] __do_softirq+0x5d/0xc1
>>  [<c021e2f4>] do_softirq+0x32/0x36
>>  [<c021e585>] irq_exit+0x35/0x67
>>  [<c0204f79>] do_IRQ+0x73/0x82
>>  [<c020343b>] common_interrupt+0x23/0x28
>>  [<c0201377>] mwait_idle_with_hints+0x36/0x39
>>  [<c020137a>] mwait_idle+0x0/0xa
>>  [<c0201817>] cpu_idle+0xa8/0xc8
>>  =======================
>> ---[ end trace 6a93a9703f6a626e ]---
>> ------------[ cut here ]------------
>>     
>
> This backtrace is a mess.
>
>   
>> WARNING: at arch/x86/mm/highmem_32.c:43 kmap_atomic_prot+0x87/0x184()
>> Modules linked in:
>> Pid: 0, comm: swapper Not tainted 2.6.25-rc6-git7 #1
>>  [<c021a0bf>] warn_on_slowpath+0x40/0x4f
>>  [<c043c372>] fn_trie_lookup+0xe3/0x288
>>  [<c043d61a>] fib4_rule_action+0x3d/0x4d
>>  [<c03f6417>] fib_rules_lookup+0x71/0xb6
>>  [<c043d652>] fib_lookup+0x28/0x36
>>  [<c023f126>] __rmqueue_smallest+0x83/0xe1
>>  [<c023f197>] __rmqueue+0x13/0x172
>>  [<c0211806>] kmap_atomic_prot+0x87/0x184
>>  [<c023fe7c>] get_page_from_freelist+0x2c5/0x358
>>  [<c023ff92>] __alloc_pages+0x71/0x2cf
>>  [<c0240229>] __get_free_pages+0x39/0x47
>>  [<c03f10d0>] neigh_create+0x2d8/0x40e
>>  [<c045b85b>] _read_unlock_bh+0x5/0xd
>>  [<c03f0539>] neigh_lookup+0x92/0x9b
>>  [<c03f1241>] neigh_event_ns+0x3b/0x70
>>  [<c0432523>] arp_process+0x1e5/0x534
>>  [<c03edd5a>] dev_queue_xmit+0x279/0x29f
>>  [<c0419415>] ip_finish_output+0x1c6/0x1fc
>>  [<c03f81d5>] tc_classify+0x14/0x6b
>>  [<c03eb578>] netif_receive_skb+0x29f/0x30e
>>  [<c0357e63>] e1000_receive_skb+0x132/0x14c
>>  [<c0359ecf>] e1000_clean_rx_irq+0x1fa/0x29c
>>  [<c0356f82>] e1000_clean+0x29f/0x427
>>  [<c03ed3ee>] net_rx_action+0x5c/0x14a
>>  [<c021e25e>] __do_softirq+0x5d/0xc1
>>  [<c021e2f4>] do_softirq+0x32/0x36
>>  [<c021e585>] irq_exit+0x35/0x67
>>  [<c0204f79>] do_IRQ+0x73/0x82
>>  [<c020343b>] common_interrupt+0x23/0x28
>>  [<c0201377>] mwait_idle_with_hints+0x36/0x39
>>  [<c020137a>] mwait_idle+0x0/0xa
>>  [<c0201817>] cpu_idle+0xa8/0xc8
>>  =======================
>>     
>
> They all are.
>
> afacit what's happened is that someone is running __alloc_pages(...,
> __GFP_ZERO) from softirq context.  But the __GFP_ZERO implementation uses
> KM_USER0 which cannot be used from softirq context because non-interrupt
> code on this CPU might be using the same kmap slot.
>
> Can anyone thing of anything which recently changed in either networking
> core or e1000e which would have triggered this?
>
>   
If kzalloc() or __get_free_pages(__GFP_ZERO) is not allowed from softirq 
then many usages are illegal.

Only old stuff (commit 77d04bd957ddca9d48a664e28b40f33993f4550e,  from 
you Andrew)

Relevant part for this backtrace :

(Only triggers on i386 if we have more than 1024 neighbours (512 on 
x86_64) (quite rare situation), so this could explain this was not 
noticed until now ?

diff --git a/net/core/neighbour.c 
<http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.26.git;a=blob;f=net/core/neighbour.c;h=0c8666872d10fdf0d90fea6b327952c6f6493051;hb=31380de95cc3183bbb379339e67f83d69e56fbd6> 
b/net/core/neighbour.c 
<http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.26.git;a=blob;f=net/core/neighbour.c;h=2ec8693fb778f581dd114838700131d810016e3d;hb=77d04bd957ddca9d48a664e28b40f33993f4550e>
index 0c86668 
<http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.26.git;a=blob;f=net/core/neighbour.c;h=0c8666872d10fdf0d90fea6b327952c6f6493051;hb=31380de95cc3183bbb379339e67f83d69e56fbd6>..2ec8693 
<http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.26.git;a=blob;f=net/core/neighbour.c;h=2ec8693fb778f581dd114838700131d810016e3d;hb=77d04bd957ddca9d48a664e28b40f33993f4550e> 
100644 (file)
--- a/net/core/neighbour.c 
<http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.26.git;a=blob;f=net/core/neighbour.c;h=0c8666872d10fdf0d90fea6b327952c6f6493051;hb=31380de95cc3183bbb379339e67f83d69e56fbd6>
+++ b/net/core/neighbour.c 
<http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.26.git;a=blob;f=net/core/neighbour.c;h=2ec8693fb778f581dd114838700131d810016e3d;hb=77d04bd957ddca9d48a664e28b40f33993f4550e>
@@ -284,14 
<http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.26.git;a=blob;f=net/core/neighbour.c;h=0c8666872d10fdf0d90fea6b327952c6f6493051;hb=31380de95cc3183bbb379339e67f83d69e56fbd6#l284> 
+284,11 
<http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.26.git;a=blob;f=net/core/neighbour.c;h=2ec8693fb778f581dd114838700131d810016e3d;hb=77d04bd957ddca9d48a664e28b40f33993f4550e#l284> 
@@ static struct neighbour **neigh_hash_alloc(unsigned int entries)
        struct neighbour **ret;
 
        if (size <= PAGE_SIZE) {
-               ret = kmalloc(size, GFP_ATOMIC);
+               ret = kzalloc(size, GFP_ATOMIC);
        } else {
                ret = (struct neighbour **)
-                       __get_free_pages(GFP_ATOMIC, get_order(size));
+                     __get_free_pages(GFP_ATOMIC|__GFP_ZERO, get_order(size));
        }
-       if (ret)
-               memset(ret, 0, size);
-
        return ret;
 }

> I think the core MM code is being doubly dumb here.
>
> a) We should be able to use __GFP_ZERO from all copntexts.
>
> b) it's not a highmem page anyway, so we won't be using that kmap slot.
>
> Pawel, can you please confirm that this:
>
> --- a/arch/x86/mm/highmem_32.c~a
> +++ a/arch/x86/mm/highmem_32.c
> @@ -73,15 +73,15 @@ void *kmap_atomic_prot(struct page *page
>  {
>  	enum fixed_addresses idx;
>  	unsigned long vaddr;
> -	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
> -
> -	debug_kmap_atomic_prot(type);
>  
> +	/* even !CONFIG_PREEMPT needs this, for in_atomic in do_page_fault */
>  	pagefault_disable();
>  
>  	if (!PageHighMem(page))
>  		return page_address(page);
>  
> +	debug_kmap_atomic_prot(type);
> +
>  	idx = type + KM_TYPE_NR*smp_processor_id();
>  	vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
>  	BUG_ON(!pte_none(*(kmap_pte-idx)));
> _
>
> fixes it?
>
> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
