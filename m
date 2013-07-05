Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 1DCCD6B0033
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 23:02:05 -0400 (EDT)
Date: Thu, 4 Jul 2013 23:02:03 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <254434703.9360266.1372993323102.JavaMail.root@redhat.com>
In-Reply-To: <1362256961.9359434.1372993129215.JavaMail.root@redhat.com>
Subject: 3.9.8 and 3.9.9: stack corruption still there
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: stable@vger.kernel.org

Reported before:
http://oss.sgi.com/archives/xfs/2013-05/msg00768.html
http://oss.sgi.com/archives/xfs/2013-05/msg00722.html

[19696.337456] BUG: unable to handle kernel NULL pointer dereference at 0000000000000130 
[19696.345304] IP: [<ffffffff81097dbb>] account_guest_time+0x3b/0xb0 
[19696.351407] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.355880] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.363717] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.369296] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.373765] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.381603] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.387180] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.391649] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.399486] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.405060] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.409531] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.417368] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.422943] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.427413] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.435250] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.440826] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.445294] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.453129] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.458702] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.463170] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.471007] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.476583] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.481051] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.488889] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.494464] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.498932] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.506769] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.512342] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.516810] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.524648] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.530223] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.534692] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.542527] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.548101] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.552569] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.560406] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.565979] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.570450] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.578287] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.583863] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.588331] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.596169] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.601742] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.606210] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.614047] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.619621] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.624091] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.631928] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.637504] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.641975] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.649809] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.655385] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.659853] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.667688] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.673262] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.677731] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.685568] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.691142] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.695610] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.703447] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.709022] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.713491] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.721328] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.726901] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.731369] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.739206] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.744781] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.749249] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.757087] IP: [<ffffffff81604e97>] no_context+0x1f7/0x270 
[19696.762660] PGD 1da69b067 PUD 1f154c067 PMD 0  
[19696.767128] BUG: unable to handle kernel NULL pointer dereference at 0000000000000067 
[19696.774965] IP: 
[19696.776544] Kernel panic - not syncing: stack-protector: Kernel stack is corrupted in: ffffffff812ffbf2 
[19696.776544]  
[19697.943039] Shutting down cpus with NMI 

or 

[19472.102763] BUG: Bad page map in process smbd  pte:ffff880052e12dc0 pmd:40909067 
[19472.104873] addr:00007f2d79186000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:10b 
[19472.107069] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.108384] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.109771] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.111240] Call Trace: 
[19472.111717]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.113049]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19472.114387]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.115797]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.117183]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.118491]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.119796]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.120939]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.122156]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.123468]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.124871]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.126109]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.127599]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.128887]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.130332]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.131749] BUG: Bad page map in process smbd  pte:ffffffff818189e9 pmd:40909067 
[19472.133497] addr:00007f2d79187000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:10c 
[19472.136103] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.137532] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.138914] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.140075] Call Trace: 
[19472.140460]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.141356]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19472.142299]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.143749]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.145218]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.146046]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.146891]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.147897]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.149048]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.150458]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.151719]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.152839]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.154279]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.155415]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.156658]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.157866] BUG: Bad page map in process smbd  pte:ffff88004090a1d1 pmd:40909067 
[19472.159237] addr:00007f2d79188000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:10d 
[19472.161343] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.162492] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.163843] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.165702] Call Trace: 
[19472.166509]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.168108]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19472.169902]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.171876]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.173039]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.174080]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.175397]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.176736]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.177837]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.178836]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.180136]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.181274]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.182631]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.183777]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.185013]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.186088] BUG: Bad page map in process smbd  pte:ffff88004090a388 pmd:40909067 
[19472.187719] addr:00007f2d79189000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:10e 
[19472.189961] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.191314] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.192549] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.193892] Call Trace: 
[19472.194410]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.195623]  [<ffffffff8115a799>] vm_normal_page+0x69/0x80 
[19472.196842]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.198080]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.199362]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.200541]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.201626]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.202667]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.203801]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.205001]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.206377]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.207505]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.208875]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.210022]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.211277]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.212485] BUG: Bad page map in process smbd  pte:0023ee05 pmd:40909067 
[19472.213958] addr:00007f2d7918d000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:112 
[19472.216163] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.217335] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.218572] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.219912] Call Trace: 
[19472.220443]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.221710]  [<ffffffff8115a799>] vm_normal_page+0x69/0x80 
[19472.222920]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.224208]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.225557]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.226718]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.227871]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.228917]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.229857]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.230986]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.232359]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.233500]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.234849]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.236014]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.237303]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.238547] swap_free: Unused swap file entry 7fffffffc0cd7e 
[19472.239775] BUG: Bad page map in process smbd  pte:ffffffff819afc00 pmd:40909067 
[19472.241730] addr:00007f2d7918e000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:113 
[19472.243908] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.244772] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.245730] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.246901] Call Trace: 
[19472.247427]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.248491]  [<ffffffff8115ad1c>] unmap_page_range+0x56c/0x7f0 
[19472.249430]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.250490]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.251577]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.252698]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.253753]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.254790]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.255976]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.257336]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.258341]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.259641]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.260787]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.262028]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.263238] swap_free: Unused swap file entry 20000238c409200 
[19472.264537] BUG: Bad page map in process smbd  pte:471881240002 pmd:40909067 
[19472.266059] addr:00007f2d79191000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:116 
[19472.268306] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.269459] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.270785] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.272092] Call Trace: 
[19472.272605]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.273889]  [<ffffffff8115ad1c>] unmap_page_range+0x56c/0x7f0 
[19472.275062]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.276358]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.277575]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.278446]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.279400]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.280448]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.281603]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.282988]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.284083]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.285457]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.286597]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.287840]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.289050] BUG: Bad page map in process smbd  pte:cccccccccccccccc pmd:40909067 
[19472.290568] addr:00007f2d79193000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:118 
[19472.292815] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.293962] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.295196] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.296520] Call Trace: 
[19472.297068]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.298297]  [<ffffffff8115ae78>] unmap_page_range+0x6c8/0x7f0 
[19472.299561]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.300814]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.301954]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.303083]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.304290]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.305568]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.306818]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.308372]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.309688]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.311290]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.312594]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.314036]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.315399] BUG: Bad page map in process smbd  pte:ffff88004090a1b8 pmd:40909067 
[19472.317209] addr:00007f2d79194000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:119 
[19472.319834] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.321180] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.322531] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.323869] Call Trace: 
[19472.324394]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.325606]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19472.326808]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.328054]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.329353]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.330541]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.331711]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.332817]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.333756]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.334885]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.336334]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.337451]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.338901]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.340089]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.341474]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.342976] BUG: Bad page map in process smbd  pte:ffffffff8120f104 pmd:40909067 
[19472.344643] addr:00007f2d79195000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:11a 
[19472.346322] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.347224] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.348525] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.349729] Call Trace: 
[19472.350135]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.351180]  [<ffffffff8120f104>] ? sysfs_new_dirent+0x54/0x110 
[19472.352356]  [<ffffffff8120f104>] ? sysfs_new_dirent+0x54/0x110 
[19472.353735]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19472.354992]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.356063]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.357170]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.358248]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.359314]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.360515]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.361836]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.362849]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.365410]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.368411]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.372199]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.374944]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.377260]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.379428] swap_free: Unused swap file entry 207fffffffc0b042 
[19472.381879] BUG: Bad page map in process smbd  pte:ffffffff81608420 pmd:40909067 
[19472.384128] addr:00007f2d79196000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:11b 
[19472.386856] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.388151] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.389480] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.390983] Call Trace: 
[19472.391560]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.392979]  [<ffffffff81608420>] ? __slab_alloc+0x3b8/0x4a2 
[19472.394369]  [<ffffffff81608420>] ? __slab_alloc+0x3b8/0x4a2 
[19472.395860]  [<ffffffff8115ad1c>] unmap_page_range+0x56c/0x7f0 
[19472.397286]  [<ffffffff8120f104>] ? sysfs_new_dirent+0x54/0x110 
[19472.398636]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.400036]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.401342]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.402662]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.403887]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.405175]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.406559]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.408114]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.409319]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.410922]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.412134]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.413633]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.414996] BUG: Bad page map in process smbd  pte:ffffffff81184ead pmd:40909067 
[19472.416718] addr:00007f2d79197000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:11c 
[19472.419289] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.420604] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.422048] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.423607] Call Trace: 
[19472.424157]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.425565]  [<ffffffff81184ead>] ? kmem_cache_alloc+0x19d/0x1e0 
[19472.427109]  [<ffffffff81184ead>] ? kmem_cache_alloc+0x19d/0x1e0 
[19472.428643]  [<ffffffff8115a799>] vm_normal_page+0x69/0x80 
[19472.430028]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.431396]  [<ffffffff8120f104>] ? sysfs_new_dirent+0x54/0x110 
[19472.432633]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.434075]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.435249]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.436511]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.437657]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.438935]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.440265]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.441866]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.443110]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.444718]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.445714]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.446630]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.447489] BUG: Bad page map in process smbd  pte:ffffffff8120f104 pmd:40909067 
[19472.448641] addr:00007f2d79198000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:11d 
[19472.450200] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.450989] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.451893] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.452847] Call Trace: 
[19472.453244]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.454130]  [<ffffffff8120f104>] ? sysfs_new_dirent+0x54/0x110 
[19472.455054]  [<ffffffff8120f104>] ? sysfs_new_dirent+0x54/0x110 
[19472.455948]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19472.456836]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.457755]  [<ffffffff81184ead>] ? kmem_cache_alloc+0x19d/0x1e0 
[19472.458718]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.459607]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.460437]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.461274]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.461984]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.462807]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.463657]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.464637]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.465458]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.466415]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.467373]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.468263]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.469112] BUG: Bad page map in process smbd  pte:ffffffff8120e5bb pmd:40909067 
[19472.470253] addr:00007f2d79199000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:11e 
[19472.471819] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.472667] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.473556] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.474894] Call Trace: 
[19472.475328]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.476212]  [<ffffffff8120e5bb>] ? sysfs_add_file_mode+0x6b/0xe0 
[19472.477428]  [<ffffffff8120e5bb>] ? sysfs_add_file_mode+0x6b/0xe0 
[19472.478364]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19472.479219]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.480138]  [<ffffffff8120f104>] ? sysfs_new_dirent+0x54/0x110 
[19472.481043]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.481896]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.482733]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.483539]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.484297]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.485112]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.485934]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.486923]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.487751]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.488737]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.489555]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.490437]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.491295] BUG: Bad page map in process smbd  pte:ffffffff8120e65a pmd:40909067 
[19472.492443] addr:00007f2d7919a000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:11f 
[19472.494032] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.494819] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.495720] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.496686] Call Trace: 
[19472.497108]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.497950]  [<ffffffff8120e65a>] ? sysfs_create_file+0x2a/0x30 
[19472.498879]  [<ffffffff8120e65a>] ? sysfs_create_file+0x2a/0x30 
[19472.499807]  [<ffffffff8115ae78>] unmap_page_range+0x6c8/0x7f0 
[19472.500749]  [<ffffffff8120e5bb>] ? sysfs_add_file_mode+0x6b/0xe0 
[19472.501714]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.502629]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.503446]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.504296]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.505062]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.505845]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.506736]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.507739]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.508556]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.509541]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.510365]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.511266]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.512120] BUG: Bad page map in process smbd  pte:ffffffff813ea050 pmd:40909067 
[19472.513260] addr:00007f2d7919b000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:120 
[19472.514836] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.515686] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.516597] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.517557] Call Trace: 
[19472.517948]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.518844]  [<ffffffff813ea050>] ? device_add+0x180/0x720 
[19472.519729]  [<ffffffff813ea050>] ? device_add+0x180/0x720 
[19472.520615]  [<ffffffff8115ae78>] unmap_page_range+0x6c8/0x7f0 
[19472.521525]  [<ffffffff8120e5bb>] ? sysfs_add_file_mode+0x6b/0xe0 
[19472.522492]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.523401]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.524217]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.524994]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.525761]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.526535]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.527381]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.528349]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.529184]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.530181]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.530961]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.531875]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.532737] swap_free: Unused swap file entry 207fffffffc09f54 
[19472.533650] BUG: Bad page map in process smbd  pte:ffffffff813ea820 pmd:40909067 
[19472.534802] addr:00007f2d7919c000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:121 
[19472.536366] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.537237] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.538159] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.539100] Call Trace: 
[19472.539477]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.540350]  [<ffffffff813ea820>] ? device_create_vargs+0xf0/0x130 
[19472.541328]  [<ffffffff813ea820>] ? device_create_vargs+0xf0/0x130 
[19472.542323]  [<ffffffff8115ad1c>] unmap_page_range+0x56c/0x7f0 
[19472.543248]  [<ffffffff8120e5bb>] ? sysfs_add_file_mode+0x6b/0xe0 
[19472.544227]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.545138]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.545923]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.546734]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.547464]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.548259]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.549102]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.550070]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.550848]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.551816]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.552636]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.553519]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.554379] swap_free: Unused swap file entry 147fffffffc09f54 
[19472.555285] BUG: Bad page map in process smbd  pte:ffffffff813ea894 pmd:40909067 
[19472.556452] addr:00007f2d7919d000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:122 
[19472.558024] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.558835] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.559739] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.560714] Call Trace: 
[19472.561142]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.561983]  [<ffffffff813ea894>] ? device_create+0x34/0x40 
[19472.562907]  [<ffffffff813ea894>] ? device_create+0x34/0x40 
[19472.563818]  [<ffffffff8115ad1c>] unmap_page_range+0x56c/0x7f0 
[19472.564764]  [<ffffffff8120e5bb>] ? sysfs_add_file_mode+0x6b/0xe0 
[19472.565740]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.566649]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.567455]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.568295]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.569054]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.569823]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.570691]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.571694]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.572516]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.573495]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.574354]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.575253]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.576132] BUG: Bad page map in process smbd  pte:ffffffff813b7920 pmd:40909067 
[19472.577269] addr:00007f2d7919e000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:123 
[19472.578830] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.579627] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.580532] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.581474] Call Trace: 
[19472.581876]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.582794]  [<ffffffff813b7920>] ? vcs_make_sysfs+0x60/0x70 
[19472.583686]  [<ffffffff813b7920>] ? vcs_make_sysfs+0x60/0x70 
[19472.584584]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19472.585450]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.586377]  [<ffffffff8120e5bb>] ? sysfs_add_file_mode+0x6b/0xe0 
[19472.587348]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.588251]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.589048]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.589840]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.590606]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.591394]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.592255]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.593250]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.594058]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.594983]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.595826]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.596754]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.597607] BUG: Bad page map in process smbd  pte:ffffffff813c0352 pmd:40909067 
[19472.598766] addr:00007f2d7919f000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:124 
[19472.600335] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.601160] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.602058] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.602977] Call Trace: 
[19472.603408]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.604296]  [<ffffffff813c0352>] ? vc_allocate+0x162/0x200 
[19472.605199]  [<ffffffff813c0352>] ? vc_allocate+0x162/0x200 
[19472.606062]  [<ffffffff8115a799>] vm_normal_page+0x69/0x80 
[19472.606891]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.607817]  [<ffffffff813b7920>] ? vcs_make_sysfs+0x60/0x70 
[19472.608722]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.609601]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.610414]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.611241]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.611965]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.612785]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.613687]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.614677]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.615488]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.616470]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.617315]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.618213]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.619049] BUG: Bad page map in process smbd  pte:ffffffff813c0419 pmd:40909067 
[19472.620207] addr:00007f2d791a0000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:125 
[19472.621766] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.622586] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.623494] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.624452] Call Trace: 
[19472.624834]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.625719]  [<ffffffff813c0419>] ? con_install+0x29/0xe0 
[19472.626564]  [<ffffffff813c0419>] ? con_install+0x29/0xe0 
[19472.627420]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19472.628275]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.629202]  [<ffffffff813c0352>] ? vc_allocate+0x162/0x200 
[19472.630048]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.630902]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.631736]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.632555]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.633338]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.634144]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.634967]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.635963]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.636764]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.637790]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.638615]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.639494]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.640362] BUG: Bad page map in process smbd  pte:ffffffff813a98ee pmd:40909067 
[19472.641535] addr:00007f2d791a1000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:126 
[19472.643151] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.643932] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.644836] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.645800] Call Trace: 
[19472.646214]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.647082]  [<ffffffff813a98ee>] ? tty_init_dev+0x9e/0x200 
[19472.647904]  [<ffffffff813a98ee>] ? tty_init_dev+0x9e/0x200 
[19472.648781]  [<ffffffff8115ae78>] unmap_page_range+0x6c8/0x7f0 
[19472.649698]  [<ffffffff813c0419>] ? con_install+0x29/0xe0 
[19472.650527]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.651400]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.652210]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.652981]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.653759]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.654566]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.655420]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.656406]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.657210]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.658173]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.658967]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.659871]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.660725] BUG: Bad page map in process smbd  pte:ffffffff813aa644 pmd:40909067 
[19472.661895] addr:00007f2d791a2000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:127 
[19472.663459] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.664304] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.665222] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.666177] Call Trace: 
[19472.666556]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.667446]  [<ffffffff813aa644>] ? tty_open+0x324/0x5e0 
[19472.668296]  [<ffffffff813aa644>] ? tty_open+0x324/0x5e0 
[19472.669150]  [<ffffffff8115ae78>] unmap_page_range+0x6c8/0x7f0 
[19472.670051]  [<ffffffff813c0419>] ? con_install+0x29/0xe0 
[19472.670863]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.671757]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.672557]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.673370]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.674137]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.674908]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.675786]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.676791]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.677608]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.678567]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.679387]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.680292]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.681146] BUG: Bad page map in process smbd  pte:ffffffff811a0e5d pmd:40909067 
[19472.682288] addr:00007f2d791a3000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:128 
[19472.683857] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.684698] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.685602] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.686540] Call Trace: 
[19472.686920]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.687802]  [<ffffffff811a0e5d>] ? chrdev_open+0x9d/0x180 
[19472.688660]  [<ffffffff811a0e5d>] ? chrdev_open+0x9d/0x180 
[19472.689517]  [<ffffffff8115a799>] vm_normal_page+0x69/0x80 
[19472.690382]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.691306]  [<ffffffff813c0419>] ? con_install+0x29/0xe0 
[19472.692164]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.693057]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.693846]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.694658]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.695413]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.696221]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.697043]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.698006]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.698833]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.699810]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.700636]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.701521]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.702363] BUG: Bad page map in process smbd  pte:ffffffff8119ab5f pmd:40909067 
[19472.703506] addr:00007f2d791a4000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:129 
[19472.705060] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.705848] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.706766] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.707736] Call Trace: 
[19472.708174]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.709041]  [<ffffffff8119ab5f>] ? do_dentry_open+0x1ef/0x2a0 
[19472.709927]  [<ffffffff8119ab5f>] ? do_dentry_open+0x1ef/0x2a0 
[19472.710847]  [<ffffffff8115a799>] vm_normal_page+0x69/0x80 
[19472.711729]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.712634]  [<ffffffff811a0e5d>] ? chrdev_open+0x9d/0x180 
[19472.713498]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.714400]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.715215]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.715983]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.716748]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.717546]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.718393]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.719374]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.720185]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.721153]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.721934]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.722840]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.723705] BUG: Bad page map in process smbd  pte:ffffffff8119ac41 pmd:40909067 
[19472.724854] addr:00007f2d791a5000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:12a 
[19472.726384] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.727204] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.728100] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.729049] Call Trace: 
[19472.729432]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.730300]  [<ffffffff8119ac41>] ? finish_open+0x31/0x40 
[19472.731138]  [<ffffffff8119ac41>] ? finish_open+0x31/0x40 
[19472.731952]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19472.732849]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.733775]  [<ffffffff8119ab5f>] ? do_dentry_open+0x1ef/0x2a0 
[19472.734686]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.735564]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.736373]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.737211]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.742865]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.743772]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.744749]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.745873]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.746823]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.747919]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.748862]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.749893]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.750896] BUG: Bad page map in process smbd  pte:219400000001 pmd:40909067 
[19472.752148] addr:00007f2d791a6000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:12b 
[19472.753899] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.754879] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.755927] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.757033] Call Trace: 
[19472.757456]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.758473]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19472.759473]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.760513]  [<ffffffff8119ac41>] ? finish_open+0x31/0x40 
[19472.761507]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.762525]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.763394]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.764203]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.764911]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.765724]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.766545]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.767519]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.768344]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.769307]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.770140]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.770994]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.771856] BUG: Bad page map in process smbd  pte:100b6df23 pmd:40909067 
[19472.772912] addr:00007f2d791a7000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:12c 
[19472.774463] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.775297] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.776204] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.777147] Call Trace: 
[19472.777528]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.778414]  [<ffffffff8115a799>] vm_normal_page+0x69/0x80 
[19472.779271]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.780183]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.781067]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.781848]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.782692]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.783453]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.784291]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.785160]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.786134]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.786907]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.787888]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.788783]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.789687]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.790549] BUG: Bad page map in process smbd  pte:5a5a5a5a5a5a5a5a pmd:40909067 
[19472.791701] addr:00007f2d791bb000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:140 
[19472.793266] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.794127] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.794992] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.795976] Call Trace: 
[19472.796390]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.797275]  [<ffffffff8115ae78>] unmap_page_range+0x6c8/0x7f0 
[19472.798208]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.799060]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.799833]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.800642]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.801419]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.802222]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.803064]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.804005]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.804818]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.805790]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.806608]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.807501]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.808346] BUG: Bad page map in process smbd  pte:00000001 pmd:40909067 
[19472.809399] page:ffffea0000000000 count:0 mapcount:-1 mapping:          (null) index:0x0 
[19472.810636] page flags: 0x0() 
[19472.811122] addr:00007f2d791bc000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:141 
[19472.813656] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.814882] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.816261] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.817731] Call Trace: 
[19472.818312]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.819501]  [<ffffffff8115ae90>] unmap_page_range+0x6e0/0x7f0 
[19472.820905]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.822209]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.823416]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.824460]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.825260]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.826076]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.826931]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.827996]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.828855]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.829868]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.830744]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.831683]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.832571] BUG: Bad page map in process smbd  pte:ffff880052e12dc0 pmd:40909067 
[19472.833777] addr:00007f2d791bd000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:142 
[19472.836106] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.837389] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.838782] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.840234] Call Trace: 
[19472.840739]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.841608]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19472.842460]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.843386]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.844284]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.845108]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.845950]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.846732]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.847541]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.848396]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.849372]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.850198]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.851151]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.851932]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.852840]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.853710] swap_free: Unused swap file entry 107fffc40018cf84 
[19472.854630] BUG: Bad page map in process smbd  pte:ffff8800319f0810 pmd:40909067 
[19472.855789] addr:00007f2d791be000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:143 
[19472.857351] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.858172] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.859056] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.859969] Call Trace: 
[19472.860393]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.861251]  [<ffffffff8115ad1c>] unmap_page_range+0x56c/0x7f0 
[19472.862171]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.863045]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.863829]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.864637]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.865380]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.866180]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.866987]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.867978]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.868796]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.869771]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.870592]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.871484]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.872390] BUG: Bad page map in process smbd  pte:00000001 pmd:40909067 
[19472.873424] page:ffffea0000000000 count:0 mapcount:-2 mapping:          (null) index:0x0 
[19472.874679] page flags: 0x0() 
[19472.875195] addr:00007f2d791bf000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:144 
[19472.877732] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.878982] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.880386] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.881807] Call Trace: 
[19472.882370]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.883761]  [<ffffffff8115ae90>] unmap_page_range+0x6e0/0x7f0 
[19472.885144]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.886518]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.887649]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.888897]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.890012]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.891245]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.892544]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.894066]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.895345]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.896860]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.898124]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.899520]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.900849] BUG: Bad page map in process smbd  pte:ffff880052e12f90 pmd:40909067 
[19472.902641] addr:00007f2d791c0000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:145 
[19472.905122] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.906348] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.907739] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.909182] Call Trace: 
[19472.909736]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.911155]  [<ffffffff8115a799>] vm_normal_page+0x69/0x80 
[19472.912461]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.913863]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.915193]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.916522]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.917780]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.918905]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.920117]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.921437]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.922910]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.924089]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.925648]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.926892]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.928212]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.929494] swap_free: Unused swap file entry 187fffc400204850 
[19472.930897] BUG: Bad page map in process smbd  pte:ffff88004090a018 pmd:40909067 
[19472.932689] addr:00007f2d791c1000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:146 
[19472.935095] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.936396] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.937752] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.939205] Call Trace: 
[19472.939775]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.941184]  [<ffffffff8115ad1c>] unmap_page_range+0x56c/0x7f0 
[19472.942553]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.943942]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.945160]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.946438]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.947582]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.948797]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.950128]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.951657]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.952910]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.954303]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.955384]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.956637]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.957991] BUG: Bad page map in process smbd  pte:45372b66 pmd:40909067 
[19472.959540] addr:00007f2d791c4000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:149 
[19472.961897] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.963176] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.964564] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.965988] Call Trace: 
[19472.966586]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.967924]  [<ffffffff8115a799>] vm_normal_page+0x69/0x80 
[19472.969075]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.970154]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.971293]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19472.972550]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19472.973592]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19472.974444]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19472.975439]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19472.976724]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19472.978221]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19472.979449]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19472.980922]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19472.982094]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19472.983405]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19472.984672] BUG: Bad page map in process smbd  pte:ffff88007b494f78 pmd:40909067 
[19472.986413] addr:00007f2d791c5000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:14a 
[19472.988906] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19472.990130] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19472.991513] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19472.992903] Call Trace: 
[19472.993419]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19472.994774]  [<ffffffff8115a799>] vm_normal_page+0x69/0x80 
[19472.996059]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19472.997515]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19472.998898]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.000132]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.001373]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.002532]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.003738]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.005030]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.006552]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.007815]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.009165]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.010372]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.011734]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.013046] swap_free: Unused swap file entry 80000238d50ff80 
[19473.014411] BUG: Bad page map in process smbd  pte:471aa1ff0008 pmd:40909067 
[19473.016096] addr:00007f2d791c8000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:14d 
[19473.018595] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.019839] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.021243] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.022734] Call Trace: 
[19473.023285]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.024635]  [<ffffffff8115ad1c>] unmap_page_range+0x56c/0x7f0 
[19473.026011]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.027305]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.028554]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.029778]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.030925]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.032132]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.033344]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.034377]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.035241]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.036268]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.037162]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.038076]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.038938] BUG: Bad page map in process smbd  pte:cccccccccccccccc pmd:40909067 
[19473.040413] addr:00007f2d791ca000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:14f 
[19473.042779] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.044014] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.045398] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.046876] Call Trace: 
[19473.047457]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.048799]  [<ffffffff8115ae78>] unmap_page_range+0x6c8/0x7f0 
[19473.050205]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.051588]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.052835]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.054059]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.055249]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.056470]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.057502]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.059022]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.060173]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.061678]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.062874]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.064217]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.065475] BUG: Bad page map in process smbd  pte:ffff88004090a370 pmd:40909067 
[19473.067205] addr:00007f2d791cb000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:150 
[19473.069366] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.070302] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.071518] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.072774] Call Trace: 
[19473.073188]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.074285]  [<ffffffff8115a799>] vm_normal_page+0x69/0x80 
[19473.075506]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19473.076869]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.078213]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.079356]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.080582]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.081703]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.082913]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.084180]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.085593]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.086833]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.088285]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.089570]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.090902]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.092141] BUG: Bad page map in process smbd  pte:ffffffff8120f104 pmd:40909067 
[19473.093939] addr:00007f2d791cc000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:151 
[19473.096356] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.097656] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.099037] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.100549] Call Trace: 
[19473.101155]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.102507]  [<ffffffff8120f104>] ? sysfs_new_dirent+0x54/0x110 
[19473.103888]  [<ffffffff8120f104>] ? sysfs_new_dirent+0x54/0x110 
[19473.105229]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19473.106589]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19473.108023]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.109397]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.110660]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.111922]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.113035]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.114247]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.115549]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.117070]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.118337]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.119843]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.121041]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.122392]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.123714] swap_free: Unused swap file entry 207fffffffc0b042 
[19473.125130] BUG: Bad page map in process smbd  pte:ffffffff81608420 pmd:40909067 
[19473.126957] addr:00007f2d791cd000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:152 
[19473.129427] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.130708] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.132101] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.133602] Call Trace: 
[19473.134162]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.135512]  [<ffffffff81608420>] ? __slab_alloc+0x3b8/0x4a2 
[19473.136879]  [<ffffffff81608420>] ? __slab_alloc+0x3b8/0x4a2 
[19473.138234]  [<ffffffff8115ad1c>] unmap_page_range+0x56c/0x7f0 
[19473.139589]  [<ffffffff8120f104>] ? sysfs_new_dirent+0x54/0x110 
[19473.140994]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.142413]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.143676]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.144972]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.146051]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.147233]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.148535]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.150041]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.151249]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.152797]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.154054]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.155354]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.156406] BUG: Bad page map in process smbd  pte:ffffffff81184ead pmd:40909067 
[19473.158060] addr:00007f2d791ce000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:153 
[19473.160164] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.161372] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.162737] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.164139] Call Trace: 
[19473.164713]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.165720]  [<ffffffff81184ead>] ? kmem_cache_alloc+0x19d/0x1e0 
[19473.166784]  [<ffffffff81184ead>] ? kmem_cache_alloc+0x19d/0x1e0 
[19473.168171]  [<ffffffff8115a799>] vm_normal_page+0x69/0x80 
[19473.169365]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19473.170465]  [<ffffffff8120f104>] ? sysfs_new_dirent+0x54/0x110 
[19473.171619]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.172966]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.174023]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.175169]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.176299]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.177482]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.178781]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.180266]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.181517]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.183023]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.184282]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.185633]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.186910] BUG: Bad page map in process smbd  pte:ffffffff8120f104 pmd:40909067 
[19473.188689] addr:00007f2d791cf000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:154 
[19473.191107] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.192243] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.193598] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.195066] Call Trace: 
[19473.195607]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.197010]  [<ffffffff8120f104>] ? sysfs_new_dirent+0x54/0x110 
[19473.198404]  [<ffffffff8120f104>] ? sysfs_new_dirent+0x54/0x110 
[19473.199804]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19473.201110]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19473.202517]  [<ffffffff81184ead>] ? kmem_cache_alloc+0x19d/0x1e0 
[19473.203973]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.205316]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.206559]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.207832]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.208895]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.210075]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.211357]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.213023]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.214278]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.215779]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.217057]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.218384]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.219685] BUG: Bad page map in process smbd  pte:ffffffff8120fffe pmd:40909067 
[19473.221446] addr:00007f2d791d0000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:155 
[19473.223957] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.225188] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.226555] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.227958] Call Trace: 
[19473.228532]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.229900]  [<ffffffff8120fffe>] ? sysfs_do_create_link_sd+0x7e/0x210 
[19473.231443]  [<ffffffff8120fffe>] ? sysfs_do_create_link_sd+0x7e/0x210 
[19473.233062]  [<ffffffff8115a799>] vm_normal_page+0x69/0x80 
[19473.234399]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19473.235812]  [<ffffffff8120f104>] ? sysfs_new_dirent+0x54/0x110 
[19473.237171]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.238586]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.239794]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.241038]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.242151]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.243393]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.244689]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.246213]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.247437]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.248924]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.250070]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.251439]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.252747] BUG: Bad page map in process smbd  pte:ffffffff812101b1 pmd:40909067 
[19473.254525] addr:00007f2d791d1000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:156 
[19473.257144] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.258119] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.259506] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.260974] Call Trace: 
[19473.261482]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.262855]  [<ffffffff812101b1>] ? sysfs_create_link+0x21/0x40 
[19473.264219]  [<ffffffff812101b1>] ? sysfs_create_link+0x21/0x40 
[19473.265606]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19473.266945]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19473.268359]  [<ffffffff8120fffe>] ? sysfs_do_create_link_sd+0x7e/0x210 
[19473.269945]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.271249]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.272505]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.273441]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.274295]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.275270]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.276580]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.277644]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.278584]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.279972]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.281316]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.282653]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.283548] BUG: Bad page map in process smbd  pte:ffffffff813ea127 pmd:40909067 
[19473.285202] addr:00007f2d791d2000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:157 
[19473.287617] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.288847] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.290171] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.291614] Call Trace: 
[19473.292133]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.293463]  [<ffffffff813ea127>] ? device_add+0x257/0x720 
[19473.294596]  [<ffffffff813ea127>] ? device_add+0x257/0x720 
[19473.295875]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19473.297113]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19473.298535]  [<ffffffff812101b1>] ? sysfs_create_link+0x21/0x40 
[19473.299965]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.301044]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.301843]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.302702]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.303464]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.304283]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.305189]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.306192]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.307291]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.308518]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.309333]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.310246]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.311215] swap_free: Unused swap file entry 207fffffffc09f54 
[19473.312149] BUG: Bad page map in process smbd  pte:ffffffff813ea820 pmd:40909067 
[19473.313290] addr:00007f2d791d3000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:158 
[19473.314881] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.315843] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.316883] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.317888] Call Trace: 
[19473.318300]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.319250]  [<ffffffff813ea820>] ? device_create_vargs+0xf0/0x130 
[19473.320321]  [<ffffffff813ea820>] ? device_create_vargs+0xf0/0x130 
[19473.321289]  [<ffffffff8115ad1c>] unmap_page_range+0x56c/0x7f0 
[19473.322217]  [<ffffffff813ea127>] ? device_add+0x257/0x720 
[19473.323202]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.324210]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.325031]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.325876]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.326659]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.327484]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.328486]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.329530]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.330409]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.331415]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.332268]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.333185]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.334052] swap_free: Unused swap file entry 147fffffffc09f54 
[19473.335104] BUG: Bad page map in process smbd  pte:ffffffff813ea894 pmd:40909067 
[19473.336321] addr:00007f2d791d4000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:159 
[19473.338022] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.338845] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.339851] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.340846] Call Trace: 
[19473.341276]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.342287]  [<ffffffff813ea894>] ? device_create+0x34/0x40 
[19473.343202]  [<ffffffff813ea894>] ? device_create+0x34/0x40 
[19473.344056]  [<ffffffff8115ad1c>] unmap_page_range+0x56c/0x7f0 
[19473.345041]  [<ffffffff813ea127>] ? device_add+0x257/0x720 
[19473.345950]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.347095]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.347959]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.348952]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.349727]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.350576]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.351475]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.352483]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.353385]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.354386]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.355285]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.356292]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.357304] BUG: Bad page map in process smbd  pte:ffffffff813b7920 pmd:40909067 
[19473.358464] addr:00007f2d791d5000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:15a 
[19473.360320] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.361220] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.362189] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.363146] Call Trace: 
[19473.363515]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.364427]  [<ffffffff813b7920>] ? vcs_make_sysfs+0x60/0x70 
[19473.365492]  [<ffffffff813b7920>] ? vcs_make_sysfs+0x60/0x70 
[19473.366407]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19473.367275]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19473.368215]  [<ffffffff813ea127>] ? device_add+0x257/0x720 
[19473.369065]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.369942]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.370774]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.371836]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.372623]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.373414]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.374290]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.375268]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.376088]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.377049]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.377842]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.378748]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.379601] BUG: Bad page map in process smbd  pte:ffffffff813c0352 pmd:40909067 
[19473.380785] addr:00007f2d791d6000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:15b 
[19473.382349] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.383178] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.384097] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.385034] Call Trace: 
[19473.385407]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.386318]  [<ffffffff813c0352>] ? vc_allocate+0x162/0x200 
[19473.387206]  [<ffffffff813c0352>] ? vc_allocate+0x162/0x200 
[19473.388094]  [<ffffffff8115a799>] vm_normal_page+0x69/0x80 
[19473.388931]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19473.389872]  [<ffffffff813b7920>] ? vcs_make_sysfs+0x60/0x70 
[19473.390759]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.391661]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.392485]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.393322]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.394085]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.394860]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.395739]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.396743]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.397557]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.398563]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.399387]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.400277]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.401145] BUG: Bad page map in process smbd  pte:ffffffff813c0419 pmd:40909067 
[19473.402288] addr:00007f2d791d7000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:15c 
[19473.404049] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.404851] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.405764] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.406702] Call Trace: 
[19473.407098]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.407916]  [<ffffffff813c0419>] ? con_install+0x29/0xe0 
[19473.408770]  [<ffffffff813c0419>] ? con_install+0x29/0xe0 
[19473.409621]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19473.410484]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19473.411384]  [<ffffffff813c0352>] ? vc_allocate+0x162/0x200 
[19473.412251]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.413142]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.413919]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.414755]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.415495]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.416314]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.417169]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.418151]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.418937]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.419920]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.420761]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.421660]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.422504] BUG: Bad page map in process smbd  pte:ffffffff813a98ee pmd:40909067 
[19473.423663] addr:00007f2d791d8000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:15d 
[19473.425236] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.426067] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.426939] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.427929] Call Trace: 
[19473.428330]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.429213]  [<ffffffff813a98ee>] ? tty_init_dev+0x9e/0x200 
[19473.430093]  [<ffffffff813a98ee>] ? tty_init_dev+0x9e/0x200 
[19473.431462]  [<ffffffff8115ae78>] unmap_page_range+0x6c8/0x7f0 
[19473.432389]  [<ffffffff813c0419>] ? con_install+0x29/0xe0 
[19473.433242]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.434715]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.436037]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.437372]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.438627]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.439943]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.441343]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.442333]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.443160]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.444774]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.446135]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.447624]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.448939] BUG: Bad page map in process smbd  pte:ffffffff813aa644 pmd:40909067 
[19473.450791] addr:00007f2d791d9000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:15e 
[19473.453394] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.454784] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.455704] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.457263] Call Trace: 
[19473.457838]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.459411]  [<ffffffff813aa644>] ? tty_open+0x324/0x5e0 
[19473.460246]  [<ffffffff813aa644>] ? tty_open+0x324/0x5e0 
[19473.461633]  [<ffffffff8115ae78>] unmap_page_range+0x6c8/0x7f0 
[19473.462547]  [<ffffffff813c0419>] ? con_install+0x29/0xe0 
[19473.463403]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.464868]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.466065]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.467434]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.468679]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.470015]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.471430]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.473042]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.474353]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.475978]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.477342]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.478839]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.480137] BUG: Bad page map in process smbd  pte:ffffffff811a0e5d pmd:40909067 
[19473.482042] addr:00007f2d791da000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:15f 
[19473.484554] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.485818] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.486730] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.488271] Call Trace: 
[19473.488841]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.490407]  [<ffffffff811a0e5d>] ? chrdev_open+0x9d/0x180 
[19473.491797]  [<ffffffff811a0e5d>] ? chrdev_open+0x9d/0x180 
[19473.493213]  [<ffffffff8115a799>] vm_normal_page+0x69/0x80 
[19473.494632]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19473.495693]  [<ffffffff813c0419>] ? con_install+0x29/0xe0 
[19473.496534]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.497427]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.498771]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.500087]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.501339]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.502584]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.503444]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.504424]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.505755]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.507351]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.508706]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.510138]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.511579] BUG: Bad page map in process smbd  pte:ffffffff8119ab5f pmd:40909067 
[19473.513029] addr:00007f2d791db000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:160 
[19473.514926] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.516205] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.517689] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.519194] Call Trace: 
[19473.519735]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.521077]  [<ffffffff8119ab5f>] ? do_dentry_open+0x1ef/0x2a0 
[19473.521954]  [<ffffffff8119ab5f>] ? do_dentry_open+0x1ef/0x2a0 
[19473.522866]  [<ffffffff8115a799>] vm_normal_page+0x69/0x80 
[19473.524128]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19473.525029]  [<ffffffff811a0e5d>] ? chrdev_open+0x9d/0x180 
[19473.525998]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.526915]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.527759]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.529059]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.530183]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.531513]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.532886]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.533901]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.535137]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.536787]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.538096]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.539570]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.540976] BUG: Bad page map in process smbd  pte:ffffffff8119ac41 pmd:40909067 
[19473.542353] addr:00007f2d791dc000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:161 
[19473.545030] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.546376] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.547868] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.549441] Call Trace: 
[19473.550077]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.551556]  [<ffffffff8119ac41>] ? finish_open+0x31/0x40 
[19473.552812]  [<ffffffff8119ac41>] ? finish_open+0x31/0x40 
[19473.554190]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19473.555607]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19473.556521]  [<ffffffff8119ab5f>] ? do_dentry_open+0x1ef/0x2a0 
[19473.557436]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.558340]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.559150]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.560472]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.561694]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.563028]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.564440]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.565422]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.566762]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.568351]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.569422]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.570460]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.571789] BUG: Bad page map in process smbd  pte:219400000001 pmd:40909067 
[19473.573500] addr:00007f2d791dd000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:162 
[19473.575991] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.577253] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.578678] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.580170] Call Trace: 
[19473.580711]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.582202]  [<ffffffff8115a7a9>] vm_normal_page+0x79/0x80 
[19473.583521]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19473.584436]  [<ffffffff8119ac41>] ? finish_open+0x31/0x40 
[19473.585819]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.587107]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.588373]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.589690]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.590889]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.592150]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.593525]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.594511]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.595840]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.597453]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.598797]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.600299]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.601706] BUG: Bad page map in process smbd  pte:100b6df23 pmd:40909067 
[19473.603506] addr:00007f2d791de000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:163 
[19473.606041] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.607070] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.607937] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.608902] Call Trace: 
[19473.609440]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.610517]  [<ffffffff8115a799>] vm_normal_page+0x69/0x80 
[19473.611912]  [<ffffffff8115ab69>] unmap_page_range+0x3b9/0x7f0 
[19473.613330]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.614810]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.616098]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.617261]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.618106]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.618950]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.619811]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.620787]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.621875]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.623074]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.624095]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.625492]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.626855] BUG: Bad page map in process smbd  pte:5a5a5a5a5a5a5a5a pmd:40909067 
[19473.628762] addr:00007f2d791f2000 vm_flags:00000070 anon_vma:          (null) mapping:ffff88004a8586f8 index:177 
[19473.631418] vma->vm_ops->fault: filemap_fault+0x0/0x400 
[19473.632763] vma->vm_file->f_op->mmap: ext4_file_mmap+0x0/0x60 
[19473.634146] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 
[19473.635770] Call Trace: 
[19473.636376]  [<ffffffff811593b8>] print_bad_pte+0x1c8/0x240 
[19473.637799]  [<ffffffff8115ae78>] unmap_page_range+0x6c8/0x7f0 
[19473.639170]  [<ffffffff8115b021>] unmap_single_vma+0x81/0xf0 
[19473.640593]  [<ffffffff8115c059>] unmap_vmas+0x49/0x90 
[19473.641916]  [<ffffffff81164948>] exit_mmap+0x98/0x170 
[19473.643199]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.644450]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.645727]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.647057]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 
[19473.648560]  [<ffffffff81013438>] do_signal+0x48/0x5a0 
[19473.649861]  [<ffffffff81042d1f>] ? kvm_clock_get_cycles+0x1f/0x30 
[19473.651394]  [<ffffffff8101c27e>] ? fpu_finit+0x1e/0x30 
[19473.652707]  [<ffffffff81013a00>] do_notify_resume+0x70/0xa0 
[19473.654082]  [<ffffffff81611fbc>] retint_signal+0x48/0x8c 
[19473.655461] swap_free: Unused swap file entry 600000000000000 
[19473.656807] swap_free: Unused swap file entry 187fffc400204850 
[19473.658216] swap_free: Unused swap file entry 107fffc400192b80 
[19473.666275] ------------[ cut here ]------------ 
[19473.667020] kernel BUG at include/linux/mm.h:280! 
[19473.667020] invalid opcode: 0000 [#3] SMP  
[19473.667020] Modules linked in: binfmt_misc rfcomm bnep ipt_ULOG l2tp_ppp l2tp_netlink l2tp_core tun scsi_transport_iscsi nfc af_802154 rds atm pppoe pppox ppp_generic slhc af_key ip6table_filter ip6_tables iptable_filter ip_tables btrfs zlib_deflate raid6_pq xor vfat fat nfsv4 auth_rpcgss nfsv3 nfs_acl nfsv2 nfs lockd sunrpc fscache nfnetlink_queue nfnetlink_log nfnetlink bluetooth rfkill arc4 md4 nls_utf8 cifs dns_resolver fuse nf_tproxy_core nls_koi8_u nls_cp932 ts_kmp sctp sg xfs libcrc32c kvm_amd kvm i2c_piix4 virtio_balloon pcspkr ata_generic pata_acpi cirrus drm_kms_helper ttm drm ata_piix virtio_blk virtio_net i2c_core libata floppy dm_mirror dm_region_hash dm_log dm_mod [last unloaded: ipt_REJECT] 
[19473.667020] CPU 0  
[19473.667020] Pid: 8339, comm: smbd Tainted: G    B D      3.9.9 #1 Bochs Bochs 
[19473.667020] RIP: 0010:[<ffffffff8160714c>]  [<ffffffff8160714c>] put_page_testzero.part.9+0x4/0x6 
[19473.667020] RSP: 0018:ffff880035d6fb48  EFLAGS: 00010246 
[19473.667020] RAX: 0000000000000000 RBX: ffff88001261dc60 RCX: 0000000000000030 
[19473.667020] RDX: 0000000000000000 RSI: 000000000000000d RDI: ffff88001261dc50 
[19473.667020] RBP: ffff880035d6fb48 R08: ffffea00012aae20 R09: ffff88007fb95e80 
[19473.667020] R10: 00000000000000cc R11: 000000000000000e R12: 0000000000000000 
[19473.667020] R13: ffff88001261dcc0 R14: ffff88001261dc50 R15: ffffea0000000000 
[19473.667020] FS:  00007f2d7c1ae840(0000) GS:ffff88007fc00000(0000) knlGS:00000000f74dc6c0 
[19473.667020] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b 
[19473.667020] CR2: 00007f755e0a1688 CR3: 000000006ca32000 CR4: 00000000000006f0 
[19473.667020] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000 
[19473.667020] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400 
[19473.667020] Process smbd (pid: 8339, threadinfo ffff880035d6e000, task ffff880036dc0000) 
[19473.667020] Stack: 
[19473.667020]  ffff880035d6fba8 ffffffff81140964 0000000000000246 0000000100000000 
[19473.667020]  ffff88007d015e08 ffff880035d6fb70 ffff880035d6fb70 000000000000000e 
[19473.667020]  ffffea0000d15a00 0000000000000076 ffff88001261dc50 000000000000000e 
[19473.667020] Call Trace: 
[19473.667020]  [<ffffffff81140964>] release_pages+0x214/0x220 
[19473.667020]  [<ffffffff8116f1cd>] free_pages_and_swap_cache+0xad/0xd0 
[19473.667020]  [<ffffffff81159cdc>] tlb_flush_mmu+0x5c/0xa0 
[19473.667020]  [<ffffffff81159d3c>] tlb_finish_mmu+0x1c/0x50 
[19473.667020]  [<ffffffff81164977>] exit_mmap+0xc7/0x170 
[19473.667020]  [<ffffffff8105e227>] mmput+0x67/0xf0 
[19473.667020]  [<ffffffff81066788>] do_exit+0x278/0xa20 
[19473.667020]  [<ffffffff81066faf>] do_group_exit+0x3f/0xa0 
[19473.667020]  [<ffffffff81075d9d>] get_signal_to_deliver+0x1ad/0x5c0 

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
