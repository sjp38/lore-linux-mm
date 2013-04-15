Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 93A596B0027
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 05:43:57 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 2/3] mem-hotplug: Put kernel_physical_mapping_remove() declaration in CONFIG_MEMORY_HOTREMOVE.
Date: Mon, 15 Apr 2013 17:46:46 +0800
Message-Id: <1366019207-27818-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1366019207-27818-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1366019207-27818-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, mgorman@suse.de, tj@kernel.org, liwanp@linux.vnet.ibm.com
Cc: tangchen@cn.fujitsu.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

kernel=5Fphysical=5Fmapping=5Fremove() is only called by arch=5Fremove=5Fme=
mory() in
init=5F64.c, which is enclosed in CONFIG=5FMEMORY=5FHOTREMOVE. So when we d=
on't
configure CONFIG=5FMEMORY=5FHOTREMOVE, the compiler will give a warning:

	warning: =E2=80=98kernel=5Fphysical=5Fmapping=5Fremove=E2=80=99 defined bu=
t not used

So put kernel=5Fphysical=5Fmapping=5Fremove() in CONFIG=5FMEMORY=5FHOTREMOV=
E.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/init=5F64.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/x86/mm/init=5F64.c b/arch/x86/mm/init=5F64.c
index 474e28f..dafdeb2 100644
--- a/arch/x86/mm/init=5F64.c
+++ b/arch/x86/mm/init=5F64.c
@@ -1019,6 +1019,7 @@ void =5F=5Fref vmemmap=5Ffree(struct page *memmap, un=
signed long nr=5Fpages)
 	remove=5Fpagetable(start, end, false);
 }
=20
+#ifdef CONFIG=5FMEMORY=5FHOTREMOVE
 static void =5F=5Fmeminit
 kernel=5Fphysical=5Fmapping=5Fremove(unsigned long start, unsigned long en=
d)
 {
@@ -1028,7 +1029,6 @@ kernel=5Fphysical=5Fmapping=5Fremove(unsigned long st=
art, unsigned long end)
 	remove=5Fpagetable(start, end, true);
 }
=20
-#ifdef CONFIG=5FMEMORY=5FHOTREMOVE
 int =5F=5Fref arch=5Fremove=5Fmemory(u64 start, u64 size)
 {
 	unsigned long start=5Fpfn =3D start >> PAGE=5FSHIFT;
--=20
1.7.1

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
