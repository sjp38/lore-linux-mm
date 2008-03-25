Subject: [RFC/PATCH 00/15 v3] kvm on big iron
From: Carsten Otte <cotte@de.ibm.com>
In-Reply-To: <1206205354.7177.82.camel@cotte.boeblingen.de.ibm.com>
References: <1206030270.6690.51.camel@cotte.boeblingen.de.ibm.com>
	 <1206205354.7177.82.camel@cotte.boeblingen.de.ibm.com>
Content-Type: text/plain
Date: Tue, 25 Mar 2008 18:47:07 +0100
Message-Id: <1206467227.6507.36.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: virtualization@lists.linux-foundation.org, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, os@de.ibm.com, borntraeger@de.ibm.com, hollisb@us.ibm.com, EHRHARDT@de.ibm.com, jeroney@us.ibm.com, aliguori@us.ibm.com, jblunck@suse.de, rvdheij@gmail.com, rusty@rustcorp.com.au, arnd@arndb.de, "Zhang, Xiantao" <xiantao.zhang@intel.com>, oliver.paukstadt@millenux.com
List-ID: <linux-mm.kvack.org>

Many thanks for the review feedback we have received so far,
and many thanks to Andrew for reviewing our common code memory
management changes. I do greatly appreciate that :-).

All important parts have been reviewed, all review feedback has been
integrated in the code. Therefore we would like to ask for inclusion of
our work into kvm.git.

Changes from Version 1:
- include feedback from Randy Dunlap on the documentation
- include feedback from Jeremy Fitzhardinge, the prototype for dup_mm
  has moved to include/linux/sched.h
- rebase to current kvm.git hash g361be34. Thank you Avi for pulling
  in the fix we need, and for moving KVM_MAX_VCPUS to include/arch :-).

Changes from Version 2:
- include feedback from Rusty Russell on the virtio patch
- include fix for race s390_enable_sie() versus ptrace spotted by Dave 
  Hansen: we now do task_lock() to protect mm_users from update while 
  we're growing the page table. Good catch, Dave :-).
- rebase to current kvm.git hash g680615e

Todo list:
- I've created a patch for Christoph Helwig's feedback about symbolic
names for machine_flags. This change is independent of the kvm port, and
I will submit it for review to Martin.

The patch queue consists of the following patches:
[RFC/PATCH 01/15] preparation: provide hook to enable pgstes in user 
                               pagetable
[RFC/PATCH 02/15] preparation: host memory management changes for s390 
                               kvm
[RFC/PATCH 03/15] preparation: address of the 64bit extint parm in 
                               lowcore
[RFC/PATCH 04/15] preparation: split sysinfo defintions for kvm use
[RFC/PATCH 05/15] kvm-s390: s390 arch backend for the kvm kernel module
[RFC/PATCH 06/15] kvm-s390: sie intercept handling
[RFC/PATCH 07/15] kvm-s390: interrupt subsystem, cpu timer, waitpsw
[RFC/PATCH 08/15] kvm-s390: intercepts for privileged instructions
[RFC/PATCH 09/15] kvm-s390: interprocessor communication via sigp
[RFC/PATCH 10/15] kvm-s390: intercepts for diagnose instructions
[RFC/PATCH 11/15] kvm-s390: add kvm to kconfig on s390
[RFC/PATCH 12/15] kvm-s390: API documentation
[RFC/PATCH 13/15] kvm-s390: update maintainers
[RFC/PATCH 14/15] guest: detect when running on kvm
[RFC/PATCH 15/15] guest: virtio device support, and kvm hypercalls

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
