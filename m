Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 90DD76B038C
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 10:01:34 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b2so352545802pgc.6
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 07:01:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o20si21353120pgn.150.2017.03.21.07.01.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 07:01:32 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2LDrrd9146297
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 10:01:32 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 29aypsrn8e-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 10:01:31 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 21 Mar 2017 14:01:28 -0000
Date: Tue, 21 Mar 2017 10:01:19 -0400
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: Review request: draft userfaultfd(2) manual page
References: <487b2c79-f99b-6d0f-2412-aa75cde65569@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <487b2c79-f99b-6d0f-2412-aa75cde65569@gmail.com>
Message-Id: <20170321140118.GA6471@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-man <linux-man@vger.kernel.org>

Hello Michael,

On Mon, Mar 20, 2017 at 09:08:05PM +0100, Michael Kerrisk (man-pages) wrote:
> Hello Andrea, Mike, and all,
> 
> Mike: thanks for the page that you sent. I've reworked it
> a bit, and also added a lot of further information,
> and an example program. In the process, I split the page
> into two pieces, with one piece describing the userfaultfd()
> system call and the other describing the ioctl() operations.
> 
> I'd like to get review input, especially from you and
> Andrea, but also anyone else, for the current version
> of this page, which includes a few FIXMEs to be sorted.

Thanks for the update. I'm adressing the FIXME points you've mentioned
below.
Otherwise, everything seems the right description of the current upstream.
4.11 will have quite a few updates to userfault and we'll need to udpate
this page and ioctl_userfaultfd(2) to address those updates. I am planning
to work on the man update in the next few weeks. 
 
> I've shown the rendered version of the page below. 
> The groff source is attached, and can also be found
> at the branch here:
 
> https://git.kernel.org/pub/scm/docs/man-pages/man-pages.git/log/?h=draft_userfaultfd
> 
> The new ioctl_userfaultfd(2) page follows this mail.
> 
> Cheers,
> 
> Michael
 
--
Sincerely yours,
Mike. 
 

> USERFAULTFD(2)         Linux Programmer's Manual        USERFAULTFD(2)
> 
> a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??
> a??FIXME                                                a??
> a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??
> a??Need  to  describe close(2) semantics for userfaulfd a??
> a??file descriptor: what happens when  the  userfaultfd a??
> a??FD is closed?                                        a??
> a??                                                     a??
> a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??
 
When userfaultfd is closed, it unregisters all memory ranges that were
previously registered with it and flushes the outstanding page fault
events.

> NAME
>        userfaultfd - create a file descriptor for handling page faults
>        in user space
> 
> SYNOPSIS
>        #include <sys/types.h>
>        #include <linux/userfaultfd.h>
> 
>        int userfaultfd(int flags);
> 
>        Note: There is no glibc  wrapper  for  this  system  call;  see
>        NOTES.
> 
> DESCRIPTION
>        userfaultfd() creates a new userfaultfd object that can be used
>        for delegation of page-fault handling to a user-space  applicaa??
>        tion,  and  returns  a  file  descriptor that refers to the new
>        object.   The  new  userfaultfd  object  is  configured   using
>        ioctl(2).
> 
>        Once  the userfaultfd object is configured, the application can
>        use read(2) to receive userfaultfd  notifications.   The  reads
>        from  userfaultfd may be blocking or non-blocking, depending on
>        the value of flags used for the creation of the userfaultfd  or
>        subsequent calls to fcntl(2).
> 
>        The following values may be bitwise ORed in flags to change the
>        behavior of userfaultfd():
> 
>        O_CLOEXEC
>               Enable the close-on-exec flag for  the  new  userfaultfd
>               file  descriptor.   See the description of the O_CLOEXEC
>               flag in open(2).
> 
>        O_NONBLOCK
>               Enables  non-blocking  operation  for  the   userfaultfd
>               object.   See  the description of the O_NONBLOCK flag in
>               open(2).
> 
>    Usage
>        The userfaultfd mechanism is designed to allow a  thread  in  a
>        multithreaded  program  to  perform  user-space  paging for the
>        other threads in the process.  When a page fault occurs for one
>        of the regions registered to the userfaultfd object, the faulta??
>        ing thread is put to sleep and an event is generated  that  can
>        be  read  via  the userfaultfd file descriptor.  The fault-hana??
>        dling thread reads events from this file  descriptor  and  sera??
>        vices  them  using  the  operations  described  in  ioctl_usera??
>        faultfd(2).  When servicing the page fault events,  the  fault-
>        handling thread can trigger a wake-up for the sleeping thread.
> 
>    Userfaultfd operation
>        After the userfaultfd object is created with userfaultfd(), the
>        application must enable it using the UFFDIO_API ioctl(2) operaa??
>        tion.  This operation allows a handshake between the kernel and
>        user space to determine the API version and supported features.
>        This  operation  must  be  performed  before  any  of the other
>        ioctl(2) operations described below (or those  operations  fail
>        with the EINVAL error).
> 
>        After  a  successful UFFDIO_API operation, the application then
>        registers  memory  address  ranges  using  the  UFFDIO_REGISTER
>        ioctl(2)  operation.   After  successful  completion  of a UFFa??
>        DIO_REGISTER operation, a page fault occurring in the requested
>        memory  range, and satisfying the mode defined at the registraa??
>        tion time, will be forwarded by the kernel  to  the  user-space
>        application.   The  application can then use the UFFDIO_COPY or
>        UFFDIO_ZERO ioctl(2) operations to resolve the page fault.
> 
>        Details of the various ioctl(2)  operations  can  be  found  in
>        ioctl_userfaultfd(2).
> 
>        Currently,  userfaultfd can be used only with anonymous private
>        memory mappings.
> 
>    Reading from the userfaultfd structure
>        a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??
>        a??FIXME                                                a??
>        a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??
>        a??are the details below correct?                       a??
>        a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??

Yes, at least for the current upstream version. 4.11 will have quite a few
updates to userfaultfd.

>        Each read(2) from the userfaultfd file descriptor  returns  one
>        or  more  uffd_msg  structures, each of which describes a page-
>        fault event:
> 
>            struct uffd_msg {
>                __u8  event;                /* Type of event */
>                ...
>                union {
>                    struct {
>                        __u64 flags;        /* Flags describing fault */
>                        __u64 address;      /* Faulting address */
>                    } pagefault;
>                    ...
>                } arg;
> 
>                /* Padding fields omitted */
>            } __packed;
> 
>        If multiple events are available and  the  supplied  buffer  is
>        large enough, read(2) returns as many events as will fit in the
>        supplied buffer.  If the buffer supplied to read(2) is  smaller
>        than the size of the uffd_msg structure, the read(2) fails with
>        the error EINVAL.
> 
>        The fields set in the uffd_msg structure are as follows:
> 
>        event  The type of event.  Currently, only one value can appear
>               in  this  field: UFFD_EVENT_PAGEFAULT, which indicates a
>               page-fault event.
> 
>        address
>               The address that triggered the page fault.
> 
>        flags  A bit mask  of  flags  that  describe  the  event.   For
>               UFFD_EVENT_PAGEFAULT, the following flag may appear:
> 
>               UFFD_PAGEFAULT_FLAG_WRITE
>                      If  the address is in a range that was registered
>                      with the UFFDIO_REGISTER_MODE_MISSING  flag  (see
>                      ioctl_userfaultfd(2))  and this flag is set, this
>                      a write fault; otherwise it is a read fault.
> 
>        A read(2) on a userfaultfd file descriptor can  fail  with  the
>        following errors:
> 
>        EINVAL The  userfaultfd  object  has not yet been enabled using
>               the UFFDIO_API ioctl(2) operation
> 
>        The userfaultfd file descriptor can be monitored with  poll(2),
>        select(2),  and  epoll(7).  When events are available, the file
>        descriptor indicates as readable.
> 
> 
>        a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??
>        a??FIXME                                                a??
>        a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??
>        a??But, it seems,  the  object  must  be  created  with a??
>        a??O_NONBLOCK.  What is the rationale for this requirea?? a??
>        a??ment? Something needs to  be  said  in  this  manual a??
>        a??page.                                                a??
>        a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??a??

The object can be created without O_NONBLOCK, so probably the above
sentence can be rephrased as:

When the userfaultfd file descriptor is opened in non-blocking mode, it can
be monitored with ...

> RETURN VALUE
>        On  success,  userfaultfd()  returns a new file descriptor that
>        refers to the userfaultfd object.  On error,  -1  is  returned,
>        and errno is set appropriately.
> 
> ERRORS
>        EINVAL An unsupported value was specified in flags.
> 
>        EMFILE The  per-process  limit  on  the  number  of  open  file
>               descriptors has been reached
> 
>        ENFILE The system-wide limit on the total number of open  files
>               has been reached.
> 
>        ENOMEM Insufficient kernel memory was available.
> 
> VERSIONS
>        The userfaultfd() system call first appeared in Linux 4.3.
> 
> CONFORMING TO
>        userfaultfd()  is Linux-specific and should not be used in proa??
>        grams intended to be portable.
> 
> NOTES
>        Glibc does not provide a wrapper for this system call; call  it
>        using syscall(2).
> 
>        The userfaultfd mechanism can be used as an alternative to traa??
>        ditional user-space paging techniques based on the use  of  the
>        SIGSEGV  signal  and mmap(2).  It can also be used to implement
>        lazy restore for  checkpoint/restore  mechanisms,  as  well  as
>        post-copy  migration  to allow (nearly) uninterrupted execution
>        when transferring virtual machines from one host to another.
> 
> EXAMPLE
>        The program below demonstrates the use of the userfaultfd mecha??
>        anism.   The  program creates two threads, one of which acts as
>        the page-fault handler for the process,  for  the  pages  in  a
>        demand-page zero region created using mmap(2).
> 
>        The  program takes one command-line argument, which is the numa??
>        ber of pages that will be  created  in  a  mapping  whose  page
>        faults will be handled via userfaultfd.  After creating a usera??
>        faultfd object, the program then creates an  anonymous  private
>        mapping  of  the specified size and registers the address range
>        of that mapping using the UFFDIO_REGISTER  ioctl(2)  operation.
>        The  program then creates a second thread that will perform the
>        task of handling page faults.
> 
>        The main thread then walks through the  pages  of  the  mapping
>        fetching  bytes  from successive pages.  Because the pages have
>        not yet been accessed, the first access of a byte in each  page
>        will  trigger  a  page-fault  event  on  the  userfaultfd  file
>        descriptor.
> 
>        Each of the page-fault events is handled by the second  thread,
>        which sits in a loop processing input from the userfaultfd file
>        descriptor.  In each loop iteration, the  second  thread  first
>        calls  poll(2)  to  check the state of the file descriptor, and
>        then reads an event from the file descriptor.  All such  events
>        should be UFFD_EVENT_PAGEFAULT events, which the thread handles
>        by copying a page of data into the faulting  region  using  the
>        UFFDIO_COPY ioctl(2) operation.
> 
>        The  following  is  an  example of what we see when running the
>        program:
> 
>            $ ./userfaultfd_demo 3
>            Address returned by mmap() = 0x7fd30106c000
> 
>            fault_handler_thread():
>                poll() returns: nready = 1; POLLIN = 1; POLLERR = 0
>                UFFD_EVENT_PAGEFAULT event: flags = 0; address = 7fd30106c00f
>                    (uffdio_copy.copy returned 4096)
>            Read address 0x7fd30106c00f in main(): A
>            Read address 0x7fd30106c40f in main(): A
>            Read address 0x7fd30106c80f in main(): A
>            Read address 0x7fd30106cc0f in main(): A
> 
>            fault_handler_thread():
>                poll() returns: nready = 1; POLLIN = 1; POLLERR = 0
>                UFFD_EVENT_PAGEFAULT event: flags = 0; address = 7fd30106d00f
>                    (uffdio_copy.copy returned 4096)
>            Read address 0x7fd30106d00f in main(): B
>            Read address 0x7fd30106d40f in main(): B
>            Read address 0x7fd30106d80f in main(): B
>            Read address 0x7fd30106dc0f in main(): B
> 
>            fault_handler_thread():
>                poll() returns: nready = 1; POLLIN = 1; POLLERR = 0
>                UFFD_EVENT_PAGEFAULT event: flags = 0; address = 7fd30106e00f
>                    (uffdio_copy.copy returned 4096)
>            Read address 0x7fd30106e00f in main(): C
>            Read address 0x7fd30106e40f in main(): C
>            Read address 0x7fd30106e80f in main(): C
>            Read address 0x7fd30106ec0f in main(): C
> 
>    Program source
> 
>        /* userfaultfd_demo.c
> 
>           Licensed under the GNU General Public License version 2 or later.
>        */
>        #define _GNU_SOURCE
>        #include <sys/types.h>
>        #include <stdio.h>
>        #include <linux/userfaultfd.h>
>        #include <pthread.h>
>        #include <errno.h>
>        #include <unistd.h>
>        #include <stdlib.h>
>        #include <fcntl.h>
>        #include <signal.h>
>        #include <poll.h>
>        #include <string.h>
>        #include <sys/mman.h>
>        #include <sys/syscall.h>
>        #include <sys/ioctl.h>
>        #include <poll.h>
> 
>        #define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \
>                                } while (0)
> 
>        static int page_size;
> 
>        static void *
>        fault_handler_thread(void *arg)
>        {
>            static struct uffd_msg msg;   /* Data read from userfaultfd */
>            static int fault_cnt = 0;     /* Number of faults so far handled */
>            long uffd;                    /* userfaultfd file descriptor */
>            static char *page = NULL;
>            struct uffdio_copy uffdio_copy;
>            ssize_t nread;
> 
>            uffd = (long) arg;
> 
>            /* Create a page that will be copied into the faulting region */
> 
>            if (page == NULL) {
>                page = mmap(NULL, page_size, PROT_READ | PROT_WRITE,
>                            MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
>                if (page == MAP_FAILED)
>                    errExit("mmap");
>            }
> 
>            /* Loop, handling incoming events on the userfaultfd
>               file descriptor */
> 
>            for (;;) {
> 
>                /* See what poll() tells us about the userfaultfd */
> 
>                struct pollfd pollfd;
>                int nready;
>                pollfd.fd = uffd;
>                pollfd.events = POLLIN;
>                nready = poll(&pollfd, 1, -1);
>                if (nready == -1)
>                    errExit("poll");
> 
>                printf("\nfault_handler_thread():\n");
>                printf("    poll() returns: nready = %d; "
>                        "POLLIN = %d; POLLERR = %d\n", nready,
>                        (pollfd.revents & POLLIN) != 0,
>                        (pollfd.revents & POLLERR) != 0);
> 
>                /* Read an event from the userfaultfd */
> 
>                nread = read(uffd, &msg, sizeof(msg));
>                if (nread == 0) {
>                    printf("EOF on userfaultfd!\n");
>                    exit(EXIT_FAILURE);
>                }
> 
>                if (nread == -1)
>                    errExit("read");
> 
>                /* We expect only one kind of event; verify that assumption */
> 
>                if (msg.event != UFFD_EVENT_PAGEFAULT) {
>                    fprintf(stderr, "Unexpected event on userfaultfd\n");
>                    exit(EXIT_FAILURE);
>                }
> 
>                /* Display info about the page-fault event */
> 
>                printf("    UFFD_EVENT_PAGEFAULT event: ");
>                printf("flags = %llx; ", msg.arg.pagefault.flags);
>                printf("address = %llx\n", msg.arg.pagefault.address);
> 
>                /* Copy the page pointed to by 'page' into the faulting
>                   region. Vary the contents that are copied in, so that it
>                   is more obvious that each fault is handled separately. */
> 
>                memset(page, 'A' + fault_cnt % 20, page_size);
>                fault_cnt++;
> 
>                uffdio_copy.src = (unsigned long) page;
> 
>                /* We need to handle page faults in units of pages(!).
>                   So, round faulting address down to page boundary */
> 
>                uffdio_copy.dst = (unsigned long) msg.arg.pagefault.address &
>                                                   ~(page_size - 1);
>                uffdio_copy.len = page_size;
>                uffdio_copy.mode = 0;
>                uffdio_copy.copy = 0;
>                if (ioctl(uffd, UFFDIO_COPY, &uffdio_copy) == -1)
>                    errExit("ioctl-UFFDIO_COPY");
> 
>                printf("        (uffdio_copy.copy returned %lld)\n",
>                        uffdio_copy.copy);
>            }
>        }
> 
>        int
>        main(int argc, char *argv[])
>        {
>            long uffd;          /* userfaultfd file descriptor */
>            char *addr;         /* Start of region handled by userfaultfd */
>            unsigned long len;  /* Length of region handled by userfaultfd */
>            pthread_t thr;      /* ID of thread that handles page faults */
>            struct uffdio_api uffdio_api;
>            struct uffdio_register uffdio_register;
>            int s;
> 
>            if (argc != 2) {
>                fprintf(stderr, "Usage: %s num-pages\n", argv[0]);
>                exit(EXIT_FAILURE);
>            }
> 
>            page_size = sysconf(_SC_PAGE_SIZE);
>            len = strtoul(argv[1], NULL, 0) * page_size;
> 
>            /* Create and enable userfaultfd object */
> 
>            uffd = syscall(__NR_userfaultfd, O_CLOEXEC | O_NONBLOCK);
>            if (uffd == -1)
>                errExit("userfaultfd");
> 
>            uffdio_api.api = UFFD_API;
>            uffdio_api.features = 0;
>            if (ioctl(uffd, UFFDIO_API, &uffdio_api) == -1)
>                errExit("ioctl-UFFDIO_API");
> 
>            /* Create a private anonymous mapping. The memory will be
>               demand-zero paged--that is, not yet allocated. When we
>               actually touch the memory, it will be allocated via
>               the userfaultfd. */
> 
>            addr = mmap(NULL, len, PROT_READ | PROT_WRITE,
>                        MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
>            if (addr == MAP_FAILED)
>                errExit("mmap");
> 
>            printf("Address returned by mmap() = %p\n", addr);
> 
>            /* Register the memory range of the mapping we just created for
>               handling by the userfaultfd object. In mode, we request to track
>               missing pages (i.e., pages that have not yet been faulted in). */
> 
>            uffdio_register.range.start = (unsigned long) addr;
>            uffdio_register.range.len = len;
>            uffdio_register.mode = UFFDIO_REGISTER_MODE_MISSING;
>            if (ioctl(uffd, UFFDIO_REGISTER, &uffdio_register) == -1)
>                errExit("ioctl-UFFDIO_REGISTER");
> 
>            /* Create a thread that will process the userfaultfd events */
> 
>            s = pthread_create(&thr, NULL, fault_handler_thread, (void *) uffd);
>            if (s != 0) {
>                errno = s;
>                errExit("pthread_create");
>            }
> 
>            /* Main thread now touches memory in the mapping, touching
>               locations 1024 bytes apart. This will trigger userfaultfd
>               events for all pages in the region. */
> 
>            int l;
>            l = 0xf;    /* Ensure that faulting address is not on a page
>                           boundary, in order to test that we correctly
>                           handle that case in fault_handling_thread() */
>            while (l < len) {
>                char c = addr[l];
>                printf("Read address %p in main(): ", addr + l);
>                printf("%c\n", c);
>                l += 1024;
>                usleep(100000);         /* Slow things down a little */
>            }
> 
>            exit(EXIT_SUCCESS);
>        }
> 
> SEE ALSO
>        fcntl(2), ioctl(2), ioctl_userfaultfd(2), madvise(2), mmap(2)
> 
>        Documentation/vm/userfaultfd.txt in  the  Linux  kernel  source
>        tree
> 
> 
> -- 
> Michael Kerrisk
> Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> Linux/UNIX System Programming Training: http://man7.org/training/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
