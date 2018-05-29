Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C10086B0005
	for <linux-mm@kvack.org>; Tue, 29 May 2018 12:18:31 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id e18-v6so4128220pgt.3
        for <linux-mm@kvack.org>; Tue, 29 May 2018 09:18:31 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id b65-v6si10852147pgc.139.2018.05.29.09.18.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 09:18:29 -0700 (PDT)
Date: Wed, 30 May 2018 00:17:45 +0800
From: kbuild test robot <lkp@intel.com>
Subject: [linux-stable-rc:linux-4.14.y 3879/4798] ipc/mqueue.c:1531:1: note:
 in expansion of macro 'COMPAT_SYSCALL_DEFINE3'
Message-ID: <201805300041.XKo2UNvU%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="opJtzjQTFsWo+cga"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: kbuild-all@01.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Sergey,

First bad commit (maybe != root cause):

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable-rc.git linux-4.14.y
head:   9fcb9d72e8a3a813caae6e2fac43a73603d75abd
commit: 8e99c881e497e7f7528f693c563e204ae888a846 [3879/4798] tools/lib/subcmd/pager.c: do not alias select() params
config: x86_64-acpi-redef (attached as .config)
compiler: gcc-8 (Debian 8.1.0-3) 8.1.0
reproduce:
        git checkout 8e99c881e497e7f7528f693c563e204ae888a846
        # save the attached .config to linux build tree
        make ARCH=x86_64 

All warnings (new ones prefixed by >>):

   In file included from ipc/mqueue.c:29:
   include/linux/syscalls.h:211:18: warning: 'sys_mq_open' alias between functions of incompatible types 'long int(const char *, int,  umode_t,  struct mq_attr *)' {aka 'long int(const char *, int,  short unsigned int,  struct mq_attr *)'} and 'long int(long int,  long int,  long int,  long int)' [-Wattribute-alias]
     asmlinkage long sys##name(__MAP(x,__SC_DECL,__VA_ARGS__)) \
                     ^~~
   include/linux/syscalls.h:207:2: note: in expansion of macro '__SYSCALL_DEFINEx'
     __SYSCALL_DEFINEx(x, sname, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~
   include/linux/syscalls.h:199:36: note: in expansion of macro 'SYSCALL_DEFINEx'
    #define SYSCALL_DEFINE4(name, ...) SYSCALL_DEFINEx(4, _##name, __VA_ARGS__)
                                       ^~~~~~~~~~~~~~~
   ipc/mqueue.c:847:1: note: in expansion of macro 'SYSCALL_DEFINE4'
    SYSCALL_DEFINE4(mq_open, const char __user *, u_name, int, oflag, umode_t, mode,
    ^~~~~~~~~~~~~~~
   include/linux/syscalls.h:215:18: note: aliased declaration here
     asmlinkage long SyS##name(__MAP(x,__SC_LONG,__VA_ARGS__)) \
                     ^~~
   include/linux/syscalls.h:207:2: note: in expansion of macro '__SYSCALL_DEFINEx'
     __SYSCALL_DEFINEx(x, sname, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~
   include/linux/syscalls.h:199:36: note: in expansion of macro 'SYSCALL_DEFINEx'
    #define SYSCALL_DEFINE4(name, ...) SYSCALL_DEFINEx(4, _##name, __VA_ARGS__)
                                       ^~~~~~~~~~~~~~~
   ipc/mqueue.c:847:1: note: in expansion of macro 'SYSCALL_DEFINE4'
    SYSCALL_DEFINE4(mq_open, const char __user *, u_name, int, oflag, umode_t, mode,
    ^~~~~~~~~~~~~~~
   In file included from include/linux/ethtool.h:17,
                    from include/linux/netdevice.h:41,
                    from include/net/sock.h:51,
                    from ipc/mqueue.c:42:
   include/linux/compat.h:51:18: warning: 'compat_sys_mq_getsetattr' alias between functions of incompatible types 'long int(mqd_t,  const struct compat_mq_attr *, struct compat_mq_attr *)' {aka 'long int(int,  const struct compat_mq_attr *, struct compat_mq_attr *)'} and 'long int(long int,  long int,  long int)' [-Wattribute-alias]
     asmlinkage long compat_sys##name(__MAP(x,__SC_DECL,__VA_ARGS__))\
                     ^~~~~~~~~~
   include/linux/compat.h:42:2: note: in expansion of macro 'COMPAT_SYSCALL_DEFINEx'
     COMPAT_SYSCALL_DEFINEx(3, _##name, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~~~~~~
>> ipc/mqueue.c:1531:1: note: in expansion of macro 'COMPAT_SYSCALL_DEFINE3'
    COMPAT_SYSCALL_DEFINE3(mq_getsetattr, mqd_t, mqdes,
    ^~~~~~~~~~~~~~~~~~~~~~
   include/linux/compat.h:55:18: note: aliased declaration here
     asmlinkage long compat_SyS##name(__MAP(x,__SC_LONG,__VA_ARGS__))\
                     ^~~~~~~~~~
   include/linux/compat.h:42:2: note: in expansion of macro 'COMPAT_SYSCALL_DEFINEx'
     COMPAT_SYSCALL_DEFINEx(3, _##name, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~~~~~~
>> ipc/mqueue.c:1531:1: note: in expansion of macro 'COMPAT_SYSCALL_DEFINE3'
    COMPAT_SYSCALL_DEFINE3(mq_getsetattr, mqd_t, mqdes,
    ^~~~~~~~~~~~~~~~~~~~~~
   include/linux/compat.h:51:18: warning: 'compat_sys_mq_notify' alias between functions of incompatible types 'long int(mqd_t,  const struct compat_sigevent *)' {aka 'long int(int,  const struct compat_sigevent *)'} and 'long int(long int,  long int)' [-Wattribute-alias]
     asmlinkage long compat_sys##name(__MAP(x,__SC_DECL,__VA_ARGS__))\
                     ^~~~~~~~~~
   include/linux/compat.h:40:2: note: in expansion of macro 'COMPAT_SYSCALL_DEFINEx'
     COMPAT_SYSCALL_DEFINEx(2, _##name, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~~~~~~
>> ipc/mqueue.c:1517:1: note: in expansion of macro 'COMPAT_SYSCALL_DEFINE2'
    COMPAT_SYSCALL_DEFINE2(mq_notify, mqd_t, mqdes,
    ^~~~~~~~~~~~~~~~~~~~~~
   include/linux/compat.h:55:18: note: aliased declaration here
     asmlinkage long compat_SyS##name(__MAP(x,__SC_LONG,__VA_ARGS__))\
                     ^~~~~~~~~~
   include/linux/compat.h:40:2: note: in expansion of macro 'COMPAT_SYSCALL_DEFINEx'
     COMPAT_SYSCALL_DEFINEx(2, _##name, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~~~~~~
>> ipc/mqueue.c:1517:1: note: in expansion of macro 'COMPAT_SYSCALL_DEFINE2'
    COMPAT_SYSCALL_DEFINE2(mq_notify, mqd_t, mqdes,
    ^~~~~~~~~~~~~~~~~~~~~~
   include/linux/compat.h:51:18: warning: 'compat_sys_mq_timedreceive' alias between functions of incompatible types 'long int(mqd_t,  char *, compat_size_t,  unsigned int *, const struct compat_timespec *)' {aka 'long int(int,  char *, unsigned int,  unsigned int *, const struct compat_timespec *)'} and 'long int(long int,  long int,  long int,  long int,  long int)' [-Wattribute-alias]
     asmlinkage long compat_sys##name(__MAP(x,__SC_DECL,__VA_ARGS__))\
                     ^~~~~~~~~~
   include/linux/compat.h:46:2: note: in expansion of macro 'COMPAT_SYSCALL_DEFINEx'
     COMPAT_SYSCALL_DEFINEx(5, _##name, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~~~~~~
>> ipc/mqueue.c:1502:1: note: in expansion of macro 'COMPAT_SYSCALL_DEFINE5'
    COMPAT_SYSCALL_DEFINE5(mq_timedreceive, mqd_t, mqdes,
    ^~~~~~~~~~~~~~~~~~~~~~
   include/linux/compat.h:55:18: note: aliased declaration here
     asmlinkage long compat_SyS##name(__MAP(x,__SC_LONG,__VA_ARGS__))\
                     ^~~~~~~~~~
   include/linux/compat.h:46:2: note: in expansion of macro 'COMPAT_SYSCALL_DEFINEx'
     COMPAT_SYSCALL_DEFINEx(5, _##name, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~~~~~~
>> ipc/mqueue.c:1502:1: note: in expansion of macro 'COMPAT_SYSCALL_DEFINE5'
    COMPAT_SYSCALL_DEFINE5(mq_timedreceive, mqd_t, mqdes,
    ^~~~~~~~~~~~~~~~~~~~~~
   include/linux/compat.h:51:18: warning: 'compat_sys_mq_timedsend' alias between functions of incompatible types 'long int(mqd_t,  const char *, compat_size_t,  unsigned int,  const struct compat_timespec *)' {aka 'long int(int,  const char *, unsigned int,  unsigned int,  const struct compat_timespec *)'} and 'long int(long int,  long int,  long int,  long int,  long int)' [-Wattribute-alias]
     asmlinkage long compat_sys##name(__MAP(x,__SC_DECL,__VA_ARGS__))\
                     ^~~~~~~~~~
   include/linux/compat.h:46:2: note: in expansion of macro 'COMPAT_SYSCALL_DEFINEx'
     COMPAT_SYSCALL_DEFINEx(5, _##name, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~~~~~~
   ipc/mqueue.c:1487:1: note: in expansion of macro 'COMPAT_SYSCALL_DEFINE5'
    COMPAT_SYSCALL_DEFINE5(mq_timedsend, mqd_t, mqdes,
    ^~~~~~~~~~~~~~~~~~~~~~
   include/linux/compat.h:55:18: note: aliased declaration here
     asmlinkage long compat_SyS##name(__MAP(x,__SC_LONG,__VA_ARGS__))\
                     ^~~~~~~~~~
   include/linux/compat.h:46:2: note: in expansion of macro 'COMPAT_SYSCALL_DEFINEx'
     COMPAT_SYSCALL_DEFINEx(5, _##name, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~~~~~~
   ipc/mqueue.c:1487:1: note: in expansion of macro 'COMPAT_SYSCALL_DEFINE5'
    COMPAT_SYSCALL_DEFINE5(mq_timedsend, mqd_t, mqdes,
    ^~~~~~~~~~~~~~~~~~~~~~
   include/linux/compat.h:51:18: warning: 'compat_sys_mq_open' alias between functions of incompatible types 'long int(const char *, int,  compat_mode_t,  struct compat_mq_attr *)' {aka 'long int(const char *, int,  short unsigned int,  struct compat_mq_attr *)'} and 'long int(long int,  long int,  long int,  long int)' [-Wattribute-alias]
     asmlinkage long compat_sys##name(__MAP(x,__SC_DECL,__VA_ARGS__))\
                     ^~~~~~~~~~
   include/linux/compat.h:44:2: note: in expansion of macro 'COMPAT_SYSCALL_DEFINEx'
     COMPAT_SYSCALL_DEFINEx(4, _##name, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~~~~~~
>> ipc/mqueue.c:1464:1: note: in expansion of macro 'COMPAT_SYSCALL_DEFINE4'
    COMPAT_SYSCALL_DEFINE4(mq_open, const char __user *, u_name,
    ^~~~~~~~~~~~~~~~~~~~~~
   include/linux/compat.h:55:18: note: aliased declaration here
     asmlinkage long compat_SyS##name(__MAP(x,__SC_LONG,__VA_ARGS__))\
                     ^~~~~~~~~~
   include/linux/compat.h:44:2: note: in expansion of macro 'COMPAT_SYSCALL_DEFINEx'
     COMPAT_SYSCALL_DEFINEx(4, _##name, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~~~~~~
>> ipc/mqueue.c:1464:1: note: in expansion of macro 'COMPAT_SYSCALL_DEFINE4'
    COMPAT_SYSCALL_DEFINE4(mq_open, const char __user *, u_name,
    ^~~~~~~~~~~~~~~~~~~~~~
   In file included from ipc/mqueue.c:29:
   include/linux/syscalls.h:211:18: warning: 'sys_mq_getsetattr' alias between functions of incompatible types 'long int(mqd_t,  const struct mq_attr *, struct mq_attr *)' {aka 'long int(int,  const struct mq_attr *, struct mq_attr *)'} and 'long int(long int,  long int,  long int)' [-Wattribute-alias]
     asmlinkage long sys##name(__MAP(x,__SC_DECL,__VA_ARGS__)) \
                     ^~~
   include/linux/syscalls.h:207:2: note: in expansion of macro '__SYSCALL_DEFINEx'
     __SYSCALL_DEFINEx(x, sname, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~
   include/linux/syscalls.h:198:36: note: in expansion of macro 'SYSCALL_DEFINEx'
    #define SYSCALL_DEFINE3(name, ...) SYSCALL_DEFINEx(3, _##name, __VA_ARGS__)
                                       ^~~~~~~~~~~~~~~
   ipc/mqueue.c:1398:1: note: in expansion of macro 'SYSCALL_DEFINE3'
    SYSCALL_DEFINE3(mq_getsetattr, mqd_t, mqdes,
    ^~~~~~~~~~~~~~~
   include/linux/syscalls.h:215:18: note: aliased declaration here
     asmlinkage long SyS##name(__MAP(x,__SC_LONG,__VA_ARGS__)) \
                     ^~~
   include/linux/syscalls.h:207:2: note: in expansion of macro '__SYSCALL_DEFINEx'
     __SYSCALL_DEFINEx(x, sname, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~
   include/linux/syscalls.h:198:36: note: in expansion of macro 'SYSCALL_DEFINEx'
    #define SYSCALL_DEFINE3(name, ...) SYSCALL_DEFINEx(3, _##name, __VA_ARGS__)
                                       ^~~~~~~~~~~~~~~
   ipc/mqueue.c:1398:1: note: in expansion of macro 'SYSCALL_DEFINE3'
    SYSCALL_DEFINE3(mq_getsetattr, mqd_t, mqdes,
    ^~~~~~~~~~~~~~~
   include/linux/syscalls.h:211:18: warning: 'sys_mq_notify' alias between functions of incompatible types 'long int(mqd_t,  const struct sigevent *)' {aka 'long int(int,  const struct sigevent *)'} and 'long int(long int,  long int)' [-Wattribute-alias]
     asmlinkage long sys##name(__MAP(x,__SC_DECL,__VA_ARGS__)) \
                     ^~~
   include/linux/syscalls.h:207:2: note: in expansion of macro '__SYSCALL_DEFINEx'
     __SYSCALL_DEFINEx(x, sname, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~
   include/linux/syscalls.h:197:36: note: in expansion of macro 'SYSCALL_DEFINEx'
    #define SYSCALL_DEFINE2(name, ...) SYSCALL_DEFINEx(2, _##name, __VA_ARGS__)
                                       ^~~~~~~~~~~~~~~
   ipc/mqueue.c:1342:1: note: in expansion of macro 'SYSCALL_DEFINE2'
    SYSCALL_DEFINE2(mq_notify, mqd_t, mqdes,
    ^~~~~~~~~~~~~~~
   include/linux/syscalls.h:215:18: note: aliased declaration here
     asmlinkage long SyS##name(__MAP(x,__SC_LONG,__VA_ARGS__)) \
                     ^~~
   include/linux/syscalls.h:207:2: note: in expansion of macro '__SYSCALL_DEFINEx'
     __SYSCALL_DEFINEx(x, sname, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~
   include/linux/syscalls.h:197:36: note: in expansion of macro 'SYSCALL_DEFINEx'
    #define SYSCALL_DEFINE2(name, ...) SYSCALL_DEFINEx(2, _##name, __VA_ARGS__)
                                       ^~~~~~~~~~~~~~~
   ipc/mqueue.c:1342:1: note: in expansion of macro 'SYSCALL_DEFINE2'
    SYSCALL_DEFINE2(mq_notify, mqd_t, mqdes,
    ^~~~~~~~~~~~~~~
   include/linux/syscalls.h:211:18: warning: 'sys_mq_timedreceive' alias between functions of incompatible types 'long int(mqd_t,  char *, size_t,  unsigned int *, const struct timespec *)' {aka 'long int(int,  char *, long unsigned int,  unsigned int *, const struct timespec *)'} and 'long int(long int,  long int,  long int,  long int,  long int)' [-Wattribute-alias]
     asmlinkage long sys##name(__MAP(x,__SC_DECL,__VA_ARGS__)) \
                     ^~~
   include/linux/syscalls.h:207:2: note: in expansion of macro '__SYSCALL_DEFINEx'
     __SYSCALL_DEFINEx(x, sname, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~
   include/linux/syscalls.h:200:36: note: in expansion of macro 'SYSCALL_DEFINEx'
    #define SYSCALL_DEFINE5(name, ...) SYSCALL_DEFINEx(5, _##name, __VA_ARGS__)
                                       ^~~~~~~~~~~~~~~
   ipc/mqueue.c:1197:1: note: in expansion of macro 'SYSCALL_DEFINE5'
    SYSCALL_DEFINE5(mq_timedreceive, mqd_t, mqdes, char __user *, u_msg_ptr,
    ^~~~~~~~~~~~~~~
   include/linux/syscalls.h:215:18: note: aliased declaration here
     asmlinkage long SyS##name(__MAP(x,__SC_LONG,__VA_ARGS__)) \
                     ^~~
   include/linux/syscalls.h:207:2: note: in expansion of macro '__SYSCALL_DEFINEx'
     __SYSCALL_DEFINEx(x, sname, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~
   include/linux/syscalls.h:200:36: note: in expansion of macro 'SYSCALL_DEFINEx'
    #define SYSCALL_DEFINE5(name, ...) SYSCALL_DEFINEx(5, _##name, __VA_ARGS__)
                                       ^~~~~~~~~~~~~~~
   ipc/mqueue.c:1197:1: note: in expansion of macro 'SYSCALL_DEFINE5'
    SYSCALL_DEFINE5(mq_timedreceive, mqd_t, mqdes, char __user *, u_msg_ptr,
    ^~~~~~~~~~~~~~~
   include/linux/syscalls.h:211:18: warning: 'sys_mq_timedsend' alias between functions of incompatible types 'long int(mqd_t,  const char *, size_t,  unsigned int,  const struct timespec *)' {aka 'long int(int,  const char *, long unsigned int,  unsigned int,  const struct timespec *)'} and 'long int(long int,  long int,  long int,  long int,  long int)' [-Wattribute-alias]
     asmlinkage long sys##name(__MAP(x,__SC_DECL,__VA_ARGS__)) \
                     ^~~
   include/linux/syscalls.h:207:2: note: in expansion of macro '__SYSCALL_DEFINEx'
     __SYSCALL_DEFINEx(x, sname, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~
   include/linux/syscalls.h:200:36: note: in expansion of macro 'SYSCALL_DEFINEx'
    #define SYSCALL_DEFINE5(name, ...) SYSCALL_DEFINEx(5, _##name, __VA_ARGS__)
                                       ^~~~~~~~~~~~~~~
   ipc/mqueue.c:1183:1: note: in expansion of macro 'SYSCALL_DEFINE5'
    SYSCALL_DEFINE5(mq_timedsend, mqd_t, mqdes, const char __user *, u_msg_ptr,
    ^~~~~~~~~~~~~~~
   include/linux/syscalls.h:215:18: note: aliased declaration here
     asmlinkage long SyS##name(__MAP(x,__SC_LONG,__VA_ARGS__)) \
                     ^~~
   include/linux/syscalls.h:207:2: note: in expansion of macro '__SYSCALL_DEFINEx'
     __SYSCALL_DEFINEx(x, sname, __VA_ARGS__)
     ^~~~~~~~~~~~~~~~~
   include/linux/syscalls.h:200:36: note: in expansion of macro 'SYSCALL_DEFINEx'
    #define SYSCALL_DEFINE5(name, ...) SYSCALL_DEFINEx(5, _##name, __VA_ARGS__)
                                       ^~~~~~~~~~~~~~~
   ipc/mqueue.c:1183:1: note: in expansion of macro 'SYSCALL_DEFINE5'
    SYSCALL_DEFINE5(mq_timedsend, mqd_t, mqdes, const char __user *, u_msg_ptr,
    ^~~~~~~~~~~~~~~
   include/linux/syscalls.h:211:18: warning: 'sys_mq_unlink' alias between functions of incompatible types 'long int(const char *)' and 'long int(long int)' [-Wattribute-alias]

vim +/COMPAT_SYSCALL_DEFINE3 +1531 ipc/mqueue.c

0d060606 Al Viro        2017-06-27  1463  
0d060606 Al Viro        2017-06-27 @1464  COMPAT_SYSCALL_DEFINE4(mq_open, const char __user *, u_name,
0d060606 Al Viro        2017-06-27  1465  		       int, oflag, compat_mode_t, mode,
0d060606 Al Viro        2017-06-27  1466  		       struct compat_mq_attr __user *, u_attr)
0d060606 Al Viro        2017-06-27  1467  {
0d060606 Al Viro        2017-06-27  1468  	struct mq_attr attr, *p = NULL;
0d060606 Al Viro        2017-06-27  1469  	if (u_attr && oflag & O_CREAT) {
0d060606 Al Viro        2017-06-27  1470  		p = &attr;
0d060606 Al Viro        2017-06-27  1471  		if (get_compat_mq_attr(&attr, u_attr))
0d060606 Al Viro        2017-06-27  1472  			return -EFAULT;
0d060606 Al Viro        2017-06-27  1473  	}
0d060606 Al Viro        2017-06-27  1474  	return do_mq_open(u_name, oflag, mode, p);
0d060606 Al Viro        2017-06-27  1475  }
0d060606 Al Viro        2017-06-27  1476  
0d060606 Al Viro        2017-06-27  1477  static int compat_prepare_timeout(const struct compat_timespec __user *p,
b9047726 Deepa Dinamani 2017-08-02  1478  				   struct timespec64 *ts)
0d060606 Al Viro        2017-06-27  1479  {
b9047726 Deepa Dinamani 2017-08-02  1480  	if (compat_get_timespec64(ts, p))
0d060606 Al Viro        2017-06-27  1481  		return -EFAULT;
b9047726 Deepa Dinamani 2017-08-02  1482  	if (!timespec64_valid(ts))
0d060606 Al Viro        2017-06-27  1483  		return -EINVAL;
0d060606 Al Viro        2017-06-27  1484  	return 0;
0d060606 Al Viro        2017-06-27  1485  }
0d060606 Al Viro        2017-06-27  1486  
0d060606 Al Viro        2017-06-27 @1487  COMPAT_SYSCALL_DEFINE5(mq_timedsend, mqd_t, mqdes,
0d060606 Al Viro        2017-06-27  1488  		       const char __user *, u_msg_ptr,
0d060606 Al Viro        2017-06-27  1489  		       compat_size_t, msg_len, unsigned int, msg_prio,
0d060606 Al Viro        2017-06-27  1490  		       const struct compat_timespec __user *, u_abs_timeout)
0d060606 Al Viro        2017-06-27  1491  {
b9047726 Deepa Dinamani 2017-08-02  1492  	struct timespec64 ts, *p = NULL;
0d060606 Al Viro        2017-06-27  1493  	if (u_abs_timeout) {
0d060606 Al Viro        2017-06-27  1494  		int res = compat_prepare_timeout(u_abs_timeout, &ts);
0d060606 Al Viro        2017-06-27  1495  		if (res)
0d060606 Al Viro        2017-06-27  1496  			return res;
0d060606 Al Viro        2017-06-27  1497  		p = &ts;
0d060606 Al Viro        2017-06-27  1498  	}
0d060606 Al Viro        2017-06-27  1499  	return do_mq_timedsend(mqdes, u_msg_ptr, msg_len, msg_prio, p);
0d060606 Al Viro        2017-06-27  1500  }
0d060606 Al Viro        2017-06-27  1501  
0d060606 Al Viro        2017-06-27 @1502  COMPAT_SYSCALL_DEFINE5(mq_timedreceive, mqd_t, mqdes,
0d060606 Al Viro        2017-06-27  1503  		       char __user *, u_msg_ptr,
0d060606 Al Viro        2017-06-27  1504  		       compat_size_t, msg_len, unsigned int __user *, u_msg_prio,
0d060606 Al Viro        2017-06-27  1505  		       const struct compat_timespec __user *, u_abs_timeout)
0d060606 Al Viro        2017-06-27  1506  {
b9047726 Deepa Dinamani 2017-08-02  1507  	struct timespec64 ts, *p = NULL;
0d060606 Al Viro        2017-06-27  1508  	if (u_abs_timeout) {
0d060606 Al Viro        2017-06-27  1509  		int res = compat_prepare_timeout(u_abs_timeout, &ts);
0d060606 Al Viro        2017-06-27  1510  		if (res)
0d060606 Al Viro        2017-06-27  1511  			return res;
0d060606 Al Viro        2017-06-27  1512  		p = &ts;
0d060606 Al Viro        2017-06-27  1513  	}
0d060606 Al Viro        2017-06-27  1514  	return do_mq_timedreceive(mqdes, u_msg_ptr, msg_len, u_msg_prio, p);
0d060606 Al Viro        2017-06-27  1515  }
0d060606 Al Viro        2017-06-27  1516  
0d060606 Al Viro        2017-06-27 @1517  COMPAT_SYSCALL_DEFINE2(mq_notify, mqd_t, mqdes,
0d060606 Al Viro        2017-06-27  1518  		       const struct compat_sigevent __user *, u_notification)
0d060606 Al Viro        2017-06-27  1519  {
0d060606 Al Viro        2017-06-27  1520  	struct sigevent n, *p = NULL;
0d060606 Al Viro        2017-06-27  1521  	if (u_notification) {
0d060606 Al Viro        2017-06-27  1522  		if (get_compat_sigevent(&n, u_notification))
0d060606 Al Viro        2017-06-27  1523  			return -EFAULT;
0d060606 Al Viro        2017-06-27  1524  		if (n.sigev_notify == SIGEV_THREAD)
0d060606 Al Viro        2017-06-27  1525  			n.sigev_value.sival_ptr = compat_ptr(n.sigev_value.sival_int);
0d060606 Al Viro        2017-06-27  1526  		p = &n;
0d060606 Al Viro        2017-06-27  1527  	}
0d060606 Al Viro        2017-06-27  1528  	return do_mq_notify(mqdes, p);
0d060606 Al Viro        2017-06-27  1529  }
0d060606 Al Viro        2017-06-27  1530  
0d060606 Al Viro        2017-06-27 @1531  COMPAT_SYSCALL_DEFINE3(mq_getsetattr, mqd_t, mqdes,
0d060606 Al Viro        2017-06-27  1532  		       const struct compat_mq_attr __user *, u_mqstat,
0d060606 Al Viro        2017-06-27  1533  		       struct compat_mq_attr __user *, u_omqstat)
0d060606 Al Viro        2017-06-27  1534  {
0d060606 Al Viro        2017-06-27  1535  	int ret;
0d060606 Al Viro        2017-06-27  1536  	struct mq_attr mqstat, omqstat;
0d060606 Al Viro        2017-06-27  1537  	struct mq_attr *new = NULL, *old = NULL;
0d060606 Al Viro        2017-06-27  1538  
0d060606 Al Viro        2017-06-27  1539  	if (u_mqstat) {
0d060606 Al Viro        2017-06-27  1540  		new = &mqstat;
0d060606 Al Viro        2017-06-27  1541  		if (get_compat_mq_attr(new, u_mqstat))
0d060606 Al Viro        2017-06-27  1542  			return -EFAULT;
0d060606 Al Viro        2017-06-27  1543  	}
0d060606 Al Viro        2017-06-27  1544  	if (u_omqstat)
0d060606 Al Viro        2017-06-27  1545  		old = &omqstat;
0d060606 Al Viro        2017-06-27  1546  
0d060606 Al Viro        2017-06-27  1547  	ret = do_mq_getsetattr(mqdes, new, old);
0d060606 Al Viro        2017-06-27  1548  	if (ret || !old)
0d060606 Al Viro        2017-06-27  1549  		return ret;
0d060606 Al Viro        2017-06-27  1550  
0d060606 Al Viro        2017-06-27  1551  	if (put_compat_mq_attr(old, u_omqstat))
0d060606 Al Viro        2017-06-27  1552  		return -EFAULT;
0d060606 Al Viro        2017-06-27  1553  	return 0;
^1da177e Linus Torvalds 2005-04-16  1554  }
0d060606 Al Viro        2017-06-27  1555  #endif
^1da177e Linus Torvalds 2005-04-16  1556  

:::::: The code at line 1531 was first introduced by commit
:::::: 0d0606060baefdb13d3d80dba1b4c816b0676e16 mqueue: move compat syscalls to native ones

:::::: TO: Al Viro <viro@zeniv.linux.org.uk>
:::::: CC: Al Viro <viro@zeniv.linux.org.uk>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--opJtzjQTFsWo+cga
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--opJtzjQTFsWo+cga--
