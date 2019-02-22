Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53C07C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0415B2075C
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 12:53:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="LNQKgdMo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0415B2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8734A8E00FB; Fri, 22 Feb 2019 07:53:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D2C88E00D4; Fri, 22 Feb 2019 07:53:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 629368E00FB; Fri, 22 Feb 2019 07:53:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id E2EE18E00D4
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:53:39 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id h65so957372wrh.16
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 04:53:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RU+or7OE+xeHtjxzNrTm9G6GbA97mBxvO1lEjBNgYI4=;
        b=sDZvJ7JMiy7Zm85CM0HakcQhxdddRSDG+EzBsCVWAl9wqLsznYTL8YOfjC0s6Rctez
         Vn+tKip8IfQvzhdRUkADjrpliFcpP8n4Q3AEukgV6M4ue7l/l3tXWR6+YA1qA3/WikHl
         kD0b0anXD0lLUSDWCEoJlGWIzpCZKXzvQweb8u+8Z6NhA/GdL0KjiYWd3qj2ztkfGdyl
         PUCWSF0DOWagITjcdC4R+eLh/HIEweNBUuvcjOWt9mTNQ3Id5HcNinNhW43mD2IRB8b6
         oNi7JhPhmpCKrEooWhs4h8mZbBlXBsgZld4iTMmKVOR4p3OXrnygOQt5X1Qx9POSIHs8
         wJoA==
X-Gm-Message-State: AHQUAubFSthILZVuS14OedRrakpMGKCe/Ek+YpwHVeUKBvOlODj6DIgJ
	lh21vS496vFOKSkkZgbp7i77fMaJq+TKrHtpCz+E23uOOn+Xuxy7+3IaM9h76nYUfPSTR3Ul9p2
	Txs6PdZGxP3b037y7oTFqNYWH7PM8tuE0IaliiO+DoJODJUwQJ/0H/7SEn5qgKCEvDB+eWzJd0c
	prIwXf0FFjFN/Iwi6rp3J3TJWORptBKvnaSRTZhN4b1y3hGAzJh7jm8s6wJXtM6CEcZjwjiedMH
	elDsDQb4LuWJtSJfiJWJwM50qY2mQqYUvpfWH6b/jlynayS1aPRMUrxSwXNwUxDw36AJl6y2ieR
	2YctMvdPaHZOBMckamhdoeTvUNKuXt1rKPv7UNokdBBS1TM3MKNqQNGVuIOx8LOxz4R87MZ/0RL
	6
X-Received: by 2002:adf:8068:: with SMTP id 95mr2939936wrk.181.1550840019446;
        Fri, 22 Feb 2019 04:53:39 -0800 (PST)
X-Received: by 2002:adf:8068:: with SMTP id 95mr2939881wrk.181.1550840018400;
        Fri, 22 Feb 2019 04:53:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550840018; cv=none;
        d=google.com; s=arc-20160816;
        b=kQGEJKmCtCB46YCKhRu79RRS8VExmrevoraiLljZCRb2NV1QlnAbOTLYtZRHXj7SGX
         fvbhIpOVeLRcuNSAum32o6935/+qersQZkslJ2blwkSn3dzDhYqzSj3rHTfibcslbB8w
         JMiVIfnEREhCx1OtCt7zeRcwyrioHZ3CNjKecTkfVrz6Mt9W9FO30Poiuxp6Jv6/W+dh
         L56mx7pu3slS38HQA6Z7g/NtTkqw93DAO9UfOlCKsO6MJOCLNT4/BSDuX+s6yuWNQhix
         u2qQRy4e6OAk+9s6Qo4aIQ0WFh68S2CHJR83kKSewN9Fu+RwHxBcmgS/1mI6sY0kLDME
         q2FQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=RU+or7OE+xeHtjxzNrTm9G6GbA97mBxvO1lEjBNgYI4=;
        b=JtqIPwmdurClm6XRp9dhZrRVyHpiTZ0QfICq/kr6nVpsw49yevy8RvDy4rtk9xvFui
         Y32KS9iptHKO/dHfxJAaFI4N51m2vJc+KaYkTQYHlmbmB0EUkGwiuWwg2CkBfTNPT1U/
         7dO8DxxcTZ8Q26eSqNM2uGcvjOahQwytm7N8jklRz1fGWKLpIk6GVVLf2Dl/nn5AKjtv
         o/8HEYChnirl69JT15rkAJEkZhZ4x3OzQaLmOAJKPBVs8J13zhsQhG1DDM+6QqFarIv6
         Sk1MXu4wmsZnI1+cuOwG6uOiLil8t8cQoMNsoCk//ZJYbVH7yr9if+VI406mhVpoM/Qd
         5A5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LNQKgdMo;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 8sor897141wmd.6.2019.02.22.04.53.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 04:53:38 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LNQKgdMo;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=RU+or7OE+xeHtjxzNrTm9G6GbA97mBxvO1lEjBNgYI4=;
        b=LNQKgdMoXLkk3vLgnA5PEOiEPK8fsk2VlYlLEiH/StERFEnr+McNBwQfGS9vvmjAMi
         QHTRwv032nohBRIotdakg7RO2p0g13+gcbIR/f7FS3M7GZntMbCdcTPNEc03llgebNcN
         A0xBE7hLwmM0ERnATLIP8CvfrkkQpkOb3O8KOUWOCCPwoN2j4oZKfYoZymy/mN+l2/kS
         hbDRlBHrLDPKxDTD4wcCjFAkP482/9puy/H3Ir4ZTTBolYjCVblrBDM0nO7Cb0lI7eDu
         hxtdRv+Oi1y5bBqs+F0RzEIPmxeQNS9IDhJoViWLDSaomrwJKnsrpHyIV8LLAV+1+HV0
         9SoA==
X-Google-Smtp-Source: AHgI3Ibb+5n0E6YRYhEsUNTW8xD300TNyoI4J/VhQut0YtmUKaRdSkhbzkgMSemHjOizIAIygUZsdQ==
X-Received: by 2002:a7b:c84b:: with SMTP id c11mr2397913wml.108.1550840017928;
        Fri, 22 Feb 2019 04:53:37 -0800 (PST)
Received: from andreyknvl0.muc.corp.google.com ([2a00:79e0:15:13:8ce:d7fa:9f4c:492])
        by smtp.gmail.com with ESMTPSA id o14sm808209wrp.34.2019.02.22.04.53.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 04:53:36 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Kate Stewart <kstewart@linuxfoundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Shuah Khan <shuah@kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v10 04/12] mm, arm64: untag user pointers passed to memory syscalls
Date: Fri, 22 Feb 2019 13:53:16 +0100
Message-Id: <3875fa863b755d8cb43afa7bb0fe543e5fd05a5d.1550839937.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.rc0.258.g878e2cd30e-goog
In-Reply-To: <cover.1550839937.git.andreyknvl@google.com>
References: <cover.1550839937.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This commit allows tagged pointers to be passed to the following memory
syscalls: madvise, mbind, get_mempolicy, mincore, mlock, mlock2, brk,
mmap_pgoff, old_mmap, munmap, remap_file_pages, mprotect, pkey_mprotect,
mremap, msync and shmdt.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 ipc/shm.c      | 2 ++
 mm/madvise.c   | 2 ++
 mm/mempolicy.c | 5 +++++
 mm/migrate.c   | 1 +
 mm/mincore.c   | 2 ++
 mm/mlock.c     | 5 +++++
 mm/mmap.c      | 7 +++++++
 mm/mprotect.c  | 2 ++
 mm/mremap.c    | 2 ++
 mm/msync.c     | 2 ++
 10 files changed, 30 insertions(+)

diff --git a/ipc/shm.c b/ipc/shm.c
index 0842411cb0e9..f0fd9591d28f 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1567,6 +1567,7 @@ SYSCALL_DEFINE3(shmat, int, shmid, char __user *, shmaddr, int, shmflg)
 	unsigned long ret;
 	long err;
 
+	shmaddr = untagged_addr(shmaddr);
 	err = do_shmat(shmid, shmaddr, shmflg, &ret, SHMLBA);
 	if (err)
 		return err;
@@ -1706,6 +1707,7 @@ long ksys_shmdt(char __user *shmaddr)
 
 SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
 {
+	shmaddr = untagged_addr(shmaddr);
 	return ksys_shmdt(shmaddr);
 }
 
diff --git a/mm/madvise.c b/mm/madvise.c
index 21a7881a2db4..64e6d34a7f9b 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -809,6 +809,8 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 	size_t len;
 	struct blk_plug plug;
 
+	start = untagged_addr(start);
+
 	if (!madvise_behavior_valid(behavior))
 		return error;
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index ee2bce59d2bf..0b5d5f794f4e 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1334,6 +1334,7 @@ static long kernel_mbind(unsigned long start, unsigned long len,
 	int err;
 	unsigned short mode_flags;
 
+	start = untagged_addr(start);
 	mode_flags = mode & MPOL_MODE_FLAGS;
 	mode &= ~MPOL_MODE_FLAGS;
 	if (mode >= MPOL_MAX)
@@ -1491,6 +1492,8 @@ static int kernel_get_mempolicy(int __user *policy,
 	int uninitialized_var(pval);
 	nodemask_t nodes;
 
+	addr = untagged_addr(addr);
+
 	if (nmask != NULL && maxnode < nr_node_ids)
 		return -EINVAL;
 
@@ -1576,6 +1579,8 @@ COMPAT_SYSCALL_DEFINE6(mbind, compat_ulong_t, start, compat_ulong_t, len,
 	unsigned long nr_bits, alloc_size;
 	nodemask_t bm;
 
+	start = untagged_addr(start);
+
 	nr_bits = min_t(unsigned long, maxnode-1, MAX_NUMNODES);
 	alloc_size = ALIGN(nr_bits, BITS_PER_LONG) / 8;
 
diff --git a/mm/migrate.c b/mm/migrate.c
index d4fd680be3b0..b9f414e66af1 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1601,6 +1601,7 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 		if (get_user(node, nodes + i))
 			goto out_flush;
 		addr = (unsigned long)p;
+		addr = untagged_addr(addr);
 
 		err = -ENODEV;
 		if (node < 0 || node >= MAX_NUMNODES)
diff --git a/mm/mincore.c b/mm/mincore.c
index 218099b5ed31..c4a3f4484b6b 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -228,6 +228,8 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 	unsigned long pages;
 	unsigned char *tmp;
 
+	start = untagged_addr(start);
+
 	/* Check the start address: needs to be page-aligned.. */
 	if (start & ~PAGE_MASK)
 		return -EINVAL;
diff --git a/mm/mlock.c b/mm/mlock.c
index 41cc47e28ad6..8fa29e7c0e73 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -715,6 +715,7 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
 
 SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 {
+	start = untagged_addr(start);
 	return do_mlock(start, len, VM_LOCKED);
 }
 
@@ -722,6 +723,8 @@ SYSCALL_DEFINE3(mlock2, unsigned long, start, size_t, len, int, flags)
 {
 	vm_flags_t vm_flags = VM_LOCKED;
 
+	start = untagged_addr(start);
+
 	if (flags & ~MLOCK_ONFAULT)
 		return -EINVAL;
 
@@ -735,6 +738,8 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 {
 	int ret;
 
+	start = untagged_addr(start);
+
 	len = PAGE_ALIGN(len + (offset_in_page(start)));
 	start &= PAGE_MASK;
 
diff --git a/mm/mmap.c b/mm/mmap.c
index f901065c4c64..fc8e908a97ba 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -199,6 +199,8 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 	bool downgraded = false;
 	LIST_HEAD(uf);
 
+	brk = untagged_addr(brk);
+
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
 
@@ -1571,6 +1573,8 @@ unsigned long ksys_mmap_pgoff(unsigned long addr, unsigned long len,
 	struct file *file = NULL;
 	unsigned long retval;
 
+	addr = untagged_addr(addr);
+
 	if (!(flags & MAP_ANONYMOUS)) {
 		audit_mmap_fd(fd, flags);
 		file = fget(fd);
@@ -2869,6 +2873,7 @@ EXPORT_SYMBOL(vm_munmap);
 
 SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
 {
+	addr = untagged_addr(addr);
 	profile_munmap(addr);
 	return __vm_munmap(addr, len, true);
 }
@@ -2887,6 +2892,8 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	unsigned long ret = -EINVAL;
 	struct file *file;
 
+	start = untagged_addr(start);
+
 	pr_warn_once("%s (%d) uses deprecated remap_file_pages() syscall. See Documentation/vm/remap_file_pages.rst.\n",
 		     current->comm, current->pid);
 
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 36cb358db170..9d79594dabee 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -578,6 +578,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot)
 {
+	start = untagged_addr(start);
 	return do_mprotect_pkey(start, len, prot, -1);
 }
 
@@ -586,6 +587,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 SYSCALL_DEFINE4(pkey_mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot, int, pkey)
 {
+	start = untagged_addr(start);
 	return do_mprotect_pkey(start, len, prot, pkey);
 }
 
diff --git a/mm/mremap.c b/mm/mremap.c
index 3320616ed93f..cd0e79c6ce63 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -588,6 +588,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	LIST_HEAD(uf_unmap_early);
 	LIST_HEAD(uf_unmap);
 
+	addr = untagged_addr(addr);
+
 	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
 		return ret;
 
diff --git a/mm/msync.c b/mm/msync.c
index ef30a429623a..c3bd3e75f687 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -37,6 +37,8 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 	int unmapped_error = 0;
 	int error = -EINVAL;
 
+	start = untagged_addr(start);
+
 	if (flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC))
 		goto out;
 	if (offset_in_page(start))
-- 
2.21.0.rc0.258.g878e2cd30e-goog

