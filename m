From: Jann Horn <jann@thejh.net>
Subject: [PATCH v2 0/3] fix SELinux W^X bypass via ptrace
Date: Thu, 29 Sep 2016 00:54:38 +0200
Message-ID: <1475103281-7989-1-git-send-email-jann@thejh.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: owner-linux-security-module@vger.kernel.org
To: security@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>
Cc: Nick Kralevich <nnk@google.com>, Janis Danisevskis <jdanis@google.com>, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

This fixes a bypass of SELinux' W^X protection via ptrace.
For more details, see the commit messages of patches 2/3 and 3/3.

Jann Horn (3):
  fs/exec: don't force writing memory access
  mm: add LSM hook for writes to readonly memory
  selinux: require EXECMEM for forced ptrace poke

 drivers/gpu/drm/etnaviv/etnaviv_gem.c   |  3 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c |  2 +-
 drivers/infiniband/core/umem_odp.c      |  4 +-
 fs/exec.c                               |  4 +-
 fs/proc/base.c                          | 68 +++++++++++++++++++++-------
 fs/proc/internal.h                      |  4 +-
 fs/proc/task_mmu.c                      |  4 +-
 fs/proc/task_nommu.c                    |  2 +-
 include/linux/lsm_hooks.h               |  9 ++++
 include/linux/mm.h                      | 12 ++++-
 include/linux/sched.h                   |  4 +-
 include/linux/security.h                | 10 +++++
 kernel/events/uprobes.c                 |  6 ++-
 kernel/fork.c                           |  6 ++-
 mm/gup.c                                | 80 +++++++++++++++++++++++++--------
 mm/memory.c                             | 22 ++++++---
 mm/nommu.c                              | 22 +++++----
 mm/process_vm_access.c                  |  8 ++--
 security/security.c                     |  8 ++++
 security/selinux/hooks.c                | 15 +++++++
 security/tomoyo/domain.c                |  2 +-
 virt/kvm/async_pf.c                     |  3 +-
 virt/kvm/kvm_main.c                     |  9 ++--
 23 files changed, 230 insertions(+), 77 deletions(-)

-- 
2.1.4

