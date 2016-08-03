Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC1246B0253
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 14:21:04 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4so130496782wml.0
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 11:21:04 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id lk10si9305850wjb.59.2016.08.03.11.21.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 11:21:03 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id q128so37594842wma.1
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 11:21:03 -0700 (PDT)
Subject: Re: [PATCH 00/14] Present useful limits to user (v2)
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
From: Topi Miettinen <toiwoton@gmail.com>
Message-ID: <5808f9b5-6558-458b-0487-d20ecea0e903@gmail.com>
Date: Wed, 3 Aug 2016 18:20:20 +0000
MIME-Version: 1.0
In-Reply-To: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
Content-Type: multipart/mixed;
 boundary="------------A3E853F60BD52C9FDFF5D323"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Jonathan Corbet <corbet@lwn.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Alexander Graf <agraf@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>, Dave Goodell <dgoodell@cisco.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Williamson <alex.williamson@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Alexei Starovoitov <ast@kernel.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Balbir Singh <bsingharora@gmail.com>, Markus Elfring <elfring@users.sourceforge.net>, "David S. Miller" <davem@davemloft.net>, Nicolas Dichtel <nicolas.dichtel@6wind.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Jiri Slaby <jslaby@suse.cz>, Cyrill Gorcunov <gorcunov@openvz.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Carpenter <dan.carpenter@oracle.com>, Michael Kerrisk <mtk.manpages@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Marcus Gelderie <redmnic@gmail.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Joe Perches <joe@perches.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andi Kleen <ak@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Stas Sergeev <stsp@list.ru>, Amanieu d'Antras <amanieu@gmail.com>, Richard Weinberger <richard@nod.at>, Wang Xiaoqiang <wangxq10@lzu.edu.cn>, Helge Deller <deller@gmx.de>, Mateusz Guzik <mguzik@redhat.com>, Alex Thorlton <athorlton@sgi.com>, Ben Segall <bsegall@google.com>, John Stultz <john.stultz@linaro.org>, Rik van Riel <riel@redhat.com>, Eric B Munson <emunson@akamai.com>, Alexey Klimov <klimov.linux@gmail.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE (KVM) FOR POWERPC" <kvm-ppc@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE (KVM)" <kvm@vger.kernel.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "open list:INFINIBAND SUBSYSTEM" <linux-rdma@vger.kernel.org>, "open list:FILESYSTEMS (VFS and infrastructure)" <linux-fsdevel@vger.kernel.org>, "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>, "open list:BPF (Safe dynamic programs and tools)" <netdev@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

This is a multi-part message in MIME format.
--------------A3E853F60BD52C9FDFF5D323
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit

Hello,

I'm trying the systemtap approach and it looks promising. The script is
annotating strace-like output with capability, device access and RLIMIT
information. In the end there's a summary. Here's sample output from
wpa_supplicant run:

mprotect(0x7efebf140000, 16384, PROT_READ) = 0 [DATA 548864 -> 573440]
[AS 44986368 -> 45002752]
brk(0x55d9611f8000) = 94392125718528 missing
[Capabilities=CAP_SYS_ADMIN] [AS 45002752 -> 45010944]
open(0x55d960716462, O_RDWR) = 3 [DeviceAllow=/dev/char/1:3 rw ]
open("/dev/random", O_RDONLY|O_NONBLOCK) = 3 [DeviceAllow=/dev/char/1:8 r ]
socket(PF_LOCAL, SOCK_STREAM|SOCK_CLOEXEC, 0) = 4
[RestrictAddressFamilies=AF_UNIX] [NOFILE 3 -> 4]
open("/etc/wpa_supplicant.conf", O_RDONLY) = 5 [NOFILE 4 -> 5]
socket(PF_NETLINK, SOCK_RAW, 0) = 5 [RestrictAddressFamilies=AF_NETLINK]
socket(PF_NETLINK, SOCK_RAW|SOCK_CLOEXEC, 16) = 6
[RestrictAddressFamilies=AF_NETLINK] [NOFILE 5 -> 6]
socket(PF_NETLINK, SOCK_RAW|SOCK_CLOEXEC, 16) = 7
[RestrictAddressFamilies=AF_NETLINK] [NOFILE 6 -> 7]
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 8
[RestrictAddressFamilies=AF_INET] [NOFILE 7 -> 8]
open("/dev/rfkill", O_RDONLY) = 9 [DeviceAllow=/dev/char/10:58 r ]
[NOFILE 8 -> 9]
socket(PF_LOCAL, SOCK_DGRAM|SOCK_CLOEXEC, 0) = 10
[RestrictAddressFamilies=AF_UNIX] [NOFILE 9 -> 10]
sendmsg(6, 0x7ffc778f35b0, 0x0) = 36 [Capabilities=CAP_NET_ADMIN]

Summary:
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW
Consider also missing CapabilityBoundingSet=CAP_SYS_ADMIN
DeviceAllow=/dev/char/1:3 rw
DeviceAllow=/dev/char/1:8 r
DeviceAllow=/dev/char/10:58 r
DeviceAllow=/dev/char/1:9 r
LimitFSIZE=0
LimitDATA=577536
LimitSTACK=139264
LimitCORE=0
LimitNOFILE=15
LimitAS=45146112
LimitNPROC=171
LimitMEMLOCK=0
LimitSIGPENDING=0
LimitMSGQUEUE=0
LimitNICE=0
LimitRTPRIO=0
RestrictAddressFamilies=AF_UNIX AF_INET AF_NETLINK AF_PACKET
MemoryDenyWriteExecute=true

Some values are not correct. NPROC is wrong because staprun needs to be
run as root instead of the separate privileged user for wpa_supplicant
and that messes user process count. DATA/AS/STACK seems to be a bit off.
I can easily use this as systemd service configuration drop-in otherwise.

Now, the relevant part for the kernel is that I'd like to analyze error
paths better, so the system calls would be also annotated when there's a
failure when a RLIMIT is too tight. It would be easier to insert probes
if there was only one path for RLIMIT checks. Would it be OK to make the
function task_rlimit() a full check against the limit and also make it a
non-inlined function, just for improved probing purposes?

There's already error analysis for the capabilities, but there are some
false positive hits (like brk() complaining about missing CAP_SYS_ADMIN
above).

-Topi


--------------A3E853F60BD52C9FDFF5D323
Content-Type: text/plain; charset=UTF-8;
 name="strace.stp"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="strace.stp"

#! /bin/sh

# suppress some run-time errors here for cleaner output
//bin/true && exec stap --suppress-handler-errors --skip-badvars $0 ${1+"$@"}

/*
 * Compile:
 * stap -p4 -DSTP_NO_OVERLOAD -m strace
 * Run:
 * /usr/bin/staprun -R -c "/sbin/wpa_supplicant -u -O /run/wpa_supplicant -c /etc/wpa_supplicant.conf -i wlan0" -w /root/strace.ko only_capability_use=1 timestamp=0
 */

/* configuration options; set these with stap -G */
global follow_fork = 0   /* -Gfollow_fork=1 means trace descendant processes too */
global timestamp = 1     /* -Gtimestamp=0 means don't print a syscall timestamp */
global elapsed_time = 0  /* -Gelapsed_time=1 means print a syscall duration too */
global only_capability_use = 0 /* -Gonly_capability_use=1 means print only when capabilities are used */
global thread_argstr%
global thread_time%

global syscalls_nonreturn[2]
global capnames[64]
global used_caps
global missing_caps
global all_used_caps
global all_missing_caps
global accessed_devices[1000]
global all_accessed_devices[1000]
global highwatermark_fsize
global highwatermark_data
global highwatermark_stack
global highwatermark_core
global highwatermark_nproc
global highwatermark_nofile
global highwatermark_memlock
global highwatermark_as
global highwatermark_sigpending
global highwatermark_msgqueue
global highwatermark_nice
global highwatermark_rtprio
global old_highwatermark_fsize
global old_highwatermark_data
global old_highwatermark_stack
global old_highwatermark_core
global old_highwatermark_nproc
global old_highwatermark_nofile
global old_highwatermark_memlock
global old_highwatermark_as
global old_highwatermark_sigpending
global old_highwatermark_msgqueue
global old_highwatermark_nice
global old_highwatermark_rtprio
global afnames[64]
global used_afs
global missing_afs
global all_used_afs
global all_missing_afs
global no_memory_deny_write_execute
global all_memory_deny_write_execute = "true"
global print_syscall


probe begin 
  {
    /* list those syscalls that never .return */
    syscalls_nonreturn["exit"]=1
    syscalls_nonreturn["exit_group"]=1

    // grep '#define CAP_.*[0-9]+$' /usr/src/linux-headers*/include/uapi/linux/capability.h | awk '{ print "capnames[" $3 "] = \"" $2 "\";" }'
    capnames[0] = "CAP_CHOWN";
    capnames[1] = "CAP_DAC_OVERRIDE";
    capnames[2] = "CAP_DAC_READ_SEARCH";
    capnames[3] = "CAP_FOWNER";
    capnames[4] = "CAP_FSETID";
    capnames[5] = "CAP_KILL";
    capnames[6] = "CAP_SETGID";
    capnames[7] = "CAP_SETUID";
    capnames[8] = "CAP_SETPCAP";
    capnames[9] = "CAP_LINUX_IMMUTABLE";
    capnames[10] = "CAP_NET_BIND_SERVICE";
    capnames[11] = "CAP_NET_BROADCAST";
    capnames[12] = "CAP_NET_ADMIN";
    capnames[13] = "CAP_NET_RAW";
    capnames[14] = "CAP_IPC_LOCK";
    capnames[15] = "CAP_IPC_OWNER";
    capnames[16] = "CAP_SYS_MODULE";
    capnames[17] = "CAP_SYS_RAWIO";
    capnames[18] = "CAP_SYS_CHROOT";
    capnames[19] = "CAP_SYS_PTRACE";
    capnames[20] = "CAP_SYS_PACCT";
    capnames[21] = "CAP_SYS_ADMIN";
    capnames[22] = "CAP_SYS_BOOT";
    capnames[23] = "CAP_SYS_NICE";
    capnames[24] = "CAP_SYS_RESOURCE";
    capnames[25] = "CAP_SYS_TIME";
    capnames[26] = "CAP_SYS_TTY_CONFIG";
    capnames[27] = "CAP_MKNOD";
    capnames[28] = "CAP_LEASE";
    capnames[29] = "CAP_AUDIT_WRITE";
    capnames[30] = "CAP_AUDIT_CONTROL";
    capnames[31] = "CAP_SETFCAP";
    capnames[32] = "CAP_MAC_OVERRIDE";
    capnames[33] = "CAP_MAC_ADMIN";
    capnames[34] = "CAP_SYSLOG";
    capnames[35] = "CAP_WAKE_ALARM";
    capnames[36] = "CAP_BLOCK_SUSPEND";
    capnames[37] = "CAP_AUDIT_READ";

    //grep '#define AF_.*' /usr/src/linux-headers-*/include/linux/socket.h | awk '{ print "afnames[" $3 "] = \"" $2 "\"" }'
    afnames[0] = "AF_UNSPEC"
    afnames[1] = "AF_UNIX"
    afnames[2] = "AF_INET"
    afnames[3] = "AF_AX25"
    afnames[4] = "AF_IPX"
    afnames[5] = "AF_APPLETALK"
    afnames[6] = "AF_NETROM"
    afnames[7] = "AF_BRIDGE"
    afnames[8] = "AF_ATMPVC"
    afnames[9] = "AF_X25"
    afnames[10] = "AF_INET6"
    afnames[11] = "AF_ROSE"
    afnames[12] = "AF_DECnet"
    afnames[13] = "AF_NETBEUI"
    afnames[14] = "AF_SECURITY"
    afnames[15] = "AF_KEY"
    afnames[16] = "AF_NETLINK"
    afnames[17] = "AF_PACKET"
    afnames[18] = "AF_ASH"
    afnames[19] = "AF_ECONET"
    afnames[20] = "AF_ATMSVC"
    afnames[21] = "AF_RDS"
    afnames[22] = "AF_SNA"
    afnames[23] = "AF_IRDA"
    afnames[24] = "AF_PPPOX"
    afnames[25] = "AF_WANPIPE"
    afnames[26] = "AF_LLC"
    afnames[27] = "AF_IB"
    afnames[28] = "AF_MPLS"
    afnames[29] = "AF_CAN"
    afnames[30] = "AF_TIPC"
    afnames[31] = "AF_BLUETOOTH"
    afnames[32] = "AF_IUCV"
    afnames[33] = "AF_RXRPC"
    afnames[34] = "AF_ISDN"
    afnames[35] = "AF_PHONET"
    afnames[36] = "AF_IEEE802154"
    afnames[37] = "AF_CAIF"
    afnames[38] = "AF_ALG"
    afnames[39] = "AF_NFC"
    afnames[40] = "AF_VSOCK"
    afnames[41] = "AF_KCM"
  }



function filter_p()
  {
    if (target() == 0) return 0; /* system-wide */
    if (!follow_fork && pid() != target()) return 1; /* single-process */
    if (follow_fork && !target_set_pid(pid())) return 1; /* multi-process */
    return 0;
  }

function caps_to_str(caps)
  {
    str = ""
    for (i = 0; i < 37; i++) # CAP_LAST_CAP
      if (caps & (1 << i)) {
        str .= capnames[i]
	if ((caps & ~((1 << (i + 1)) - 1)) != 0)
	  str .= " "
      }
    return str
  }

function dev_to_str(type, dev, access)
  {
    devs = "/dev/"
    if (type == 1) # DEV_BLOCK
      devs .= "block"
    else
      devs .= "char"
    devs .= sprintf("/%d:%d ", dev >> 32, dev & 0xffffffff)
    if (access & 2) # ACC_READ
      devs .= "r"
    if (access & 4) # ACC_WRITE
      devs .= "w"
    if (access & 1) # ACC_MKNOD
      devs .= "m"
    return devs
  }

function afs_to_str(afs)
  {
    str = ""
    for (i = 0; i < 42; i++) # MAX_AF
      if (afs & (1 << i)) {
        str .= afnames[i]
	if ((afs & ~((1 << (i + 1)) - 1)) != 0)
	  str .= " "
      }
    return str
  }

/* Capabilities */
probe kernel.function("cap_capable@security/commoncap.c").return
  {
    if (filter_p()) next;

    if ($return == 0 && $audit)
      used_caps |= 1 << $cap;
    else
      missing_caps |= 1 << $cap;
  }

/* Devices */
probe kernel.function("__devcgroup_check_permission@security/device_cgroup.c").return
  {
    if (filter_p()) next;

    if ($return == 0)
      accessed_devices[$type, $major << 32 | $minor] |= $access
  }

/* RLIMIT_FSIZE */
probe kernel.function("inode_newsize_ok@fs/attr.c").return
  {
    if (filter_p()) next;

    if ($return == 0 && highwatermark_fsize < $offset)
      highwatermark_fsize = $offset
  }

/* RLIMIT_DATA */
probe kernel.function("prctl_set_mm@kernel/sys.c").return
  {
    if (filter_p()) next;

    if ($return == 0 && highwatermark_data < $prctl_map->end_data - $prctl_map->start_data) {
      highwatermark_data = $prctl_map->end_data - $prctl_map->start_data
      print_syscall = 1
    }
  }

probe kernel.function("do_brk@mm/mmap.c").return
  {
    if (filter_p()) next;

    task = task_current()
    if ($return > 0 && highwatermark_data < task->mm->data_vm << 12) { # PAGE_SHIFT
      highwatermark_data = task->mm->data_vm << 12
      print_syscall = 1
    }
    if ($return > 0 && highwatermark_as < task->mm->total_vm << 12) {
      highwatermark_as = task->mm->total_vm << 12
      print_syscall = 1
    }
  }

/* also RLIMIT_STACK and RLIMIT_MEMLOCK */
probe kernel.function("vm_stat_account@mm/mmap.c").return
  {
    if (filter_p()) next;

    if (highwatermark_data < $mm->data_vm << 12) { # PAGE_SHIFT
      highwatermark_data = $mm->data_vm << 12
      print_syscall = 1
    }
    if (highwatermark_stack < $mm->stack_vm << 12) {
      highwatermark_stack = $mm->stack_vm << 12
      print_syscall = 1
    }
    if (highwatermark_memlock < atomic_long_read(&$mm->locked_vm) << 12) {
      highwatermark_memlock = atomic_long_read(&$mm->locked_vm) << 12
      print_syscall = 1
    }
    if (highwatermark_as < $mm->total_vm << 12) {
      highwatermark_as = $mm->total_vm << 12
      print_syscall = 1
    }
  }

/* RLIMIT_CORE */
probe kernel.function("dump_emit@fs/coredump.c").return
  {
    if (filter_p()) next;

    if (highwatermark_core < $cprm->written) {
      highwatermark_core = $cprm->written
      print_syscall = 1
    }
  }

/* RLIMIT_NPROC */
probe kernel.function("commit_creds@kernel/cred.c").return
  {
    if (filter_p()) next;

    if (highwatermark_nproc < atomic_read(&$new->user->processes)) {
      highwatermark_nproc = atomic_read(&$new->user->processes)
      print_syscall = 1
    }
  }

probe kernel.function("copy_process@kernel/fork.c").return
  {
    if (filter_p()) next;
    printf("return %d\n", $return);
    try {
    if (($return > 0 || $return < -1000) && $return->real_cred && $return->real_cred->user)
      printf("good return %d\n", $return);
      if (highwatermark_nproc < atomic_read(&$return->real_cred->user->processes)) {
	highwatermark_nproc = atomic_read(&$return->real_cred->user->processes)
	print_syscall = 1
      }
    } catch {}
  }

/* RLIMIT_NOFILE */
probe kernel.function("__alloc_fd@fs/file.c").return
  {
    if (filter_p()) next;

    if (($return >= 0 || $return < -1000) && highwatermark_nofile < $return) {
      highwatermark_nofile = $return
      print_syscall = 1
    }
  }

probe kernel.function("do_dup2@fs/file.c").return
  {
    if (filter_p()) next;

    if (($return >= 0 || $return < -1000) && highwatermark_nofile < $return) {
      highwatermark_nofile = $return
      print_syscall = 1
    }
  }

/* RLIMIT_MEMLOCK */
probe kernel.function("sys_bpf@kernel/bpf/syscall.c").return
  {
    if (filter_p()) next;

    task = task_current()
    user = task->real_cred->user
    if ($return == 0 && highwatermark_memlock < atomic_long_read(&user->locked_vm) << 12) { # PAGE_SHIFT
      highwatermark_memlock = atomic_long_read(&user->locked_vm) << 12
      print_syscall = 1
    }
  }

probe kernel.function("perf_mmap@kernel/events/core.c").return
  {
    if (filter_p()) next;

    task = task_current()
    if ($return == 0 && highwatermark_memlock < task->mm->pinned_vm << 12) { # PAGE_SHIFT
      highwatermark_memlock = task->mm->pinned_vm << 12
      print_syscall = 1
    }
  }

probe kernel.function("do_mlock@mm/mlock.c").return
  {
    if (filter_p()) next;

    task = task_current()
    if ($return == 0 && highwatermark_memlock < task->mm->locked_vm << 12) { # PAGE_SHIFT
      highwatermark_memlock = task->mm->locked_vm << 12
      print_syscall = 1
    }
  }

probe kernel.function("sys_mlockall@mm/mlock.c").return
  {
    if (filter_p()) next;

    task = task_current()
    if ($return == 0 && highwatermark_memlock < task->mm->total_vm << 12) { # PAGE_SHIFT
      highwatermark_memlock = task->mm->total_vm << 12
      print_syscall = 1
    }
  }

/* RLIMIT_SIGPENDING */
probe kernel.function("__sigqueue_alloc@kernel/signal.c").return
  {
    if (filter_p()) next;

    task = task_current()
    user = task->real_cred->user
    if ($return == 0 && highwatermark_sigpending < atomic_read(&user->sigpending)) {
      highwatermark_sigpending = atomic_read(&user->sigpending)
      print_syscall = 1
    }
  }

/* RLIMIT_MSGGQUEUE */
probe kernel.function("mqueue_get_inode@ipc/mqueue.c").return
  {
    if (filter_p()) next;

    task = task_current()
    user = task->real_cred->user
    if ($return == 0 && highwatermark_msgqueue < user->mq_bytes) {
      highwatermark_msgqueue = user->mq_bytes
      print_syscall = 1
    }
  }

/* RLIMIT_NICE */
probe kernel.function("set_user_nice@kernel/sched/core.c").return
  {
    if (filter_p()) next;

    if (highwatermark_nice < $nice) {
      highwatermark_nice = $nice
      print_syscall = 1
    }
  }

/* RLIMIT_RTPRIO */
probe kernel.function("__sched_setscheduler@kernel/sched/core.c").return
  {
    if (filter_p()) next;

    if (highwatermark_rtprio < $attr->sched_priority) {
      highwatermark_rtprio = $attr->sched_priority
      print_syscall = 1
    }
  }

/* socket address families */
probe kernel.function("__sock_create@net/socket.c").return
  {
    if (filter_p()) next;

    if ($return == 0) {
      used_afs |= 1 << $family
      print_syscall = 1
    } else if ($return == 93) { # EPROTONOSUPPORT
      missing_afs |= 1 << $family
      print_syscall = 1
    }
  }

/* mmap flags */
probe kernel.function("do_mmap@mm/mmap.c").return
  {
    if (filter_p()) next;

    if (($return >= 0 || $return < -1000) && ($flags & (2 | 4)) == (2 | 4)) { # PROT_WRITE | PROT_EXEC
      no_memory_deny_write_execute = 1
      print_syscall = 1
    }
  }

/* system call printing */
probe nd_syscall.* 
  {
    # TODO: filter out apparently-nested syscalls (that are implemented
    # in terms of each other within the kernel); PR6762

    if (filter_p()) next;

    thread_argstr[tid()]=argstr
    if (timestamp || elapsed_time)
      thread_time[tid()]=gettimeofday_us()

    if (name in syscalls_nonreturn)
      report(name,argstr,"")
  }

probe nd_syscall.*.return
  {
    if (filter_p()) next;

    report(name,thread_argstr[tid()],retstr)
  }

function report(syscall_name, syscall_argstr, syscall_retstr)
  {
    if (timestamp || elapsed_time)
      {
        now = gettimeofday_us()
        then = thread_time[tid()]

        if (timestamp)
          prefix=sprintf("%s.%06d ", ctime(then/1000000), then%1000000)

        if (elapsed_time && (now>then)) {
          diff = now-then
          suffix=sprintf(" <%d.%06d>", diff/1000000, diff%1000000)
        }

        delete thread_time[tid()]
      }

    /* add a thread-id string in lots of cases, except if
       stap strace.stp -c SINGLE_THREADED_CMD */
    if (tid() != target()) {
      prefix .= sprintf("%s[%d] ", execname(), tid())
    }

    if (used_caps) {
       suffix .= " [Capabilities=" . caps_to_str(used_caps) . "]"
       all_used_caps |= used_caps
       print_syscall = 1
    }		       
    if (missing_caps) {
       suffix .= " missing [Capabilities=" . caps_to_str(missing_caps) . "]"
       all_missing_caps |= missing_caps
       print_syscall = 1
    }		       

    foreach ([type, dev] in accessed_devices) {
      devs .= dev_to_str(type, dev, accessed_devices[type, dev]) . " "
      if (has_devs == 0) {
        has_devs = 1
	print_syscall = 1
	devs = " [DeviceAllow=" . devs
      }
      all_accessed_devices[type, dev] = accessed_devices[type, dev];
    }
    if (has_devs) {
      devs .= "]"
      suffix .= devs
    }

    if (used_afs) {
      suffix .= " [RestrictAddressFamilies=" . afs_to_str(used_afs) . "]"
      all_used_afs |= used_afs
      print_syscall = 1
    }		       
    if (missing_afs) {
      suffix .= " missing [RestrictAddressFamilies=" . afs_to_str(missing_afs) . "]"
      all_missing_afs |= missing_afs
      print_syscall = 1
    }		       

    if (no_memory_deny_write_execute) {
      suffix .= " [MemoryDenyWriteExecute=false]"
      all_memory_deny_write_execute = "false"
    }		       

    if (highwatermark_fsize > old_highwatermark_fsize) {
      suffix .= sprintf(" [FSIZE %d -> %d]", old_highwatermark_fsize, highwatermark_fsize)
      old_highwatermark_fsize = highwatermark_fsize
    }
    if (highwatermark_data > old_highwatermark_data) {
      suffix .= sprintf(" [DATA %d -> %d]", old_highwatermark_data, highwatermark_data)
      old_highwatermark_data = highwatermark_data
    }
    if (highwatermark_stack > old_highwatermark_stack) {
      suffix .= sprintf(" [STACK %d -> %d]", old_highwatermark_stack, highwatermark_stack)
      old_highwatermark_stack = highwatermark_stack
    }
    if (highwatermark_core > old_highwatermark_core) {
      suffix .= sprintf(" [CORE %d -> %d]", old_highwatermark_core, highwatermark_core)
      old_highwatermark_core = highwatermark_core
    }
    if (highwatermark_nofile > old_highwatermark_nofile) {
      suffix .= sprintf(" [NOFILE %d -> %d]", old_highwatermark_nofile, highwatermark_nofile)
      old_highwatermark_nofile = highwatermark_nofile
    }
    if (highwatermark_as > old_highwatermark_as) {
      suffix .= sprintf(" [AS %d -> %d]", old_highwatermark_as, highwatermark_as)
      old_highwatermark_as = highwatermark_as
    }
    if (highwatermark_nproc > old_highwatermark_nproc) {
      suffix .= sprintf(" [NPROC %d -> %d]", old_highwatermark_nproc, highwatermark_nproc)
      old_highwatermark_nproc = highwatermark_nproc
    }
    if (highwatermark_memlock > old_highwatermark_memlock) {
      suffix .= sprintf(" [MEMLOCK %d -> %d]", old_highwatermark_memlock, highwatermark_memlock)
      old_highwatermark_memlock = highwatermark_memlock
    }
    if (highwatermark_sigpending > old_highwatermark_sigpending) {
      suffix .= sprintf(" [SIGPENDING %d -> %d]", old_highwatermark_sigpending, highwatermark_sigpending)
      old_highwatermark_sigpending = highwatermark_sigpending
    }
    if (highwatermark_msgqueue > old_highwatermark_msgqueue) {
      suffix .= sprintf(" [MSGQUEUE %d -> %d]", old_highwatermark_msgqueue, highwatermark_msgqueue)
      old_highwatermark_msgqueue = highwatermark_msgqueue
    }
    if (highwatermark_nice > old_highwatermark_nice) {
      suffix .= sprintf(" [NICE %d -> %d]", old_highwatermark_nice, highwatermark_nice)
      old_highwatermark_nice = highwatermark_nice
    }
    if (highwatermark_rtprio > old_highwatermark_rtprio) {
      suffix .= sprintf(" [RTPRIO %d -> %d]", old_highwatermark_rtprio, highwatermark_rtprio)
      old_highwatermark_rtprio = highwatermark_rtprio
    }

    if (!only_capability_use || print_syscall)
        printf("%s%s(%s) = %s%s\n",
             prefix, 
             syscall_name, syscall_argstr, syscall_retstr,
	     suffix)

    used_caps = 0
    missing_caps = 0
    used_afs = 0
    print_syscall = 0
    no_memory_deny_write_execute = 0
    delete accessed_devices

    delete thread_argstr[tid()]
  }

probe end
  {
    printf("\nSummary:\n")
    printf("CapabilityBoundingSet=%s\n", caps_to_str(all_used_caps))
    if (all_missing_caps)
	    printf("Consider also missing CapabilityBoundingSet=%s\n", caps_to_str(all_missing_caps))
    foreach ([type, dev] in all_accessed_devices)
      printf("DeviceAllow=%s\n", dev_to_str(type, dev, all_accessed_devices[type, dev]))
    printf("LimitFSIZE=%d\n", highwatermark_fsize)
    printf("LimitDATA=%d\n", highwatermark_data)
    printf("LimitSTACK=%d\n", highwatermark_stack)
    printf("LimitCORE=%d\n", highwatermark_core)
    printf("LimitNOFILE=%d\n", highwatermark_nofile)
    printf("LimitAS=%d\n", highwatermark_as)
    printf("LimitNPROC=%d\n", highwatermark_nproc)
    printf("LimitMEMLOCK=%d\n", highwatermark_memlock)
    printf("LimitSIGPENDING=%d\n", highwatermark_sigpending)
    printf("LimitMSGQUEUE=%d\n", highwatermark_msgqueue)
    printf("LimitNICE=%d\n", highwatermark_nice)
    printf("LimitRTPRIO=%d\n", highwatermark_rtprio)
    printf("RestrictAddressFamilies=%s\n", afs_to_str(all_used_afs))
    if (all_missing_afs)
	    printf("Consider also missing RestrictAddressFamilies=%s\n", afs_to_str(all_missing_afs))
    printf("MemoryDenyWriteExecute=%s\n", all_memory_deny_write_execute)
  }
--------------A3E853F60BD52C9FDFF5D323--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
