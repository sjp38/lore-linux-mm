Subject: [RFC/PATCH 00/15 v2] kvm on big iron
From: Carsten Otte <cotte@de.ibm.com>
In-Reply-To: <1206030270.6690.51.camel@cotte.boeblingen.de.ibm.com>
References: <1206030270.6690.51.camel@cotte.boeblingen.de.ibm.com>
Content-Type: text/plain
Date: Sat, 22 Mar 2008 18:02:34 +0100
Message-Id: <1206205354.7177.82.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: virtualization@lists.linux-foundation.org, kvm-devel@lists.sourceforge.net, Avi Kivity <avi@qumranet.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, Linux Memory Management List <linux-mm@kvack.org>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, os@de.ibm.com, borntraeger@de.ibm.com, hollisb@us.ibm.com, EHRHARDT@de.ibm.com, jeroney@us.ibm.com, aliguori@us.ibm.com, jblunck@suse.de, rvdheij@gmail.com, rusty@rustcorp.com.au, arnd@arndb.de, "Zhang, Xiantao" <xiantao.zhang@intel.com>
List-ID: <linux-mm.kvack.org>

This patch series introduces a backend for kvm to run on IBM System z
machines (aka s390x) that uses the mainframe's sie virtualization
capability. Many thanks for the review feedback we have received so far,
I do greatly appreciate it!

The first submission didn't draw much attention of elder vm magicians on
linux-mm. I am adding Nick, Hugh and Andrew explicitly to the first two
patches. Please do comment on our common code change buried in there. Is
this acceptable for you? Who else does need to review them?

Changes from the Version 1:
- include Feedback from Randy Dunlap on the Documentation
- include Feedback from Jeremy Fitzhardinge, the prototype for dup_mm
  has moved to include/linux/sched.h
- rebase to current kvm.git hash g361be34. Thank you Avi for pulling
  in the fix we need, and for moving KVM_MAX_VCPUS to include/arch :-).

Todo list:
- I've created a patch for Christoph Helwig's feedback about symbolic
names for machine_flags. This change is independent of the kvm port, and
I will submit it for review to Martin.
- Rusty Russell has provided feedback that improves patch #15. Christian
is looking into that and will likely update that patch. If this goes in
before, we can safely do an add-on patch on top of #15.
- an open comment from Dave Hansen about a possible race enable_sie
versus ptrace in patch #1 exceeds my basic vm knowledge and needs to be
answered by Martin or Heiko

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
