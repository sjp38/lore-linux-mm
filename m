Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C787FC28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 16:19:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75D1525D91
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 16:19:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Ao3SJVxj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75D1525D91
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20D876B0274; Thu, 30 May 2019 12:19:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BA546B0275; Thu, 30 May 2019 12:19:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05C8D6B0276; Thu, 30 May 2019 12:19:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id CE7636B0274
	for <linux-mm@kvack.org>; Thu, 30 May 2019 12:19:43 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id b47so817693uad.3
        for <linux-mm@kvack.org>; Thu, 30 May 2019 09:19:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=gavpP5r3sxrBoYJ1YlT/UKhEf930n83vDNz/RveyAJE=;
        b=L50YsqqgvZDEJ4AMoRkfSer2dUbjCOPeLB5ajISrjiGi3rvNAavtDZnzXvqEhBLHJM
         MUC4qDlCH8JlpwcrjDpIOcBBSgxy86aQ9eeB5/eQ+Td7nBWtHs4iVnhaxbVCcV43/nQj
         6RiwyGz2JrSHKAPMDt7916xyQmTZ7u9Huk8fHG/POord9y+5SJqB5dANb8FEPQ4r5luw
         GJ8dnwszYM3aYQJTgwHTVs8ao/YS1W46e4MDUB0THleNwhk26CMqfipqmLTdS75voEEI
         tT7CeBPq3P7hJ1zIL/yHddFLxgfbPbToRs29QxMEYe+MAtoOiXdM8fRNxhm9Bs7PuOGX
         IrYg==
X-Gm-Message-State: APjAAAVDtESbFyJ294SK65SQe4mwdYDv2vB+tOvMam6kTxEzcFV/tuW6
	EGz1NNJdY1CUeygzkmmbHVgWGW+armWc2GowECufKn11KI3az3KkYyPmQJvVPD3XZpOcCv/3Iqj
	102tEhrur49/dN5iOXy08zHAZpNO0JtRMM8vxN5JyEiWUafmyJpJZK1vgiScgLAppgA==
X-Received: by 2002:a67:f8cf:: with SMTP id c15mr2581658vsp.174.1559233183321;
        Thu, 30 May 2019 09:19:43 -0700 (PDT)
X-Received: by 2002:a67:f8cf:: with SMTP id c15mr2581578vsp.174.1559233182034;
        Thu, 30 May 2019 09:19:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559233182; cv=none;
        d=google.com; s=arc-20160816;
        b=ZMBJmu9vM0ruNH5JR1Nq/exRc5GErrUCvujjg+GJvkWAGuWQeuzzcg7Q3zX9fWLOxj
         lkOXoYQ1xmakTjAA4DgKoPutMB5ZOTRb3PfJT12palPWkt5YxZ1mIYhs8SrVcytc/arE
         htdvWaxVxhp5BwxF5cIPYIs+r1HkgmOyQrX+zHDUdvnu1OUgp+i21fZepWy5cc8xOove
         M6NbfFz6CFZ6POtXP7ekC0hz4dZeY9OmToMGkAQL1yKj2+3DAzfNo/4tpMspyUF5L8IZ
         DXw22NUAtMgCrVCBhULfRyBUPH1Wo2+Nq6AkEheX2aibRqaK2KOyhH7j0yqClDkxIa21
         FU3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=gavpP5r3sxrBoYJ1YlT/UKhEf930n83vDNz/RveyAJE=;
        b=EBVXKSZIrdhiTYMPKvj7RcRhvPRItSqWQ2FxNQGnnBKadZLX76SAjFJbQrX71tjPSZ
         37zfzFP4MBc0MTOhpWHz3W2AWgDMWsaiI2xxM2kS2ZSBH2MjRQvl1l+5wTUvHcenpeI6
         cCy7oMc9QZFMNs3jI4lRID61Qdl7fPK56glqm3dF02R6UqKVoZiWiG7TJeUjqvIBEH5/
         tzmm+N3GrGZWIpVraM8Q+guTXIDET1iyAR3Xzh75ZFqD1wPIvsNt4CqeLwv9A2r2K286
         8UXPN2oWVQwRmQf1radDtT6KEvpQJB0/SB721QeTS/Wd6iuLZ/A9U9O3+G8YY3lmT1jQ
         D0aw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ao3SJVxj;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z20sor1444908uan.2.2019.05.30.09.19.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 09:19:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ao3SJVxj;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gavpP5r3sxrBoYJ1YlT/UKhEf930n83vDNz/RveyAJE=;
        b=Ao3SJVxjYTPncN3+OanMOZUwFPR6WkzxJQqdQj9IGciXk4MlsMpN/xGZg1Z8yT/mkS
         Vncul0Uks15kzX+KSFwI1EWO6boykkuvONSoHdWB8JfZ/FqyY1cQkpjvznaiDvvq4DK+
         JrYJ9xtOchvm8kAGfJwZBq8qp6eZcBlo2fm0QmLQkI1xNTT/gPigmO9ivzatvB88DXGb
         BqpkdgZtqXPeYdabWXyqubnJKj7kyJs5XVWpH1tQtOBycCp1gYbjO0JBpuKplTohM70y
         0n7U+obvoEPbKr9TQpq2uA9xNntpxv/EheEk0lxG55YBm9H4yVUmpbvkGUJYpI4DHfRA
         buPA==
X-Google-Smtp-Source: APXvYqypdAt8noDHPph2koXGVWzzlm5dziEUK5dARgr9OFm4N22aVfMoe9G2dOZvUHkxGtyhnkpYYP8QjZWC2Znv8nU=
X-Received: by 2002:ab0:60d0:: with SMTP id g16mr1322111uam.85.1559233181146;
 Thu, 30 May 2019 09:19:41 -0700 (PDT)
MIME-Version: 1.0
References: <20190520092258.GZ6836@dhcp22.suse.cz> <20190521024820.GG10039@google.com>
 <20190521062421.GD32329@dhcp22.suse.cz> <20190521102613.GC219653@google.com>
 <20190521103726.GM32329@dhcp22.suse.cz> <20190527074940.GB6879@google.com>
 <CAKOZuesK-8zrm1zua4dzqh4TEMivsZKiccySMvfBjOyDkg-MEw@mail.gmail.com>
 <20190529103352.GD18589@dhcp22.suse.cz> <20190530021748.GE229459@google.com>
 <20190530065755.GD6703@dhcp22.suse.cz> <20190530080214.GA159502@google.com>
In-Reply-To: <20190530080214.GA159502@google.com>
From: Daniel Colascione <dancol@google.com>
Date: Thu, 30 May 2019 09:19:29 -0700
Message-ID: <CAKOZuetx5QDPBEcUT4A2vNq3rbN_2SRMDVMeYP5p+didtUV0bA@mail.gmail.com>
Subject: Re: [RFC 6/7] mm: extend process_madvise syscall to support vector arrary
To: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Tim Murray <timmurray@google.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, 
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>, 
	Brian Geffon <bgeffon@google.com>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 30, 2019 at 1:02 AM Minchan Kim <minchan@kernel.org> wrote:
>
> On Thu, May 30, 2019 at 08:57:55AM +0200, Michal Hocko wrote:
> > On Thu 30-05-19 11:17:48, Minchan Kim wrote:
> > > On Wed, May 29, 2019 at 12:33:52PM +0200, Michal Hocko wrote:
> > > > On Wed 29-05-19 03:08:32, Daniel Colascione wrote:
> > > > > On Mon, May 27, 2019 at 12:49 AM Minchan Kim <minchan@kernel.org> wrote:
> > > > > >
> > > > > > On Tue, May 21, 2019 at 12:37:26PM +0200, Michal Hocko wrote:
> > > > > > > On Tue 21-05-19 19:26:13, Minchan Kim wrote:
> > > > > > > > On Tue, May 21, 2019 at 08:24:21AM +0200, Michal Hocko wrote:
> > > > > > > > > On Tue 21-05-19 11:48:20, Minchan Kim wrote:
> > > > > > > > > > On Mon, May 20, 2019 at 11:22:58AM +0200, Michal Hocko wrote:
> > > > > > > > > > > [Cc linux-api]
> > > > > > > > > > >
> > > > > > > > > > > On Mon 20-05-19 12:52:53, Minchan Kim wrote:
> > > > > > > > > > > > Currently, process_madvise syscall works for only one address range
> > > > > > > > > > > > so user should call the syscall several times to give hints to
> > > > > > > > > > > > multiple address range.
> > > > > > > > > > >
> > > > > > > > > > > Is that a problem? How big of a problem? Any numbers?
> > > > > > > > > >
> > > > > > > > > > We easily have 2000+ vma so it's not trivial overhead. I will come up
> > > > > > > > > > with number in the description at respin.
> > > > > > > > >
> > > > > > > > > Does this really have to be a fast operation? I would expect the monitor
> > > > > > > > > is by no means a fast path. The system call overhead is not what it used
> > > > > > > > > to be, sigh, but still for something that is not a hot path it should be
> > > > > > > > > tolerable, especially when the whole operation is quite expensive on its
> > > > > > > > > own (wrt. the syscall entry/exit).
> > > > > > > >
> > > > > > > > What's different with process_vm_[readv|writev] and vmsplice?
> > > > > > > > If the range needed to be covered is a lot, vector operation makes senese
> > > > > > > > to me.
> > > > > > >
> > > > > > > I am not saying that the vector API is wrong. All I am trying to say is
> > > > > > > that the benefit is not really clear so far. If you want to push it
> > > > > > > through then you should better get some supporting data.
> > > > > >
> > > > > > I measured 1000 madvise syscall vs. a vector range syscall with 1000
> > > > > > ranges on ARM64 mordern device. Even though I saw 15% improvement but
> > > > > > absoluate gain is just 1ms so I don't think it's worth to support.
> > > > > > I will drop vector support at next revision.
> > > > >
> > > > > Please do keep the vector support. Absolute timing is misleading,
> > > > > since in a tight loop, you're not going to contend on mmap_sem. We've
> > > > > seen tons of improvements in things like camera start come from
> > > > > coalescing mprotect calls, with the gains coming from taking and
> > > > > releasing various locks a lot less often and bouncing around less on
> > > > > the contended lock paths. Raw throughput doesn't tell the whole story,
> > > > > especially on mobile.
> > > >
> > > > This will always be a double edge sword. Taking a lock for longer can
> > > > improve a throughput of a single call but it would make a latency for
> > > > anybody contending on the lock much worse.
> > > >
> > > > Besides that, please do not overcomplicate the thing from the early
> > > > beginning please. Let's start with a simple and well defined remote
> > > > madvise alternative first and build a vector API on top with some
> > > > numbers based on _real_ workloads.
> > >
> > > First time, I didn't think about atomicity about address range race
> > > because MADV_COLD/PAGEOUT is not critical for the race.
> > > However you raised the atomicity issue because people would extend
> > > hints to destructive ones easily. I agree with that and that's why
> > > we discussed how to guarantee the race and Daniel comes up with good idea.
> >
> > Just for the clarification, I didn't really mean atomicity but rather a
> > _consistency_ (essentially time to check to time to use consistency).
>
> What do you mean by *consistency*? Could you elaborate it more?
>
> >
> > >   - vma configuration seq number via process_getinfo(2).
> > >
> > > We discussed the race issue without _read_ workloads/requests because
> > > it's common sense that people might extend the syscall later.
> > >
> > > Here is same. For current workload, we don't need to support vector
> > > for perfomance point of view based on my experiment. However, it's
> > > rather limited experiment. Some configuration might have 10000+ vmas
> > > or really slow CPU.
> > >
> > > Furthermore, I want to have vector support due to atomicity issue
> > > if it's really the one we should consider.
> > > With vector support of the API and vma configuration sequence number
> > > from Daniel, we could support address ranges operations's atomicity.
> >
> > I am not sure what do you mean here. Perform all ranges atomicaly wrt.
> > other address space modifications? If yes I am not sure we want that
>
> Yub, I think it's *necessary* if we want to support destructive hints
> via process_madvise.

[Puts on flame-proof suit]

Here's a quick sketch of what I have in mind for process_getinfo(2).
Keep in mind that it's still just a rough idea.

We've had trouble efficiently learning about process and memory state
of the system via procfs. Android background memory-use scans (the
android.bg daemon) consume quite a bit of CPU time for PSS; Minchan's
done a lot of thinking for how we can specify desired page sets for
compaction as part of this patch set; and the full procfs walks that
some trace collection tools need to undertake take more than 200ms to
collect (sometimes much more) due mostly to procfs iteration. ISTM we
can do better.

While procfs *works* on a functional level, it's inefficient due to
the splatting of information we want across several different files
(which need to be independently opened --- e.g.,
/proc/pid/oom_score_adj *and* /proc/pid/status), inefficient due to
the ad-hoc text formatting, inefficient due to information over-fetch,
and cumbersome due to the fundamental impedance mismatch between
filesystem APIs and process lifetimes. procfs itself is also optional,
which has caused various bits of awkwardness that you'll recall from
the pidfd discussions.

How about we solve the problem once and for all? I'm imagining a new
process_getinfo(2) that solves all of these problems at the same time.
I want something with a few properties:

1) if we want to learn M facts about N things, we enter the kernel
once and learn all M*N things,
2) the information we collect is self-consistent (which implies
atomicity most of the time),
3) we retrieve the information we want in an efficient binary format, and
4) we don't pay to learn anything not in M.

I've jotted down a quick sketch of the API below; I'm curious what
everyone else thinks. It'd basically look like this:

int process_getinfo(int nr_proc, int* proc, int flags, unsigned long
mask, void* out_buf, size_t* inout_sz)

We wouldn't use the return value for much: 0 on success and -1 on
error with errno set. NR_PROC and PROC together would specify the
objects we want to learn about, which would be either PIDs or PIDFDs
or maybe nothing at all if FLAGS tells us to inspect every process on
the system. MASK is a bitset of facts we want to learn, described
below. OUT_BUF and INOUT_SZ are for actually communicating the result.
On input, the caller would fill *INOUT_SZ with the size of the buffer
to which OUT_BUF points; on success, we'd fill *INOUT_SZ with the
number of bytes we actually used. If the output buffer is too small,
we'll truncate the result, fail the system call with E2BIG, and fill
*INOUT_SZ with the number of needed bytes, inviting the caller to try
again. (If a caller supplies something huge like a reusable 512KB
buffer on the first call, no reallocation and retries will be
necessary in practice on a typically-sized system.)

The actual returned buffer is a collection of structures and data
blocks starting with a struct process_info. The structures in the
returned buffer sometimes contain "pointers" to other structures
encoded as byte offsets from the start of the information buffer.
Using offsets instead of actual pointers keeps the format the same
across 32- and 64-bit versions of process_getinfo and makes it
possible to relocate the returned information buffer with memcpy.

struct process_info {
  int first_procrec_offset;  // struct procrec*
  //  Examples of system-wide things we could ask for
  int mem_total_kb;
  int mem_free_kb;
  int mem_available_kb;
  char reserved[];
};

struct procrec {
  int next_procrec_offset;  // struct procrec*
  // Following fields are self-explanatory and are only examples of the
  // kind of information we could provide.
  int tid;
  int tgid;
  char status;
  int oom_score_adj;
  struct { int real, effective, saved, fs; } uids;
  int prio;
  int comm_offset;  // char*
  uint64_t rss_file_kb
  uint64_t rss_anon_fb;
  uint64_t vm_seq;
  int first_procrec_vma_offset;  // struct procrec_vma*
  char reserved[];
};

struct procrec_vma {
  int next_procrec_vma_offset;  // struct procrec_vma*
  unsigned long start;
  unsigned long end;
  int backing_file_name_offset;  // char*
  int prot;
  char reserved[];
};

Callers would use the returned buffer by casting it to a struct
process_info and following the internal "pointers".

MASK would specify which bits of information we wanted: for example,
if we asked for PROCESS_VM_MEMORY_MAP, the kernel would fill in each
struct procret's memory_map field and have it point to a struct
procrec_vma in the returned output buffer. If we omitted
PROCESS_VM_MEMORY_MAP, we'd leave the memory_map field as NULL
(encoded as offset zero). The kernel would embed any strings (like
comm and VMA names) into the output buffer; the precise locations
would be unspecified so long as callers could find these fields via
output-buffer pointers.

Because all the structures are variable-length and are chained
together with explicit pointers (or offsets) instead of being stuffed
into a literal array, we can add additional fields to the output
structures any time we want without breaking binary compatibility.
Callers would tell the kernel that they're interested in the added
struct fields by asking for them via bits in MASK, and kernels that
don't understand those fields would just fail the system call with
EINVAL or something.

Depending on how we call it, we can use this API as a bunch of different things:

1) Quick retrieval of system-wide memory counters, like /proc/meminfo
2) Quick snapshot of all process-thread identities (asking for the
wildcard TID match via FLAGS)
3) Fast enumeration of one process's address space
4) Collecting process-summary VM counters (e.g., rss_anon and
rss_file) for a set of processes
5) Retrieval of every VMA of every process on the system for debugging

We can do all of this with one entry into the kernel and without
opening any new file descriptors (unless we want to use pidfds as
inputs). We can also make this operation as atomic as we want, e.g.,
taking mmap_sem while looking at each process and taking tasklist_lock
so all the thread IDs line up with their processes. We don't
necessarily need to take the mmap_sems of all processes we care about
at the same time.

Since this isn't a filesystem-based API, we don't have to deal with
seq_file or deal with consistency issues arising from userspace
programs doing strange things like reading procfs files very slowly in
small chunks. Security-wise, we'd just use different access checks for
different requested information bits in MASK, maybe supplying "no
access" struct procrec entries if a caller doesn't happen to have
access to a particular process. I suppose we can talk about whether
access check failures should result in dummy values or syscall
failure: maybe callers should select which behavior they want.
Format-wise, we could also just return flatbuffer messages from the
kernel, but I suspect that we don't want flatbuffer in the kernel
right now. :-)

The API I'm proposing accepts an array of processes to inspect. We
could simplify it by accepting just one process and making the caller
enter the kernel once per process it wants to learn about, but this
simplification would make the API less useful for answering questions
like "What's the RSS of every process on the system right now?".

What do you think?

