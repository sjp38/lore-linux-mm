Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 92EEE6B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 03:40:49 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so41631962wgy.2
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 00:40:49 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id bl10si3602245wjb.10.2015.04.24.00.40.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 00:40:47 -0700 (PDT)
Message-ID: <5539F370.9070704@nod.at>
Date: Fri, 24 Apr 2015 09:40:32 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v3 00/10] an introduction of library operating system
 for Linux (LibOS)
References: <1429263374-57517-1-git-send-email-tazaki@sfc.wide.ad.jp> <1429450104-47619-1-git-send-email-tazaki@sfc.wide.ad.jp>
In-Reply-To: <1429450104-47619-1-git-send-email-tazaki@sfc.wide.ad.jp>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>, linux-arch@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Christoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Rusty Russell <rusty@rustcorp.com.au>, Ryo Nakamura <upa@haeena.net>, Christoph Paasch <christoph.paasch@gmail.com>, Mathieu Lacage <mathieu.lacage@gmail.com>, libos-nuse@googlegroups.com

Hi!

Am 19.04.2015 um 15:28 schrieb Hajime Tazaki:
> changes from v2:
> - Patch 02/11 ("slab: add private memory allocator header for arch/lib")
> * add new allocator named SLIB (Library Allocator): Patch 04/11 is integrated
>   to 02 (commented by Christoph Lameter)
> - Overall
> * rewrite commit log messages
> 
> changes from v1:
> - Patch 01/11 ("sysctl: make some functions unstatic to access by arch/lib"):
> * add prefix ctl_table_ to newly publiced functions (commented by Joe Perches)
> - Patch 08/11 ("lib: other kernel glue layer code"):
> * significantly reduce glue codes (stubs) (commented by Richard Weinberger)
> - Others
> * adapt to linux-4.0.0
> * detect make dependency by Kbuild .cmd files

I still fail to build it. :-(

for-asm-upstream-v3 on top of Linus' tree gives:

rw@sandpuppy:~/linux (libos $)> make library ARCH=lib
  OBJS-MK   arch/lib/objs.mk
arch/lib/Makefile.print:41: target 'lzo/' given more than once in the same rule.
make[2]: Nothing to be done for '.config'.
scripts/kconfig/conf  --silentoldconfig arch/lib/Kconfig
  CHK     include/config/kernel.release
  CHK     include/generated/utsrelease.h
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/compile.h
  GEN     arch/lib/timeconst.h
  GEN     arch/lib/linker.lds
  CC      arch/lib/lib.o
  CC      arch/lib/lib-device.o
  CC      arch/lib/lib-socket.o
  CC      arch/lib/random.o
  CC      arch/lib/softirq.o
  CC      arch/lib/time.o
  CC      arch/lib/timer.o
  CC      arch/lib/hrtimer.o
  CC      arch/lib/sched.o
  CC      arch/lib/workqueue.o
  CC      arch/lib/print.o
  CC      arch/lib/tasklet.o
  CC      arch/lib/tasklet-hrtimer.o
  CC      arch/lib/glue.o
  CC      arch/lib/fs.o
  CC      arch/lib/sysctl.o
  CC      arch/lib/proc.o
  CC      arch/lib/sysfs.o
  CC      arch/lib/capability.o
arch/lib/capability.c:16:6: error: redefinition of a??capablea??
 bool capable(int cap)
      ^
In file included from arch/lib/capability.c:9:0:
./include/linux/capability.h:236:20: note: previous definition of a??capablea?? was here
 static inline bool capable(int cap)
                    ^
arch/lib/capability.c:39:6: error: redefinition of a??ns_capablea??
 bool ns_capable(struct user_namespace *ns, int cap)
      ^
In file included from arch/lib/capability.c:9:0:
./include/linux/capability.h:240:20: note: previous definition of a??ns_capablea?? was here
 static inline bool ns_capable(struct user_namespace *ns, int cap)
                    ^
arch/lib/Makefile:210: recipe for target 'arch/lib/capability.o' failed
make: *** [arch/lib/capability.o] Error 1

And on top of v4.0 it fails too:

rw@sandpuppy:~/linux (libos-v4.0 $)> make library ARCH=lib
  OBJS-MK   arch/lib/objs.mk
arch/lib/Makefile.print:41: target 'lzo/' given more than once in the same rule.
make[2]: Nothing to be done for '.config'.
scripts/kconfig/conf --silentoldconfig arch/lib/Kconfig
  CHK     include/config/kernel.release
  CHK     include/generated/utsrelease.h
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/compile.h
  GEN     arch/lib/timeconst.h
  GEN     arch/lib/linker.lds
  CC      arch/lib/lib.o
  CC      arch/lib/lib-device.o
  CC      arch/lib/lib-socket.o
arch/lib/lib-socket.c: In function a??lib_sock_sendmsga??:
arch/lib/lib-socket.c:114:2: error: too few arguments to function a??sock_sendmsga??
  retval = sock_sendmsg(kernel_socket, &msg_sys);
  ^
In file included from arch/lib/lib-socket.c:12:0:
./include/linux/net.h:216:5: note: declared here
 int sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t len);
     ^
arch/lib/Makefile:210: recipe for target 'arch/lib/lib-socket.o' failed
make: *** [arch/lib/lib-socket.o] Error 1

You *really* need to shape up wrt the build process.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
