Message-ID: <41DF266F.6020007@sgi.com>
Date: Fri, 07 Jan 2005 18:16:47 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: broken out migration patches
References: <1104875977.16305.7.camel@localhost>
In-Reply-To: <1104875977.16305.7.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: lhms <lhms-devel@lists.sourceforge.net>, Marcello Tosatti <marcelo.tosatti@cyclades.com>, Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave,

Looks there is some more work to do here to pull out HOTPLUG
stuff from the migration patches:

==> grep VM_IMMOVABLE page_migration-2.6.10-mm1-mhp-test7.patch
+       if (vma->vm_flags & VM_IMMOVABLE)
+               if (vma->vm_flags & VM_IMMOVABLE)
+#define VM_IMMOVABLE   0x01000000      /* Don't place in hot removable area */
+              _calc_vm_trans(flags, MAP_IMMOVABLE,  VM_IMMOVABLE );
+               tmp->vm_flags &= ~(VM_LOCKED|VM_IMMOVABLE);
[raybry@tomahawk.engr.sgi.com:patches/page-migration] 
 
===> grep HOTPLUG page_migration-2.6.10-mm1-mhp-test7.patch
+#ifndef _LINUX_MEMHOTPLUG_H
+#define _LINUX_MEMHOTPLUG_H
+#endif /* _LINUX_MEMHOTPLUG_H */
+#ifdef CONFIG_MEMORY_HOTPLUG
+#ifdef CONFIG_MEMORY_HOTPLUG
+#ifdef CONFIG_MEMORY_HOTPLUG
+#ifdef CONFIG_MEMORY_HOTPLUG
@@ -257,6 +257,8 @@ config HOTPLUG_CPU

The #ifdef's don't hurt anything, really, but it indicates that this 
separation isn't clean yet, right?

Should I carry over the VM_IMMOVABLE stuff in the page_migration patch?

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
